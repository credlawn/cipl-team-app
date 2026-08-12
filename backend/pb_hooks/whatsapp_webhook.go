package pb_hooks

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/tools/filesystem"
)

// Define Go structs for WhatsApp Webhook payload
type WhatsAppWebhookPayload struct {
	Object string          `json:"object"`
	Entry  []WhatsAppEntry `json:"entry"`
}

type WhatsAppEntry struct {
	ID      string           `json:"id"`
	Changes []WhatsAppChange `json:"changes"`
}

type WhatsAppChange struct {
	Value WhatsAppValue `json:"value"`
	Field string         `json:"field"`
}

type WhatsAppValue struct {
	MessagingProduct string            `json:"messaging_product"`
	Metadata         WhatsAppMetadata  `json:"metadata"`
	Contacts         []WhatsAppContact `json:"contacts"`
	Messages         []WhatsAppMessage `json:"messages"`
	Statuses         []WhatsAppStatus  `json:"statuses"`
}

type WhatsAppMetadata struct {
	DisplayPhoneNumber string `json:"display_phone_number"`
	PhoneNumberID      string `json:"phone_number_id"`
}

type WhatsAppContact struct {
	Profile WhatsAppProfile `json:"profile"`
	WaID    string          `json:"wa_id"`
}

type WhatsAppProfile struct {
	Name string `json:"name"`
}

type WhatsAppMessage struct {
	From        string               `json:"from"`
	ID          string               `json:"id"`
	Timestamp   string               `json:"timestamp"`
	Type        string               `json:"type"`
	Text        *WhatsAppText        `json:"text,omitempty"`
	Image       *WhatsAppMedia       `json:"image,omitempty"`
	Audio       *WhatsAppMedia       `json:"audio,omitempty"`
	Video       *WhatsAppMedia       `json:"video,omitempty"`
	Voice       *WhatsAppMedia       `json:"voice,omitempty"`
	Document    *WhatsAppMedia       `json:"document,omitempty"`
	Sticker     *WhatsAppMedia       `json:"sticker,omitempty"`
	Button      *WhatsAppButton      `json:"button,omitempty"`
	Interactive *WhatsAppInteractive `json:"interactive,omitempty"`
	Location    *WhatsAppLocation    `json:"location,omitempty"`
	Context     *WhatsAppContext     `json:"context,omitempty"`
}

type WhatsAppText struct {
	Body string `json:"body"`
}

type WhatsAppButton struct {
	Text    string `json:"text"`
	Payload string `json:"payload,omitempty"`
}

type WhatsAppInteractive struct {
	Type        string                    `json:"type"`
	ButtonReply *WhatsAppInteractiveReply `json:"button_reply,omitempty"`
	ListReply   *WhatsAppInteractiveReply `json:"list_reply,omitempty"`
}

type WhatsAppInteractiveReply struct {
	ID    string `json:"id"`
	Title string `json:"title"`
}

type WhatsAppLocation struct {
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
	Name      string  `json:"name,omitempty"`
	Address   string  `json:"address,omitempty"`
}

type WhatsAppMedia struct {
	ID       string `json:"id"`
	MimeType string `json:"mime_type"`
	Caption  string `json:"caption,omitempty"`
	Filename string `json:"filename,omitempty"`
}

type WhatsAppContext struct {
	From string `json:"from"`
	ID   string `json:"id"` // Message ID of the message being replied to
}

type WhatsAppStatus struct {
	ID          string `json:"id"`
	Status      string `json:"status"` // sent, delivered, read, failed, deleted
	Timestamp   string `json:"timestamp"`
	RecipientID string `json:"recipient_id"`
}

// SetupWhatsAppWebhook configures the WhatsApp Webhook endpoints (GET for verification and POST for receiving payloads)
func SetupWhatsAppWebhook(app *pocketbase.PocketBase) {
	app.OnServe().BindFunc(func(e *core.ServeEvent) error {
		// 1. Webhook Verification (GET)
		e.Router.GET("/api/whatsapp/webhook", func(c *core.RequestEvent) error {
			verifyToken := c.Request.URL.Query().Get("hub.verify_token")
			challenge := c.Request.URL.Query().Get("hub.challenge")
			mode := c.Request.URL.Query().Get("hub.mode")

			// Read verify token from environment variable
			storedVerifyToken := os.Getenv("WHATSAPP_VERIFY_TOKEN")
			if storedVerifyToken == "" {
				app.Logger().Error("WHATSAPP_VERIFY_TOKEN environment variable is not configured")
				return c.String(http.StatusInternalServerError, "Verify token configuration missing")
			}

			if mode == "subscribe" && verifyToken == storedVerifyToken {
				return c.String(http.StatusOK, challenge)
			}

			app.Logger().Warn("WhatsApp webhook verification failed", "received_token", verifyToken)
			return c.String(http.StatusForbidden, "Verification failed")
		})

		// 2. Webhook Event handling (POST)
		e.Router.POST("/api/whatsapp/webhook", func(c *core.RequestEvent) error {
			bodyBytes, err := io.ReadAll(c.Request.Body)
			if err != nil {
				app.Logger().Error("Failed to read WhatsApp webhook payload body", "error", err)
				return c.String(http.StatusBadRequest, "Invalid request body")
			}

			// Validate signature (X-Hub-Signature-256) if App Secret is configured
			appSecret := os.Getenv("WHATSAPP_APP_SECRET")
			if appSecret != "" {
				signatureHeader := c.Request.Header.Get("X-Hub-Signature-256")
				if !verifySignature(bodyBytes, signatureHeader, appSecret) {
					app.Logger().Warn("WhatsApp webhook signature verification failed", "signature", signatureHeader)
					return c.String(http.StatusForbidden, "Invalid signature")
				}
			}

			var payload WhatsAppWebhookPayload
			if err := json.Unmarshal(bodyBytes, &payload); err != nil {
				app.Logger().Error("Failed to parse WhatsApp webhook JSON", "error", err)
				// Return 200 OK to Meta to avoid webhook retries on parse failure
				return c.JSON(http.StatusOK, map[string]string{"status": "ignored_bad_format"})
			}

			// Process incoming events from entries
			for _, entry := range payload.Entry {
				for _, change := range entry.Changes {
					value := change.Value

					// A: Handle Incoming Messages
					if len(value.Messages) > 0 {
						for _, msg := range value.Messages {
							customerName := "WhatsApp User"
							// Match customer's profile name from contacts list
							for _, contact := range value.Contacts {
								if contact.WaID == msg.From {
									if contact.Profile.Name != "" {
										customerName = contact.Profile.Name
									}
									break
								}
							}

							if err := handleIncomingMessage(app, msg, customerName, bodyBytes); err != nil {
								app.Logger().Error("Failed to handle incoming WhatsApp message", "error", err, "message_id", msg.ID)
							}
						}
					}

					// B: Handle Message Status updates (sent, delivered, read, failed)
					if len(value.Statuses) > 0 {
						for _, status := range value.Statuses {
							if err := handleMessageStatusUpdate(app, status); err != nil {
								app.Logger().Error("Failed to handle WhatsApp message status update", "error", err, "message_id", status.ID)
							}
						}
					}
				}
			}

			return c.JSON(http.StatusOK, map[string]string{"status": "success"})
		})

		return e.Next()
	})}

// verifySignature validates the HMAC SHA-256 signature from Meta
func verifySignature(body []byte, signatureHeader string, secret string) bool {
	if !strings.HasPrefix(signatureHeader, "sha256=") {
		return false
	}
	actualSigHex := signatureHeader[7:]
	actualSig, err := hex.DecodeString(actualSigHex)
	if err != nil {
		return false
	}

	mac := hmac.New(sha256.New, []byte(secret))
	mac.Write(body)
	expectedSig := mac.Sum(nil)

	return hmac.Equal(actualSig, expectedSig)
}

func handleIncomingMessage(app *pocketbase.PocketBase, msg WhatsAppMessage, customerName string, rawPayload []byte) error {
	customerPhone := msg.From

	// 1. Fetch or Create the Conversation thread
	conversation, err := app.FindFirstRecordByData("whatsapp_conversations", "customer_phone", customerPhone)
	if err != nil {
		collection, err := app.FindCollectionByNameOrId("whatsapp_conversations")
		if err != nil {
			return fmt.Errorf("conversations collection search failed: %w", err)
		}

		conversation = core.NewRecord(collection)
		conversation.Set("customer_phone", customerPhone)
		conversation.Set("customer_name", customerName)
		conversation.Set("status", "open")
	}

	// 2. Parse details based on message type
	var messageBody string
	var mediaID string
	var mimeType string

	switch msg.Type {
	case "text":
		if msg.Text != nil {
			messageBody = msg.Text.Body
		}
	case "image":
		if msg.Image != nil {
			mediaID = msg.Image.ID
			mimeType = msg.Image.MimeType
			messageBody = msg.Image.Caption
		}
	case "audio":
		if msg.Audio != nil {
			mediaID = msg.Audio.ID
			mimeType = msg.Audio.MimeType
		}
	case "video":
		if msg.Video != nil {
			mediaID = msg.Video.ID
			mimeType = msg.Video.MimeType
			messageBody = msg.Video.Caption
		}
	case "voice":
		if msg.Voice != nil {
			mediaID = msg.Voice.ID
			mimeType = msg.Voice.MimeType
		}
	case "document":
		if msg.Document != nil {
			mediaID = msg.Document.ID
			mimeType = msg.Document.MimeType
			messageBody = msg.Document.Caption
			if messageBody == "" && msg.Document.Filename != "" {
				messageBody = msg.Document.Filename
			}
		}
	case "sticker":
		if msg.Sticker != nil {
			mediaID = msg.Sticker.ID
			mimeType = msg.Sticker.MimeType
			messageBody = "[Sticker]"
		}
	case "button":
		if msg.Button != nil {
			messageBody = msg.Button.Text
		}
	case "interactive":
		if msg.Interactive != nil {
			if msg.Interactive.Type == "button_reply" && msg.Interactive.ButtonReply != nil {
				messageBody = msg.Interactive.ButtonReply.Title
			} else if msg.Interactive.Type == "list_reply" && msg.Interactive.ListReply != nil {
				messageBody = msg.Interactive.ListReply.Title
			} else {
				messageBody = "[Interactive Response]"
			}
		}
	case "location":
		if msg.Location != nil {
			locName := msg.Location.Name
			if locName == "" {
				locName = msg.Location.Address
			}
			if locName == "" {
				locName = fmt.Sprintf("%f,%f", msg.Location.Latitude, msg.Location.Longitude)
			}
			messageBody = fmt.Sprintf("[Location: %s]", locName)
		}
	default:
		messageBody = fmt.Sprintf("[Received message type: %s]", msg.Type)
	}

	var replyToID string
	if msg.Context != nil {
		replyToID = msg.Context.ID
	}

	// Parse Meta message UNIX timestamp
	msgTime := time.Now().UTC()
	if sec, err := strconv.ParseInt(msg.Timestamp, 10, 64); err == nil {
		msgTime = time.Unix(sec, 0).UTC()
	}

	// 3. Save / Update Conversation metadata
	conversation.Set("last_message", messageBody)
	conversation.Set("last_message_time", msgTime.Format("2006-01-02 15:04:05.000Z"))
	if err := app.Save(conversation); err != nil {
		return fmt.Errorf("failed to save conversation: %w", err)
	}

	// 4. Create and Save Message record
	msgCollection, err := app.FindCollectionByNameOrId("whatsapp_messages")
	if err != nil {
		return fmt.Errorf("messages collection search failed: %w", err)
	}

	messageRecord := core.NewRecord(msgCollection)
	messageRecord.Set("message_id", msg.ID)
	messageRecord.Set("conversation", conversation.Id)
	messageRecord.Set("sender_phone", customerPhone)
	messageRecord.Set("direction", "incoming")
	messageRecord.Set("type", msg.Type)
	messageRecord.Set("body", messageBody)
	messageRecord.Set("reply_to_id", replyToID)
	messageRecord.Set("status", "received")
	messageRecord.Set("media_id", mediaID)
	messageRecord.Set("mime_type", mimeType)
	messageRecord.Set("timestamp", msgTime.Format("2006-01-02 15:04:05.000Z"))
	messageRecord.Set("payload", string(rawPayload))

	if mediaID != "" {
		file, err := downloadMediaFromMeta(app, mediaID)
		if err != nil {
			app.Logger().Error("Failed to download media from Meta", "error", err, "media_id", mediaID)
		} else {
			messageRecord.Set("media_file", file)
		}
	}

	if err := app.Save(messageRecord); err != nil {
		return fmt.Errorf("failed to save message record: %w", err)
	}

	// Check for specialized WhatsApp actions (Password reset, Daily Device Auth)
	if msg.Type == "text" && messageBody != "" {
		go HandlePasswordResetWhatsAppMessage(app, customerPhone, messageBody, msg.ID)
		go HandleDeviceAuthWhatsAppMessage(app, customerPhone, messageBody, msg.ID)
	}

	return nil
}

func handleMessageStatusUpdate(app *pocketbase.PocketBase, status WhatsAppStatus) error {
	// Locate original message record using message_id
	messageRecord, err := app.FindFirstRecordByData("whatsapp_messages", "message_id", status.ID)
	if err != nil {
		// Log but don't error out; might be a status for a message sent externally or not captured
		return fmt.Errorf("message record not found for status update (ID: %s)", status.ID)
	}

	// Update status field
	messageRecord.Set("status", status.Status)

	if err := app.Save(messageRecord); err != nil {
		return fmt.Errorf("failed to save updated message status: %w", err)
	}

	return nil
}

// Map of MIME types to file extensions
var mimeExtensions = map[string]string{
	"image/jpeg":                                                              ".jpg",
	"image/png":                                                               ".png",
	"image/webp":                                                              ".webp",
	"image/gif":                                                               ".gif",
	"audio/mpeg":                                                              ".mp3",
	"audio/ogg":                                                               ".ogg",
	"audio/amr":                                                               ".amr",
	"audio/aac":                                                               ".aac",
	"audio/m4a":                                                               ".m4a",
	"video/mp4":                                                               ".mp4",
	"video/3gpp":                                                              ".3gp",
	"application/pdf":                                                         ".pdf",
	"text/plain":                                                              ".txt",
	"application/msword":                                                      ".doc",
	"application/vnd.openxmlformats-officedocument.wordprocessingml.document": ".docx",
	"application/vnd.ms-excel":                                                ".xls",
	"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet":       ".xlsx",
}

// downloadMediaFromMeta queries Meta API to get media metadata, downloads the bytes, and wraps it in a *filesystem.File
func downloadMediaFromMeta(app *pocketbase.PocketBase, mediaID string) (*filesystem.File, error) {
	accessToken := os.Getenv("WHATSAPP_ACCESS_TOKEN")
	if accessToken == "" {
		return nil, fmt.Errorf("WHATSAPP_ACCESS_TOKEN is not configured")
	}

	// 1. Fetch media URL metadata from Meta Graph API
	metadataUrl := fmt.Sprintf("https://graph.facebook.com/v19.0/%s", mediaID)
	req, err := http.NewRequest("GET", metadataUrl, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to create metadata request: %w", err)
	}
	req.Header.Set("Authorization", "Bearer "+accessToken)

	client := &http.Client{Timeout: 15 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to call Meta media API: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		bodyBytes, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("Meta API metadata returned status %d: %s", resp.StatusCode, string(bodyBytes))
	}

	var metadata struct {
		URL      string `json:"url"`
		MimeType string `json:"mime_type"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&metadata); err != nil {
		return nil, fmt.Errorf("failed to decode Meta metadata response: %w", err)
	}

	if metadata.URL == "" {
		return nil, fmt.Errorf("empty URL returned in media metadata")
	}

	// 2. Download the binary payload using the retrieved URL
	downloadReq, err := http.NewRequest("GET", metadata.URL, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to create download request: %w", err)
	}
	downloadReq.Header.Set("Authorization", "Bearer "+accessToken)

	downloadResp, err := client.Do(downloadReq)
	if err != nil {
		return nil, fmt.Errorf("failed to execute download request: %w", err)
	}
	defer downloadResp.Body.Close()

	if downloadResp.StatusCode != http.StatusOK {
		bodyBytes, _ := io.ReadAll(downloadResp.Body)
		return nil, fmt.Errorf("Meta media download returned status %d: %s", downloadResp.StatusCode, string(bodyBytes))
	}

	fileBytes, err := io.ReadAll(downloadResp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read media body: %w", err)
	}

	// 3. Resolve file extension and construct *filesystem.File
	ext := ".bin"
	if customExt, ok := mimeExtensions[metadata.MimeType]; ok {
		ext = customExt
	} else {
		parts := strings.Split(metadata.MimeType, "/")
		if len(parts) == 2 {
			ext = "." + parts[1]
		}
	}
	filename := fmt.Sprintf("%s%s", mediaID, ext)

	file, err := filesystem.NewFileFromBytes(fileBytes, filename)
	if err != nil {
		return nil, fmt.Errorf("failed to create filesystem.File: %w", err)
	}

	return file, nil
}
