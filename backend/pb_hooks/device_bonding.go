package pb_hooks

import (
	"strings"

	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
)

func SetupDeviceBonding(app core.App) {
	app.OnRecordAuthRequest("users").BindFunc(func(e *core.RecordAuthRequestEvent) error {
		// Realtime auth or internal server auth might not have an HTTP request attached
		if e.RequestEvent == nil || e.Request == nil {
			return e.Next()
		}

		// Bypass device binding for BH users logging in via admin portal
		if strings.ToLower(e.Record.GetString("role")) == "bh" {
			return e.Next()
		}

		// AuthRefresh is exempt from device header validation.
		// A valid JWT token is already proof that the user passed device bonding
		// at login time — requiring headers again on every refresh is redundant
		// and causes sync failures in clients that don't send headers on refresh.
		if strings.HasSuffix(e.Request.URL.Path, "/auth-refresh") {
			return e.Next()
		}

		deviceId := e.Request.Header.Get("X-Device-Id")
		deviceModel := e.Request.Header.Get("X-Device-Model")
		androidVersion := e.Request.Header.Get("X-Android-Version")

		// Restrict login to the mobile app
		if deviceId == "" {
			return apis.NewForbiddenError("Mobile Device ID is missing. Access is restricted to the official mobile app.", nil)
		}

		storedDeviceId := e.Record.GetString("device_id")

		if storedDeviceId == "" {
			// Scenario A: First time login - Bind the device
			e.Record.Set("device_id", deviceId)
			e.Record.Set("device_model", deviceModel)
			e.Record.Set("android_version", androidVersion)
			if err := e.App.Save(e.Record); err != nil {
				return err
			}
			return e.Next()
		}

		// Scenario B: Device is already bound
		if storedDeviceId != deviceId {
			return apis.NewForbiddenError("Your account is bonded to another device. Please contact HR/Admin to reset your device.", nil)
		}

		// Update OS version and model silently if they have changed (e.g., user updated their Android version)
		storedAndroidVersion := e.Record.GetString("android_version")
		storedDeviceModel := e.Record.GetString("device_model")
		
		if storedAndroidVersion != androidVersion || storedDeviceModel != deviceModel {
			e.Record.Set("android_version", androidVersion)
			e.Record.Set("device_model", deviceModel)
			_ = e.App.Save(e.Record)
		}

		return e.Next()
	})
}
