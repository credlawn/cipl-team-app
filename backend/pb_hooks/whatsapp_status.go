package pb_hooks

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"sync"
	"time"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

var (
	cacheMutex    sync.Mutex
	lastCheckTime time.Time
	cachedStatus  *WhatsAppStatusResponse
	cacheDuration = 10 * time.Minute // 10 minutes cache
)

type WhatsAppStatusResponse struct {
	Status         string   `json:"status"` // "active", "idle", "error"
	MetaSubscribed bool     `json:"meta_subscribed"`
	LastEventTime  string   `json:"last_event_time"`
	Details        []string `json:"details"`
}

type MetaField struct {
	Name    string `json:"name"`
	Version string `json:"version"`
}

type MetaSubscription struct {
	Object      string      `json:"object"`
	CallbackURL string      `json:"callback_url"`
	Fields      []MetaField `json:"fields"`
	Active      bool        `json:"active"`
}

type MetaSubscriptionsResponse struct {
	Data []MetaSubscription `json:"data"`
}

// SetupWhatsAppStatusAPI registers the status verification endpoint
func SetupWhatsAppStatusAPI(app *pocketbase.PocketBase) {
	app.OnServe().BindFunc(func(e *core.ServeEvent) error {
		e.Router.GET("/api/whatsapp/status", func(c *core.RequestEvent) error {
			statusResp := getWhatsAppStatus(app)
			return c.JSON(http.StatusOK, statusResp)
		})
		return e.Next()
	})
}

func getWhatsAppStatus(app *pocketbase.PocketBase) *WhatsAppStatusResponse {
	cacheMutex.Lock()
	defer cacheMutex.Unlock()

	// If cache is valid, return it
	if cachedStatus != nil && time.Since(lastCheckTime) < cacheDuration {
		return cachedStatus
	}

	// Otherwise, perform checks
	status := checkWhatsAppStatus(app)
	cachedStatus = status
	lastCheckTime = time.Now()
	return cachedStatus
}

func checkWhatsAppStatus(app *pocketbase.PocketBase) *WhatsAppStatusResponse {
	appID := os.Getenv("WHATSAPP_APP_ID")
	appSecret := os.Getenv("WHATSAPP_APP_SECRET")
	accessToken := os.Getenv("WHATSAPP_ACCESS_TOKEN")

	var details []string
	metaSubscribed := false

	if appID == "" {
		details = append(details, "WHATSAPP_APP_ID is not configured in .env")
	}

	if appID != "" {
		var reqURL string
		// Build authorization query
		if appSecret != "" {
			reqURL = fmt.Sprintf("https://graph.facebook.com/v25.0/%s/subscriptions?access_token=%s|%s", appID, appID, appSecret)
		} else if accessToken != "" {
			reqURL = fmt.Sprintf("https://graph.facebook.com/v25.0/%s/subscriptions?access_token=%s", appID, accessToken)
		}

		if reqURL != "" {
			client := &http.Client{Timeout: 10 * time.Second}
			resp, err := client.Get(reqURL)
			if err == nil && resp.StatusCode == 200 {
				defer resp.Body.Close()
				bodyBytes, _ := io.ReadAll(resp.Body)
				var metaResp MetaSubscriptionsResponse
				if parseErr := json.Unmarshal(bodyBytes, &metaResp); parseErr == nil {
					for _, sub := range metaResp.Data {
						if sub.Object == "whatsapp_business_account" {
							for _, f := range sub.Fields {
								if f.Name == "messages" {
									metaSubscribed = true
									details = append(details, fmt.Sprintf("Meta webhook verified: Callback URL is %s", sub.CallbackURL))
									break
								}
							}
						}
					}
					if !metaSubscribed {
						details = append(details, "App does not have active subscription for 'messages' on object 'whatsapp_business_account' in Meta console")
					}
				} else {
					details = append(details, fmt.Sprintf("Failed to parse Meta subscription response: %v", parseErr))
				}
			} else {
				if resp != nil {
					defer resp.Body.Close()
					bodyBytes, _ := io.ReadAll(resp.Body)
					details = append(details, fmt.Sprintf("Meta Graph API returned error status %d: %s", resp.StatusCode, string(bodyBytes)))
				} else {
					details = append(details, fmt.Sprintf("Meta Graph API request failed: %v", err))
				}
			}
		} else {
			details = append(details, "Neither WHATSAPP_APP_SECRET nor WHATSAPP_ACCESS_TOKEN is configured to authorize Meta API")
		}
	}

	// 2. Query last incoming message timestamp
	var msgResult struct {
		Timestamp string `db:"timestamp"`
	}
	dbErr := app.DB().NewQuery("SELECT timestamp FROM whatsapp_messages WHERE direction = 'incoming' ORDER BY timestamp DESC LIMIT 1").One(&msgResult)

	lastEventTime := ""
	isRecent := false

	if dbErr == nil && msgResult.Timestamp != "" {
		lastEventTime = msgResult.Timestamp
		// Parse timestamp from database (format: "2006-01-02 15:04:05.000Z")
		t, parseErr := time.Parse("2006-01-02 15:04:05.000Z", msgResult.Timestamp)
		if parseErr == nil {
			if time.Since(t) < 24*time.Hour {
				isRecent = true
			}
		}
	} else if dbErr != nil && dbErr != sql.ErrNoRows {
		// Ignore check if table is empty, but record other database failures
		details = append(details, fmt.Sprintf("Database query for messages failed: %v", dbErr))
	}

	statusVal := "error"
	if metaSubscribed {
		if isRecent {
			statusVal = "active"
		} else {
			statusVal = "idle"
		}
	}

	return &WhatsAppStatusResponse{
		Status:         statusVal,
		MetaSubscribed: metaSubscribed,
		LastEventTime:  lastEventTime,
		Details:        details,
	}
}
