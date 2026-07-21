package pb_hooks

import (
	"net/http"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

// SetupInactiveRestoreCron sets up a cron job that runs on the 1st of every month at 2:00 AM IST
// (8:30 PM UTC on last day = 2 AM IST on 1st) to restore CNR/Denied records
// that were incorrectly marked inactive under old thresholds.
// Cron pattern: "30 20 28-31 * *" won't work cleanly for 1st. Using "0 20 L * *" is not standard.
// Standard approach: "30 20 1 * *" = 8:30 PM UTC on 1st = 2:00 AM IST on 1st (next day)
// Simpler: run at UTC 20:30 on day 1 of each month = IST 2:00 AM on day 2 of each month
// Better: "0 21 1 * *" = 9:00 PM UTC on 1st = 2:30 AM IST on 2nd
// Cleanest for IST 2 AM on 1st: run at UTC 20:30 on last day of previous month is complex
// Use: "30 20 1 * *" = 8:30 PM UTC on the 1st = 2:00 AM IST on the 1st
func SetupInactiveRestoreCron(app *pocketbase.PocketBase) {
	// Cron pattern: "30 20 1 * *"
	// = 8:30 PM UTC on the 1st of every month
	// = 2:00 AM IST on the 1st of every month
	app.Cron().MustAdd("inactive_restore", "30 20 1 * *", func() {
		app.Logger().Info("Inactive Restore Cron - STARTED")

		restored, skipped, errors := restoreInactiveLeads(app)

		app.Logger().Info("Inactive Restore Cron - COMPLETED",
			"restored", restored,
			"skipped", skipped,
			"errors", errors,
		)
	})

	// Manual trigger API — POST /api/admin/restore-inactive-leads
	// Only accessible by admin users
	app.OnServe().BindFunc(func(e *core.ServeEvent) error {
		e.Router.POST("/api/admin/restore-inactive-leads", func(c *core.RequestEvent) error {
			info, _ := c.RequestInfo()
			if info.Auth == nil {
				return c.JSON(http.StatusUnauthorized, map[string]string{"error": "Unauthorized"})
			}

			if info.Auth.GetString("role") != "admin" {
				return c.JSON(http.StatusForbidden, map[string]string{"error": "Admin access required"})
			}

			app.Logger().Info("Inactive Restore - Manual trigger by admin",
				"admin", info.Auth.GetString("employee_code"),
			)

			restored, skipped, errors := restoreInactiveLeads(app)

			return c.JSON(http.StatusOK, map[string]interface{}{
				"success":  true,
				"restored": restored,
				"skipped":  skipped,
				"errors":   errors,
				"message":  "Check server logs for detailed breakdown",
			})
		})
		return e.Next()
	})
}

// restoreInactiveLeads restores CNR/Denied records that were marked inactive
// under old thresholds but are within the new thresholds.
// New thresholds: denied_feedback_count <= 10 AND shuffle_count <= 15
// Returns: (restoredCount, skippedCount, errorCount)
func restoreInactiveLeads(app *pocketbase.PocketBase) (int, int, int) {
	const maxDeniedCount = 10 // New threshold (was 3)
	const maxShuffleCount = 15 // New threshold (was 4)

	// Fetch all inactive records with lead_status CNR or Denied
	type InactiveRecord struct {
		ID           string `db:"id"`
		MobileNo     string `db:"mobile_no"`
		LeadStatus   string `db:"lead_status"`
		ShuffleCount int    `db:"shuffle_count"`
	}

	var records []InactiveRecord
	err := app.DB().NewQuery(`
		SELECT id, mobile_no, lead_status, COALESCE(shuffle_count, 0) as shuffle_count
		FROM database
		WHERE 
			LOWER(data_status) = 'inactive'
			AND lead_status IN ('CNR', 'Denied')
	`).All(&records)

	if err != nil {
		app.Logger().Error("Inactive Restore - Failed to fetch inactive records", "error", err)
		return 0, 0, 1
	}

	app.Logger().Info("Inactive Restore - Total inactive CNR/Denied records found", "count", len(records))

	restoredCount := 0
	restoredCNR := 0
	restoredDenied := 0
	skippedCount := 0
	errorCount := 0

	for _, rec := range records {
		// Check shuffle_count threshold
		if rec.ShuffleCount > maxShuffleCount {
			skippedCount++
			continue
		}

		// Check denied feedback count for this mobile number
		var deniedCount struct {
			Count int `db:"count"`
		}
		err := app.DB().NewQuery(`
			SELECT COUNT(*) as count 
			FROM lead_feedback 
			WHERE mobile_no = {:mobile} AND lead_status = 'Denied'
		`).Bind(map[string]interface{}{
			"mobile": rec.MobileNo,
		}).One(&deniedCount)

		if err != nil {
			errorCount++
			continue
		}

		// Skip if denied count still exceeds new threshold
		if deniedCount.Count > maxDeniedCount {
			skippedCount++
			continue
		}

		// Eligible for restore — set data_status back to 'used'
		dbRecord, err := app.FindRecordById("database", rec.ID)
		if err != nil {
			errorCount++
			continue
		}

		dbRecord.Set("data_status", "used")

		if err := app.Save(dbRecord); err != nil {
			app.Logger().Error("Inactive Restore - Failed to save record",
				"mobile_no", rec.MobileNo,
				"error", err,
			)
			errorCount++
		} else {
			restoredCount++
			if rec.LeadStatus == "CNR" {
				restoredCNR++
			} else if rec.LeadStatus == "Denied" {
				restoredDenied++
			}
		}
	}

	// Final summary log — clearly visible in server logs
	app.Logger().Info("===== INACTIVE RESTORE SUMMARY =====",
		"total_inactive_checked", len(records),
		"CNR_restored", restoredCNR,
		"Denied_restored", restoredDenied,
		"total_restored", restoredCount,
		"skipped_exceed_threshold", skippedCount,
		"errors", errorCount,
	)

	return restoredCount, skippedCount, errorCount
}
