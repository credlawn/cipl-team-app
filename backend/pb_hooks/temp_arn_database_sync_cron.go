package pb_hooks

import (
	"fmt"
	"strings"
	"time"

	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase"
)

// SetupTempARNDatabaseSyncCron registers a manual-triggerable cron job for super admin
// to sync case_login (ARN, ARN Month) -> database, and adobe_dump (decision status/date) -> database.
func SetupTempARNDatabaseSyncCron(app *pocketbase.PocketBase) {
	// Scheduled for Jan 1 (won't auto-run unexpectedly, designed for manual execution from Super Admin UI)
	app.Cron().MustAdd("temp_arn_database_sync", "0 0 1 1 *", func() {
		app.Logger().Info("TempSyncCron: Starting ARN & Bank Status Database Sync")
		start := time.Now()

		runARNDatabaseSync(app)

		app.Logger().Info("TempSyncCron: Database Sync Finished", "duration", time.Since(start).String())
	})
}

// parseARNMonth extracts month string (e.g., 'Aug-26') from ARN numbers like 'D26H11078602S0VY'
func parseARNMonth(arn string) string {
	arn = strings.TrimSpace(arn)
	if len(arn) < 4 {
		return ""
	}

	// Example: D26H...
	// Year: 26
	// Month: H -> Aug
	yearStr := arn[1:3]
	monthChar := strings.ToUpper(string(arn[3]))

	monthMap := map[string]string{
		"A": "Jan",
		"B": "Feb",
		"C": "Mar",
		"D": "Apr",
		"E": "May",
		"F": "Jun",
		"G": "Jul",
		"H": "Aug",
		"I": "Sep",
		"J": "Oct",
		"K": "Nov",
		"L": "Dec",
	}

	monthName, exists := monthMap[monthChar]
	if !exists {
		return ""
	}

	return fmt.Sprintf("%s-%s", monthName, yearStr)
}

func runARNDatabaseSync(app *pocketbase.PocketBase) {
	// =========================================================================
	// STEP 1: Sync case_login -> database (new_arn_no, new_arn_month)
	// =========================================================================
	app.Logger().Info("TempSyncCron: Step 1 - Fetching case_login records")

	type CaseLoginRow struct {
		MobileNumber string `db:"mobile_number"`
		ArnNo        string `db:"arn_no"`
	}

	var caseLoginRows []CaseLoginRow
	err := app.DB().NewQuery(`
		SELECT mobile_number, arn_no
		FROM case_login
		WHERE mobile_number IS NOT NULL AND mobile_number != ''
		  AND arn_no IS NOT NULL AND arn_no != ''
		ORDER BY created ASC
	`).All(&caseLoginRows)

	if err != nil {
		app.Logger().Error("TempSyncCron: Failed to fetch case_login", "error", err)
		return
	}

	// Map latest ARN per mobile number
	mobileToArn := make(map[string]string)
	for _, row := range caseLoginRows {
		mob := strings.TrimSpace(row.MobileNumber)
		arn := strings.TrimSpace(row.ArnNo)
		if mob != "" && arn != "" {
			mobileToArn[mob] = arn
		}
	}

	app.Logger().Info("TempSyncCron: Unique mobiles with ARN in case_login", "count", len(mobileToArn))

	step1Updated := 0
	for mob, arn := range mobileToArn {
		arnMonth := parseARNMonth(arn)

		res, updateErr := app.DB().NewQuery(`
			UPDATE database
			SET new_arn_no = {:arn},
			    new_arn_month = {:month}
			WHERE mobile_no = {:mobile}
		`).Bind(dbx.Params{
			"arn":    arn,
			"month":  arnMonth,
			"mobile": mob,
		}).Execute()

		if updateErr == nil && res != nil {
			rowsAffected, _ := res.RowsAffected()
			if rowsAffected > 0 {
				step1Updated += int(rowsAffected)
			}
		}
	}

	app.Logger().Info("TempSyncCron: Step 1 Complete", "database_records_updated", step1Updated)

	// =========================================================================
	// STEP 2: Sync adobe_dump -> database (new_bank_status, new_bank_status_date)
	// =========================================================================
	app.Logger().Info("TempSyncCron: Step 2 - Fetching adobe_dump records")

	type AdobeDumpRow struct {
		ArnNo             string `db:"arn_no"`
		FinalDecision     string `db:"final_decision"`
		FinalDecisionDate string `db:"final_decision_date"`
	}

	var adobeRows []AdobeDumpRow
	err = app.DB().NewQuery(`
		SELECT arn_no, final_decision, final_decision_date
		FROM adobe_dump
		WHERE arn_no IS NOT NULL AND arn_no != ''
		ORDER BY created ASC
	`).All(&adobeRows)

	if err != nil {
		app.Logger().Error("TempSyncCron: Failed to fetch adobe_dump", "error", err)
		return
	}

	// Map latest decision per ARN
	type DecisionData struct {
		Status string
		Date   string
	}
	arnToDecision := make(map[string]DecisionData)

	for _, row := range adobeRows {
		arn := strings.TrimSpace(row.ArnNo)
		if arn != "" {
			arnToDecision[arn] = DecisionData{
				Status: strings.TrimSpace(row.FinalDecision),
				Date:   strings.TrimSpace(row.FinalDecisionDate),
			}
		}
	}

	app.Logger().Info("TempSyncCron: Unique ARNs in adobe_dump", "count", len(arnToDecision))

	// Check if new_bank_status_date column exists in database table
	type ColumnInfo struct {
		Name string `db:"name"`
	}
	var columns []ColumnInfo
	_ = app.DB().NewQuery("PRAGMA table_info(database)").All(&columns)

	hasDateCol := false
	for _, col := range columns {
		if col.Name == "new_bank_status_date" {
			hasDateCol = true
			break
		}
	}

	step2Updated := 0
	for arn, dec := range arnToDecision {
		var query *dbx.Query
		if hasDateCol {
			query = app.DB().NewQuery(`
				UPDATE database
				SET new_bank_status = {:status},
				    new_bank_status_date = {:status_date}
				WHERE new_arn_no = {:arn}
			`).Bind(dbx.Params{
				"status":      dec.Status,
				"status_date": dec.Date,
				"arn":         arn,
			})
		} else {
			query = app.DB().NewQuery(`
				UPDATE database
				SET new_bank_status = {:status}
				WHERE new_arn_no = {:arn}
			`).Bind(dbx.Params{
				"status": dec.Status,
				"arn":    arn,
			})
		}

		res, updateErr := query.Execute()
		if updateErr == nil && res != nil {
			rowsAffected, _ := res.RowsAffected()
			if rowsAffected > 0 {
				step2Updated += int(rowsAffected)
			}
		}
	}

	app.Logger().Info("TempSyncCron: Step 2 Complete",
		"database_records_updated", step2Updated,
		"included_date_column", hasDateCol,
	)
}
