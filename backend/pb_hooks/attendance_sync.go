package pb_hooks

import (
	"errors"
	"fmt"

	"github.com/pocketbase/pocketbase/core"
)

func SetupAttendanceSyncHook(app core.App) {

	// FIX E: Pre-create hook \u2014 server-side last line of defense against duplicates.
	//
	// If two concurrent PB.create() calls race through the client-side lock
	// (e.g. due to a network retry or an unexpected concurrent sync), this hook
	// ensures the server rejects the second one with a descriptive error.
	//
	// The Flutter client's catch block in _syncAttendanceToPocketBase already
	// handles 400-class errors gracefully: it fetches the existing record and
	// continues \u2014 so this rejection has zero negative side-effects on the client.
	app.OnRecordCreateRequest("attendance").BindFunc(func(e *core.RecordRequestEvent) error {
		userId := e.Record.GetString("user")
		if userId == "" {
			return e.Next()
		}

		attendanceDate := e.Record.GetDateTime("attendance_date").Time()
		if attendanceDate.IsZero() {
			return e.Next()
		}

		// Build a date-range filter for the same calendar day (UTC)
		dateStr := attendanceDate.UTC().Format("2006-01-02")
		filter := fmt.Sprintf(
			`user = "%s" && attendance_date >= "%s 00:00:00.000Z" && attendance_date <= "%s 23:59:59.999Z"`,
			userId, dateStr, dateStr,
		)

		existing, err := e.App.FindFirstRecordByFilter("attendance", filter)
		if err == nil && existing != nil {
			// Record already exists for this user+date \u2014 reject the duplicate
			return errors.New("attendance already marked for this date")
		}

		return e.Next()
	})

	// Post-create/update hook \u2014 sync on_duty status on the user record
	handler := func(e *core.RecordEvent) error {
		userId := e.Record.GetString("user")
		if userId == "" {
			return e.Next()
		}

		user, err := e.App.FindRecordById("users", userId)
		if err != nil {
			return e.Next()
		}

		checkOut := e.Record.GetString("check_out_time")

		// If check_out is empty, they are on duty.
		// If it has a value, they have finished their shift.
		isOnDuty := (checkOut == "")

		// Only update if it actually changes to prevent redundant saves
		if user.GetBool("on_duty") != isOnDuty {
			user.Set("on_duty", isOnDuty)
			_ = e.App.Save(user)
		}

		return e.Next()
	}

	app.OnRecordAfterCreateSuccess("attendance").BindFunc(handler)
	app.OnRecordAfterUpdateSuccess("attendance").BindFunc(handler)
}
