package pb_hooks

import (
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

var (
	deviceAuthMu  sync.RWMutex
	deviceAuthMap = make(map[string]string) // Key: device_id -> Value: cycleKey (e.g. "2026-08-11")
)

// getWorkdayCycleKey returns the cycle string based on 9:00 AM IST cutoff
func getWorkdayCycleKey(t time.Time) string {
	// Offset to IST (+5:30)
	loc := time.FixedZone("IST", 5*3600+1800)
	istTime := t.In(loc)

	if istTime.Hour() >= 9 {
		return istTime.Format("2006-01-02")
	}
	prev := istTime.AddDate(0, 0, -1)
	return prev.Format("2006-01-02")
}

// HandleDeviceAuthWhatsAppMessage processes incoming WhatsApp authorization messages
func HandleDeviceAuthWhatsAppMessage(app *pocketbase.PocketBase, customerPhone string, messageBody string, replyToID string) bool {
	trimmed := strings.TrimSpace(messageBody)
	upperBody := strings.ToUpper(trimmed)

	if !strings.HasPrefix(upperBody, "AUTHORIZE_DEVICE") {
		return false
	}

	phone10 := extract10DigitPhone(customerPhone)

	// Expected format: AUTHORIZE_DEVICE:<EMP_CODE>:<DEVICE_ID>:<TIMESTAMP>
	rest := strings.TrimSpace(trimmed[len("AUTHORIZE_DEVICE"):])
	rest = strings.TrimLeft(rest, ":= ")

	parts := strings.Split(rest, ":")
	if len(parts) < 3 {
		app.Logger().Warn("Device auth rejected: invalid format", "body", messageBody, "phone", phone10)
		replyMsg := "Invalid authorization format. Please use the 'Allow Login' button inside the CIPL app."
		sendAndRecordWhatsAppAutoReply(app, customerPhone, replyMsg, replyToID)
		return true
	}

	empCode := strings.TrimSpace(parts[0])
	incomingDeviceID := strings.TrimSpace(parts[1])
	timestampStr := strings.TrimSpace(parts[2])

	// 1. Verify Timestamp Freshness (max 5 minutes)
	tsInt, err := strconv.ParseInt(timestampStr, 10, 64)
	if err != nil {
		app.Logger().Warn("Device auth rejected: bad timestamp", "ts", timestampStr, "phone", phone10)
		replyMsg := "Invalid authorization timestamp. Please authorize from the CIPL app."
		sendAndRecordWhatsAppAutoReply(app, customerPhone, replyMsg, replyToID)
		return true
	}

	msgTime := time.Unix(tsInt, 0)
	age := time.Since(msgTime)
	if age > 5*time.Minute || age < -2*time.Minute {
		app.Logger().Warn("Device auth rejected: expired request", "age", age, "phone", phone10)
		replyMsg := "This authorization request has expired. Please tap 'Allow Login' again in the CIPL app."
		sendAndRecordWhatsAppAutoReply(app, customerPhone, replyMsg, replyToID)
		return true
	}

	// 2. Find user by Employee Code using direct SQL query
	var userRecord struct {
		ID           string `db:"id"`
		EmployeeCode string `db:"employee_code"`
		EmployeeName string `db:"employee_name"`
		DeviceID     string `db:"device_id"`
		MobileNo     string `db:"mobile_no"`
		Username     string `db:"username"`
		Disabled     bool   `db:"disabled"`
	}

	dbErr := app.DB().NewQuery(`
		SELECT id, employee_code, employee_name, device_id, mobile_no, username, disabled 
		FROM users 
		WHERE LOWER(employee_code) = LOWER({:empCode}) AND disabled = false
		LIMIT 1
	`).Bind(dbx.Params{
		"empCode": empCode,
	}).One(&userRecord)

	if dbErr != nil || userRecord.ID == "" {
		app.Logger().Warn("Device auth rejected: employee not found", "emp_code", empCode, "phone", phone10)
		replyMsg := fmt.Sprintf("Authorization Failed: Employee code '%s' not found in CIPL system. Please contact HR.", empCode)
		sendAndRecordWhatsAppAutoReply(app, customerPhone, replyMsg, replyToID)
		return true
	}

	// 3. Strict Phone Number Matching: Sender phone MUST match registered phone
	registeredPhone10 := extract10DigitPhone(userRecord.MobileNo)
	if registeredPhone10 == "" {
		registeredPhone10 = extract10DigitPhone(userRecord.Username)
	}

	if phone10 != registeredPhone10 {
		app.Logger().Warn("Device auth rejected: phone mismatch",
			"emp_code", empCode,
			"sender_phone", phone10,
			"registered_phone", registeredPhone10,
		)
		replyMsg := fmt.Sprintf("❌ Authorization Failed: This WhatsApp number (%s) is not registered for Employee %s. Please send this message from your registered mobile number (%s).", customerPhone, empCode, userRecord.MobileNo)
		sendAndRecordWhatsAppAutoReply(app, customerPhone, replyMsg, replyToID)
		return true
	}

	// 4. Strict Device ID Matching
	storedDeviceID := strings.TrimSpace(userRecord.DeviceID)
	if storedDeviceID != "" && !strings.EqualFold(storedDeviceID, incomingDeviceID) {
		app.Logger().Warn("Device auth rejected: device mismatch",
			"emp_code", empCode,
			"stored_device", storedDeviceID,
			"incoming_device", incomingDeviceID,
		)
		replyMsg := "❌ Authorization Failed: This device does not match your registered device bonding. Please contact HR/Admin."
		sendAndRecordWhatsAppAutoReply(app, customerPhone, replyMsg, replyToID)
		return true
	}

	// 5. SUCCESS: Authorize current 9:00 AM workday cycle
	currentCycle := getWorkdayCycleKey(time.Now())

	deviceAuthMu.Lock()
	deviceAuthMap[incomingDeviceID] = currentCycle
	deviceAuthMap[userRecord.ID] = currentCycle
	if storedDeviceID != "" {
		deviceAuthMap[storedDeviceID] = currentCycle
	}
	deviceAuthMu.Unlock()

	app.Logger().Info("Device authorized successfully",
		"emp_code", empCode,
		"device_id", incomingDeviceID,
		"cycle", currentCycle,
		"phone", phone10,
	)

	// 6. Send Success Confirmation to WhatsApp
	replyMsg := fmt.Sprintf("*Session Authorized! ✅*\n\nHello %s, your CIPL workspace session is now active for today.\n\nHave a productive day! 🚀", userRecord.EmployeeName)
	sendAndRecordWhatsAppAutoReply(app, customerPhone, replyMsg, replyToID)

	return true
}

// SetupDeviceAuthAPI registers the endpoint to check daily authorization status
func SetupDeviceAuthAPI(app *pocketbase.PocketBase) {
	app.OnServe().BindFunc(func(e *core.ServeEvent) error {
		e.Router.GET("/api/auth/check-daily-auth", func(c *core.RequestEvent) error {
			deviceID := strings.TrimSpace(c.Request.URL.Query().Get("device_id"))
			cycle := strings.TrimSpace(c.Request.URL.Query().Get("cycle"))

			if cycle == "" {
				cycle = getWorkdayCycleKey(time.Now())
			}

			// Check auth user if available
			var userID string
			authRecord := c.Auth
			if authRecord != nil {
				userID = authRecord.Id
			}

			deviceAuthMu.RLock()
			authCycleByDevice := deviceAuthMap[deviceID]
			authCycleByUser := ""
			if userID != "" {
				authCycleByUser = deviceAuthMap[userID]
			}
			deviceAuthMu.RUnlock()

			isAuthorized := (deviceID != "" && authCycleByDevice == cycle) || (userID != "" && authCycleByUser == cycle)

			return c.JSON(http.StatusOK, map[string]interface{}{
				"authorized": isAuthorized,
				"cycle":      cycle,
				"device_id":  deviceID,
			})
		})

		return e.Next()
	})
}
