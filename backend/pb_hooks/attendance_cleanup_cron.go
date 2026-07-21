package pb_hooks

import (
	"os"
	"path/filepath"
	"time"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

// SetupAttendanceCleanupCron sets up a daily cron at 1:30 AM IST (20:00 UTC).
// Task 1: Flag records older than 60 days with remove_data = true.
// Task 2: Fix attendance_date stored at midnight (00:00:00) → noon (12:00:00 UTC).
// Task 3: Remove duplicate records for same employee_code + date, keeping the best record.
func SetupAttendanceCleanupCron(app *pocketbase.PocketBase) {
	// 1:30 AM IST = 20:00 UTC
	app.Cron().MustAdd("attendance_cleanup", "0 20 * * *", func() {
		app.Logger().Info("Cron: Starting Attendance Cleanup (1:30 AM IST)")

		records, err := app.FindRecordsByFilter("attendance", "1=1", "", 0, 0)
		if err != nil {
			app.Logger().Error("Attendance Cleanup: Failed to fetch records", "error", err)
			return
		}

		now := time.Now().UTC()
		cutoff := now.AddDate(0, 0, -60)

		noonFixCount := 0
		flaggedCount := 0
		deletedCount := 0
		orphanFixCount := 0

		// ─────────────────────────────────────────────────────────────
		// Task 0: Clear broken selfie references (file missing on disk)
		// ─────────────────────────────────────────────────────────────
		collectionId := ""
		if len(records) > 0 {
			collectionId = records[0].Collection().Id
		}
		if collectionId != "" {
			for _, rec := range records {
				orphanModified := false

				// Check check_in_selfie
				if selfie := rec.GetString("check_in_selfie"); selfie != "" {
					filePath := filepath.Join(app.DataDir(), "storage", collectionId, rec.Id, selfie)
					if _, err := os.Stat(filePath); os.IsNotExist(err) {
						rec.Set("check_in_selfie", "")
						orphanModified = true
					}
				}

				// Check check_out_selfie
				if selfie := rec.GetString("check_out_selfie"); selfie != "" {
					filePath := filepath.Join(app.DataDir(), "storage", collectionId, rec.Id, selfie)
					if _, err := os.Stat(filePath); os.IsNotExist(err) {
						rec.Set("check_out_selfie", "")
						orphanModified = true
					}
				}

				if orphanModified {
					if err := app.Save(rec); err == nil {
						orphanFixCount++
					} else {
						app.Logger().Error("Attendance Cleanup: Failed to clear orphan selfie",
							"id", rec.Id, "error", err)
					}
				}
			}
		}

		// ─────────────────────────────────────────────────────────────
		// Task 1 + 2: Fix midnight → noon AND flag old records
		// ─────────────────────────────────────────────────────────────
		for _, rec := range records {
			attendanceTime := rec.GetDateTime("attendance_date").Time()
			if attendanceTime.IsZero() {
				continue
			}
			attendanceUTC := attendanceTime.UTC()
			modified := false

			// Task 2: Fix midnight → noon
			if attendanceUTC.Hour() == 0 && attendanceUTC.Minute() == 0 && attendanceUTC.Second() == 0 {
				noon := time.Date(
					attendanceUTC.Year(), attendanceUTC.Month(), attendanceUTC.Day(),
					12, 0, 0, 0, time.UTC,
				)
				rec.Set("attendance_date", noon)
				modified = true
				noonFixCount++
			}

			// Task 1: Flag records older than 60 days
			if attendanceUTC.Before(cutoff) && !rec.GetBool("remove_data") {
				rec.Set("remove_data", true)
				modified = true
				flaggedCount++
			}

			if modified {
				if err := app.Save(rec); err != nil {
					app.Logger().Error("Attendance Cleanup: Failed to save record",
						"id", rec.Id, "error", err)
				}
			}
		}

		// ─────────────────────────────────────────────────────────────
		// Task 3: Duplicate removal — same employee_code + date-part
		// ─────────────────────────────────────────────────────────────
		type dupKey struct {
			empCode string
			year    int
			month   time.Month
			day     int
		}

		grouped := make(map[dupKey][]*core.Record)
		for _, rec := range records {
			empCode := rec.GetString("employee_code")
			if empCode == "" {
				continue
			}
			t := rec.GetDateTime("attendance_date").Time().UTC()
			if t.IsZero() {
				continue
			}
			key := dupKey{empCode: empCode, year: t.Year(), month: t.Month(), day: t.Day()}
			grouped[key] = append(grouped[key], rec)
		}

		for _, group := range grouped {
			if len(group) <= 1 {
				continue
			}

			// Pick the winner using priority:
			//   1. Has check_out beats no check_out
			//   2. Same level → earlier check_in_time wins
			winner := group[0]
			for _, rec := range group[1:] {
				winnerHasOut := winner.GetString("check_out_time") != ""
				recHasOut := rec.GetString("check_out_time") != ""

				if recHasOut && !winnerHasOut {
					// rec is more complete → becomes winner
					winner = rec
					continue
				}
				if winnerHasOut && !recHasOut {
					// current winner is more complete → keep it
					continue
				}

				// Same level (both have out, or both have only in)
				// → earlier check_in wins
				winnerCheckIn := winner.GetDateTime("check_in_time").Time()
				recCheckIn := rec.GetDateTime("check_in_time").Time()
				if !recCheckIn.IsZero() && recCheckIn.Before(winnerCheckIn) {
					winner = rec
				}
			}

			// Delete all non-winners
			for _, rec := range group {
				if rec.Id == winner.Id {
					continue
				}
				if err := app.Delete(rec); err == nil {
					deletedCount++
				} else {
					app.Logger().Error("Attendance Cleanup: Failed to delete duplicate",
						"id", rec.Id, "error", err)
				}
			}
		}

		app.Logger().Info("Cron: Attendance Cleanup Finished",
			"total_checked", len(records),
			"orphan_selfies_cleared", orphanFixCount,
			"noon_fixed", noonFixCount,
			"old_records_flagged", flaggedCount,
			"duplicates_deleted", deletedCount,
		)
	})
}
