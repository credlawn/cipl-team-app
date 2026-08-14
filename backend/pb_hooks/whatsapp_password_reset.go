package pb_hooks

import (
	"crypto/rand"
	"encoding/json"
	"fmt"
	"math/big"
	"net/http"
	"os"
	"regexp"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

type PasswordResetEntry struct {
	UserID         string    `json:"user_id"`
	DeviceID       string    `json:"device_id"`
	Phone          string    `json:"phone"`
	OTP            string    `json:"otp"`
	ExpiresAt      time.Time `json:"expires_at"`
	FailedAttempts int       `json:"failed_attempts"`
}

type UserRateLimit struct {
	LastRequestTime time.Time
	DailyAttempts   int
	DateKey         string // e.g. "2026-08-11"
}

var (
	resetMu     sync.RWMutex
	resetStore  = make(map[string]PasswordResetEntry) // Key: device_id
	rateLimitMu sync.RWMutex
	rateLimits  = make(map[string]*UserRateLimit)     // Key: device_id
)

// extract10DigitPhone normalizes Indian phone numbers to 10 digits
func extract10DigitPhone(rawPhone string) string {
	clean := strings.TrimSpace(rawPhone)
	clean = strings.TrimPrefix(clean, "+")
	if strings.HasPrefix(clean, "91") && len(clean) > 10 {
		clean = clean[2:]
	}
	if len(clean) > 10 {
		clean = clean[len(clean)-10:]
	}
	return clean
}

// HandlePasswordResetWhatsAppMessage processes incoming WhatsApp messages for password reset
func HandlePasswordResetWhatsAppMessage(app *pocketbase.PocketBase, customerPhone string, messageBody string, replyToID string) bool {
	trimmed := strings.TrimSpace(messageBody)
	upperBody := strings.ToUpper(trimmed)

	if !strings.HasPrefix(upperBody, "RESET_PASSWORD") {
		return false
	}

	phone10 := extract10DigitPhone(customerPhone)

	// Extract payload after RESET_PASSWORD (expected format: RESET_PASSWORD:<DEVICE_ID>:<TIMESTAMP>)
	rest := strings.TrimSpace(trimmed[len("RESET_PASSWORD"):])
	rest = strings.TrimLeft(rest, ":= ")

	parts := strings.Split(rest, ":")
	if len(parts) < 2 {
		app.Logger().Warn("Password reset rejected: missing timestamp/nonce", "body", messageBody, "phone", phone10)
		replyMsg := "This password reset request is expired or invalid. Please initiate a fresh request from the CIPL mobile app."
		sendAndRecordWhatsAppAutoReply(app, customerPhone, replyMsg, replyToID)
		return true
	}

	incomingDeviceID := strings.TrimSpace(parts[0])
	timestampStr := strings.TrimSpace(parts[1])

	// 1. Verify 2-Minute Dynamic Timestamp Window
	tsInt, err := strconv.ParseInt(timestampStr, 10, 64)
	if err != nil {
		app.Logger().Warn("Password reset rejected: invalid timestamp", "ts", timestampStr, "phone", phone10)
		replyMsg := "Invalid password reset request format. Please initiate a fresh request from the CIPL mobile app."
		sendAndRecordWhatsAppAutoReply(app, customerPhone, replyMsg, replyToID)
		return true
	}

	msgTime := time.Unix(tsInt, 0)
	age := time.Since(msgTime)
	// Allow 2 minutes in past and 1 minute clock skew in future
	if age > 2*time.Minute || age < -1*time.Minute {
		app.Logger().Warn("Password reset rejected: timestamp expired (>2m)", "age", age, "phone", phone10)
		replyMsg := "This password reset request has expired. Please initiate a fresh request from the CIPL mobile app."
		sendAndRecordWhatsAppAutoReply(app, customerPhone, replyMsg, replyToID)
		return true
	}

	// 2. Find user by mobile number or username using direct SQL query
	var userRecord struct {
		ID       string `db:"id"`
		DeviceID string `db:"device_id"`
		MobileNo string `db:"mobile_no"`
		Username string `db:"username"`
		Disabled bool   `db:"disabled"`
	}

	dbErr := app.DB().NewQuery(`
		SELECT id, device_id, mobile_no, username, disabled 
		FROM users 
		WHERE (
			mobile_no = {:p10} OR 
			mobile_no = {:p12} OR 
			mobile_no = {:pPlus12} OR 
			mobile_no LIKE {:pLike} OR
			username = {:p10} OR 
			username = {:p12} OR 
			username LIKE {:pLike}
		) AND disabled = false
		LIMIT 1
	`).Bind(dbx.Params{
		"p10":     phone10,
		"p12":     "91" + phone10,
		"pPlus12": "+91" + phone10,
		"pLike":   "%" + phone10,
	}).One(&userRecord)

	if dbErr != nil || userRecord.ID == "" {
		app.Logger().Warn("Password reset requested for unregistered phone number", "phone", phone10, "raw_phone", customerPhone, "err", dbErr)
		replyMsg := "This mobile number is not registered in the CIPL system. Please contact HR for assistance."
		sendAndRecordWhatsAppAutoReply(app, customerPhone, replyMsg, replyToID)
		return true
	}

	// 3. Check strict device bonding match
	storedDeviceID := strings.TrimSpace(userRecord.DeviceID)
	if incomingDeviceID == "" || !strings.EqualFold(storedDeviceID, incomingDeviceID) {
		app.Logger().Warn("Password reset rejected due to device mismatch",
			"phone", phone10,
			"stored_device", storedDeviceID,
			"incoming_device", incomingDeviceID,
		)
		replyMsg := "This device is not registered with your account. Password reset is only permitted from your registered mobile device. Please contact HR/Admin to reset your device bonding."
		sendAndRecordWhatsAppAutoReply(app, customerPhone, replyMsg, replyToID)
		return true
	}

	// 4. Rate Limiting: 60-Second Cooldown & Max 3 Attempts per Day
	todayStr := time.Now().UTC().Format("2006-01-02")
	rateLimitMu.Lock()
	rl, exists := rateLimits[incomingDeviceID]
	if !exists || rl.DateKey != todayStr {
		rl = &UserRateLimit{
			DateKey:       todayStr,
			DailyAttempts: 0,
		}
		rateLimits[incomingDeviceID] = rl
	}

	if !rl.LastRequestTime.IsZero() && time.Since(rl.LastRequestTime) < 60*time.Second {
		rateLimitMu.Unlock()
		app.Logger().Warn("Password reset cooldown triggered", "device_id", incomingDeviceID)
		replyMsg := "Please wait a minute before requesting another password reset OTP."
		sendAndRecordWhatsAppAutoReply(app, customerPhone, replyMsg, replyToID)
		return true
	}

	if rl.DailyAttempts >= 3 {
		rateLimitMu.Unlock()
		app.Logger().Warn("Password reset daily limit reached", "device_id", incomingDeviceID, "attempts", rl.DailyAttempts)
		replyMsg := "You have reached the maximum allowed password reset attempts for today. Please contact HR for assistance."
		sendAndRecordWhatsAppAutoReply(app, customerPhone, replyMsg, replyToID)
		return true
	}

	rl.DailyAttempts++
	rl.LastRequestTime = time.Now()
	rateLimitMu.Unlock()

	// 5. Generate 6-digit cryptographic random OTP
	n, err := rand.Int(rand.Reader, big.NewInt(900000))
	if err != nil {
		app.Logger().Error("Failed to generate secure OTP", "error", err)
		return true
	}
	otp := fmt.Sprintf("%06d", n.Int64()+100000)

	// 6. Save to in-memory store (5-minute expiration)
	resetMu.Lock()
	resetStore[incomingDeviceID] = PasswordResetEntry{
		UserID:         userRecord.ID,
		DeviceID:       incomingDeviceID,
		Phone:          phone10,
		OTP:            otp,
		ExpiresAt:      time.Now().Add(5 * time.Minute),
		FailedAttempts: 0,
	}
	resetMu.Unlock()

	app.Logger().Info("Generated password reset OTP for user", "phone", phone10, "device_id", incomingDeviceID)

	// 7. Send OTP via WhatsApp and record in message history
	replyMsg := fmt.Sprintf("*%s*\n\nUse this OTP to reset your CIPL account password. This code is valid for 5 minutes.\n\nPlease do not share this OTP with anyone.", otp)
	sendAndRecordWhatsAppAutoReply(app, customerPhone, replyMsg, replyToID)

	return true
}

// sendAndRecordWhatsAppAutoReply sends an auto-reply via Meta API and records it in PocketBase collections
func sendAndRecordWhatsAppAutoReply(app *pocketbase.PocketBase, customerPhone string, replyMsg string, replyToID string) {
	accessToken := os.Getenv("WHATSAPP_ACCESS_TOKEN")
	phoneID := os.Getenv("WHATSAPP_PHONE_NUMBER_ID")

	if phoneID == "" || accessToken == "" {
		app.Logger().Error("WhatsApp configuration is missing for sending auto reply")
		return
	}

	// 1. Send via Meta API
	metaMsgID, err := sendWhatsAppMessage(phoneID, accessToken, customerPhone, replyMsg, replyToID)
	if err != nil {
		app.Logger().Error("Failed to send WhatsApp auto reply", "error", err, "phone", customerPhone)
		return
	}

	// 2. Fetch or create conversation thread
	conversation, err := app.FindFirstRecordByData("whatsapp_conversations", "customer_phone", customerPhone)
	if err != nil {
		col, colErr := app.FindCollectionByNameOrId("whatsapp_conversations")
		if colErr == nil {
			conversation = core.NewRecord(col)
			conversation.Set("customer_phone", customerPhone)
			conversation.Set("customer_name", "Employee")
			conversation.Set("status", "open")
		}
	}

	nowStr := time.Now().UTC().Format("2006-01-02 15:04:05.000Z")

	if conversation != nil {
		conversation.Set("last_message", replyMsg)
		conversation.Set("last_message_time", nowStr)
		if saveConvErr := app.Save(conversation); saveConvErr != nil {
			app.Logger().Error("Failed to save conversation update", "error", saveConvErr)
		}

		// 3. Save outgoing record in whatsapp_messages collection
		msgCol, msgColErr := app.FindCollectionByNameOrId("whatsapp_messages")
		if msgColErr == nil {
			rec := core.NewRecord(msgCol)
			rec.Set("conversation", conversation.Id)
			rec.Set("sender_phone", "")
			rec.Set("direction", "outgoing")
			rec.Set("type", "text")
			rec.Set("body", replyMsg)
			rec.Set("reply_to_id", replyToID)
			rec.Set("status", "sent")
			rec.Set("message_id", metaMsgID)
			rec.Set("timestamp", nowStr)
			if saveErr := app.Save(rec); saveErr != nil {
				app.Logger().Error("Failed to save outgoing auto reply message record", "error", saveErr)
			}
		}
	}
}

// SetupWhatsAppPasswordResetAPI registers the password reset submission endpoint
func SetupWhatsAppPasswordResetAPI(app *pocketbase.PocketBase) {
	app.OnServe().BindFunc(func(e *core.ServeEvent) error {
		e.Router.POST("/api/auth/reset-password-otp", func(c *core.RequestEvent) error {
			type ResetRequest struct {
				DeviceID        string `json:"device_id"`
				OTP             string `json:"otp"`
				Password        string `json:"password"`
				PasswordConfirm string `json:"password_confirm"`
			}

			var req ResetRequest
			if err := json.NewDecoder(c.Request.Body).Decode(&req); err != nil {
				return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid request payload"})
			}

			req.DeviceID = strings.TrimSpace(req.DeviceID)
			req.OTP = strings.TrimSpace(req.OTP)
			req.Password = strings.TrimSpace(req.Password)
			req.PasswordConfirm = strings.TrimSpace(req.PasswordConfirm)

			if req.DeviceID == "" {
				return c.JSON(http.StatusBadRequest, map[string]string{"error": "Device ID is required"})
			}
			if req.OTP == "" {
				return c.JSON(http.StatusBadRequest, map[string]string{"error": "Please enter the 6-digit OTP"})
			}
			if req.Password == "" || req.PasswordConfirm == "" {
				return c.JSON(http.StatusBadRequest, map[string]string{"error": "Password and confirmation are required"})
			}
			if req.Password != req.PasswordConfirm {
				return c.JSON(http.StatusBadRequest, map[string]string{"error": "Passwords do not match"})
			}

			// Validate Password Strength Rules
			if len(req.Password) < 8 {
				return c.JSON(http.StatusBadRequest, map[string]string{"error": "Password must be at least 8 characters long"})
			}
			if !regexp.MustCompile(`[A-Z]`).MatchString(req.Password) {
				return c.JSON(http.StatusBadRequest, map[string]string{"error": "Password must include at least one uppercase letter (A-Z)"})
			}
			if !regexp.MustCompile(`[a-z]`).MatchString(req.Password) {
				return c.JSON(http.StatusBadRequest, map[string]string{"error": "Password must include at least one lowercase letter (a-z)"})
			}
			if !regexp.MustCompile(`[0-9]`).MatchString(req.Password) {
				return c.JSON(http.StatusBadRequest, map[string]string{"error": "Password must include at least one number (0-9)"})
			}
			if req.Password == "Cred@2026" {
				return c.JSON(http.StatusBadRequest, map[string]string{"error": "You cannot use the default password. Please choose a unique one."})
			}

			// Verify OTP from store with attempt tracking
			resetMu.Lock()
			entry, exists := resetStore[req.DeviceID]
			if !exists || time.Now().After(entry.ExpiresAt) {
				resetMu.Unlock()
				return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid or expired OTP. Please request a new OTP via WhatsApp."})
			}

			if entry.OTP != req.OTP {
				entry.FailedAttempts++
				if entry.FailedAttempts >= 3 {
					delete(resetStore, req.DeviceID)
					resetMu.Unlock()
					return c.JSON(http.StatusBadRequest, map[string]string{"error": "Too many incorrect OTP attempts. This OTP has been invalidated. Please request a new OTP via WhatsApp."})
				}
				resetStore[req.DeviceID] = entry
				resetMu.Unlock()
				return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid OTP. Please check the code sent on WhatsApp."})
			}

			// OTP verified, consume it
			delete(resetStore, req.DeviceID)
			resetMu.Unlock()

			// Load user record
			user, err := c.App.FindRecordById("users", entry.UserID)
			if err != nil || user == nil {
				return c.JSON(http.StatusNotFound, map[string]string{"error": "User account not found"})
			}

			// Update password and reset must_change_password flag
			user.SetPassword(req.Password)
			user.Set("must_change_password", false)

			if err := c.App.Save(user); err != nil {
				c.App.Logger().Error("Failed to update user password during OTP reset", "error", err, "user_id", user.Id)
				return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to update password. Please try again."})
			}

			c.App.Logger().Info("Password reset successfully completed for user", "user_id", user.Id, "device_id", req.DeviceID)

			return c.JSON(http.StatusOK, map[string]interface{}{
				"success": true,
				"message": "Password reset successfully! Please sign in with your new password.",
			})
		})

		return e.Next()
	})
}
