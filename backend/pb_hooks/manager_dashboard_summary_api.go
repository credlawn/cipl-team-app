package pb_hooks

import (
	"fmt"
	"net/http"
	"strings"
	"sync"
	"time"

	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

// SetupManagerDashboardSummaryAPI registers the unified manager dashboard summary endpoint
func SetupManagerDashboardSummaryAPI(app *pocketbase.PocketBase) {
	app.OnServe().BindFunc(func(e *core.ServeEvent) error {
		e.Router.GET("/api/manager/dashboard-summary", handleManagerDashboardSummary)
		return e.Next()
	})
}

// ManagerDashboardSummaryResponse is the single consolidated payload for Manager Dashboard
type ManagerDashboardSummaryResponse struct {
	Date       string               `json:"date"`
	Overview   OverviewStats        `json:"overview"`
	DataUsage  DataUsageStats       `json:"data_usage"`
	Attendance AttendanceStats      `json:"attendance"`
	Calls      CallActivityStats    `json:"calls"`
	Tasks      ManagerTaskCardStats `json:"tasks"`
}

type OverviewStats struct {
	IPA        int     `json:"ipa"`
	IPD        int     `json:"ipd"`
	Total      int     `json:"total"`
	Percentage float64 `json:"ipa_percentage"`
}

type DataUsageStats struct {
	NewLeads          int     `json:"new_leads"`
	Worked            int     `json:"worked"`
	Used              int     `json:"used"`
	Productivity      float64 `json:"productivity"`
	ZeroNewLeadsCount int     `json:"zero_new_leads_count"`
}

type AttendanceStats struct {
	Active  int `json:"active"`
	Present int `json:"present"`
	Absent  int `json:"absent"`
	Late    int `json:"late"`
}

type CallActivityStats struct {
	PresentCount  int `json:"present_count"`
	TotalCalls    int `json:"total_calls"`
	TotalDuration int `json:"total_duration"`
	AvgDuration   int `json:"avg_duration"`
}

type ManagerTaskCardStats struct {
	VKYC            int `json:"vkyc"`
	BKYC            int `json:"bkyc"`
	Activation      int `json:"activation"`
	Cards           int `json:"cards"`
	OverdueTrainees int `json:"overdue_trainees"`
}

func parseFlexTime(timeStr string) (time.Time, error) {
	clean := strings.TrimSpace(timeStr)
	clean = strings.ReplaceAll(clean, "T", " ")
	clean = strings.TrimSuffix(clean, "Z")

	formats := []string{
		"2006-01-02 15:04:05.000",
		"2006-01-02 15:04:05.000000",
		"2006-01-02 15:04:05",
		"2006-01-02 15:04",
		"2006-01-02",
	}

	for _, f := range formats {
		if t, err := time.ParseInLocation(f, clean, time.UTC); err == nil {
			return t, nil
		}
	}

	return time.Parse(time.RFC3339, timeStr)
}

func handleManagerDashboardSummary(c *core.RequestEvent) error {
	// 1. Auth check
	info, _ := c.RequestInfo()
	if info.Auth == nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"error": "Unauthorized"})
	}

	if info.Auth.GetBool("disabled") {
		return c.JSON(http.StatusForbidden, map[string]string{"error": "Account disabled"})
	}

	// 2. Parse IST target date
	istLocation, err := time.LoadLocation("Asia/Kolkata")
	if err != nil {
		istLocation = time.FixedZone("IST", 5*3600+1800)
	}

	dateStr := strings.TrimSpace(c.Request.URL.Query().Get("date"))
	var targetDate time.Time
	if dateStr == "" {
		targetDate = time.Now().In(istLocation)
	} else {
		targetDate, err = time.ParseInLocation("2006-01-02", dateStr, istLocation)
		if err != nil {
			return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid date format. Use YYYY-MM-DD"})
		}
	}

	todayISTStr := targetDate.Format("2006-01-02")
	startOfDayIST := time.Date(targetDate.Year(), targetDate.Month(), targetDate.Day(), 0, 0, 0, 0, istLocation)
	endOfDayIST := startOfDayIST.Add(24 * time.Hour)

	startOfDayUTC := startOfDayIST.UTC()
	endOfDayUTC := endOfDayIST.UTC()

	startOfDayUTCStr := startOfDayUTC.Format("2006-01-02 15:04:05")
	endOfDayUTCStr := endOfDayUTC.Format("2006-01-02 15:04:05")
	currentMonthStr := fmt.Sprintf("%s-%02d", targetDate.Format("Jan"), targetDate.Year()%100)

	fourDaysAgo := targetDate.AddDate(0, 0, -4)
	traineeLimitStr := fmt.Sprintf("%04d-%02d-%02d 23:59:59", fourDaysAgo.Year(), fourDaysAgo.Month(), fourDaysAgo.Day())

	// Data containers for parallel fetching
	type OverviewRow struct {
		IPA int `db:"ipa"`
		IPD int `db:"ipd"`
	}
	var overviewRow OverviewRow

	type ActiveUserRow struct {
		EmployeeCode string `db:"employee_code"`
	}
	var activeUsers []ActiveUserRow

	type AttendanceRow struct {
		EmployeeCode string `db:"employee_code"`
		CheckInTime  string `db:"check_in_time"`
	}
	var attendanceRows []AttendanceRow

	type PivotRow struct {
		EmployeeCode  string `db:"employee_code"`
		NewCount      int    `db:"new_count"`
		TotalActivity int    `db:"total_activity"`
		CNRCount      int    `db:"cnr_count"`
		DeniedCount   int    `db:"denied_count"`
		CalledCount   int    `db:"called_count"`
	}
	var pivotRows []PivotRow

	type CallSummaryRow struct {
		CallCount     int `db:"call_count"`
		TotalDuration int `db:"total_duration"`
	}
	var callRow CallSummaryRow

	type TaskCountsRow struct {
		VKYC       int `db:"vkyc"`
		BKYC       int `db:"bkyc"`
		Activation int `db:"activation"`
		Cards      int `db:"cards"`
	}
	var tcRow TaskCountsRow

	type TraineeRow struct {
		Count int `db:"count"`
	}
	var traineeRow TraineeRow

	// -------------------------------------------------------------
	// RUN ALL 5 SECTIONS CONCURRENTLY USING GOROUTINES ON MULTI-CORE CPU
	// -------------------------------------------------------------
	var wg sync.WaitGroup
	wg.Add(5)

	// Goroutine 1: Overview Stats (IPA & IPD)
	go func() {
		defer wg.Done()
		_ = c.App.DB().NewQuery(`
			SELECT 
				COUNT(CASE WHEN lead_status = 'IP Approved' THEN 1 END) as ipa,
				COUNT(CASE WHEN lead_status = 'IP Decline' THEN 1 END) as ipd
			FROM case_login
			WHERE date(lead_status_date) = {:today} OR lead_status_date LIKE {:todayPrefix}
		`).Bind(dbx.Params{
			"today":       todayISTStr,
			"todayPrefix": todayISTStr + "%",
		}).One(&overviewRow)
	}()

	// Goroutine 2: Attendance & Active Users
	go func() {
		defer wg.Done()
		_ = c.App.DB().
			Select("employee_code").
			From("users").
			Where(GetActiveEmployeesFilter()).
			All(&activeUsers)

		_ = c.App.DB().NewQuery(`
			SELECT employee_code, check_in_time
			FROM attendance
			WHERE (date(attendance_date) = {:today} OR attendance_date LIKE {:todayPrefix})
			  AND check_in_time IS NOT NULL AND check_in_time != ''
		`).Bind(dbx.Params{
			"today":       todayISTStr,
			"todayPrefix": todayISTStr + "%",
		}).All(&attendanceRows)
	}()

	// Goroutine 3: Data Usage (Leads Pivot)
	go func() {
		defer wg.Done()
		_ = c.App.DB().
			Select(
				"u.employee_code",
				"(SELECT COUNT(id) FROM leads WHERE employee_code = u.employee_code AND lead_status = 'New') as new_count",
				"COUNT(CASE WHEN l.lead_status IS NOT NULL AND l.lead_status != 'New' THEN 1 END) as total_activity",
				"COUNT(CASE WHEN l.lead_status IN ('CNR', 'Voicemail') THEN 1 END) as cnr_count",
				"COUNT(CASE WHEN l.lead_status = 'Denied' THEN 1 END) as denied_count",
				"COUNT(CASE WHEN l.lead_status = 'Called' THEN 1 END) as called_count",
			).
			From("users u").
			LeftJoin("leads l", dbx.And(
				dbx.NewExp("u.employee_code = l.employee_code"),
				dbx.NewExp("l.lead_status_date >= {:startDate}", dbx.Params{"startDate": startOfDayUTCStr}),
				dbx.NewExp("l.lead_status_date < {:endDate}", dbx.Params{"endDate": endOfDayUTCStr}),
			)).
			Where(GetActiveEmployeesFilter()).
			GroupBy("u.employee_code").
			All(&pivotRows)
	}()

	// Goroutine 4: Call Activity
	go func() {
		defer wg.Done()
		_ = c.App.DB().NewQuery(`
			SELECT 
				COUNT(*) as call_count,
				COALESCE(SUM(call_duration), 0) as total_duration
			FROM (
				SELECT 
					phone_number,
					MAX(call_duration) as call_duration
				FROM call_logs
				WHERE call_timestamp >= {:start} AND call_timestamp < {:end} AND call_duration > 0
				GROUP BY 
					phone_number,
					strftime('%Y-%m-%d %H:%M:%S', call_timestamp),
					call_duration,
					employee_code
			)
		`).Bind(dbx.Params{
			"start": startOfDayUTCStr,
			"end":   endOfDayUTCStr,
		}).One(&callRow)
	}()

	// Goroutine 5: Task Cards (VKYC, BKYC, Activation, Cards, Trainees)
	go func() {
		defer wg.Done()
		_ = c.App.DB().NewQuery(`
			SELECT 
				(SELECT COUNT(*) FROM vkyc WHERE bank_vkyc_status LIKE '%pending%' AND vkyc_expiry_date >= {:todayDate} AND (remove_data = 0 OR remove_data IS NULL)) as vkyc,
				(SELECT COUNT(*) FROM bkyc WHERE bank_status LIKE '%pending%' AND (remove_data = 0 OR remove_data IS NULL)) as bkyc,
				(SELECT COUNT(*) FROM activation WHERE bank_status LIKE '%inactive%' AND (remove_data = 0 OR remove_data IS NULL)) as activation,
				(SELECT COUNT(*) FROM bank_approved_cards WHERE decision_month = {:month}) as cards
		`).Bind(dbx.Params{
			"todayDate": startOfDayUTCStr,
			"month":     currentMonthStr,
		}).One(&tcRow)

		_ = c.App.DB().NewQuery(`
			SELECT COUNT(*) as count 
			FROM users 
			WHERE disabled = 0 AND designation = 'Trainee' AND (no_atn = 0 OR no_atn IS NULL) AND date_of_joining <= {:limit}
		`).Bind(dbx.Params{
			"limit": traineeLimitStr,
		}).One(&traineeRow)
	}()

	// Wait for all 5 goroutines to complete in parallel
	wg.Wait()

	// -------------------------------------------------------------
	// AGGREGATE RESULTS IN MEMORY (< 0.1ms)
	// -------------------------------------------------------------
	response := ManagerDashboardSummaryResponse{
		Date: todayISTStr,
	}

	// 1. Overview
	totalIp := overviewRow.IPA + overviewRow.IPD
	var ipaPct float64
	if totalIp > 0 {
		ipaPct = float64(overviewRow.IPA) / float64(totalIp) * 100.0
	}
	response.Overview = OverviewStats{
		IPA:        overviewRow.IPA,
		IPD:        overviewRow.IPD,
		Total:      totalIp,
		Percentage: ipaPct,
	}

	// 2. Attendance
	activeEmpSet := make(map[string]bool)
	for _, u := range activeUsers {
		activeEmpSet[u.EmployeeCode] = true
	}
	totalActiveCount := len(activeUsers)

	presentEmpSet := make(map[string]bool)
	lateCount := 0

	for _, att := range attendanceRows {
		empCode := strings.TrimSpace(att.EmployeeCode)
		if empCode == "" || !activeEmpSet[empCode] {
			continue
		}

		if !presentEmpSet[empCode] {
			presentEmpSet[empCode] = true

			// Parse check_in_time to check late (> 10:15 AM IST)
			if tUTC, err := parseFlexTime(att.CheckInTime); err == nil {
				tIST := tUTC.In(istLocation)
				hour := tIST.Hour()
				minute := tIST.Minute()
				if hour > 10 || (hour == 10 && minute > 15) {
					lateCount++
				}
			}
		}
	}

	presentCount := len(presentEmpSet)
	absentCount := totalActiveCount - presentCount
	if absentCount < 0 {
		absentCount = 0
	}

	response.Attendance = AttendanceStats{
		Active:  totalActiveCount,
		Present: presentCount,
		Absent:  absentCount,
		Late:    lateCount,
	}

	// 3. Data Usage & Zero Leads Badge
	var summaryNew, summaryActivity, summaryWorked, zeroNewLeadsPresentCount int

	for _, row := range pivotRows {
		summaryNew += row.NewCount
		summaryActivity += row.TotalActivity

		unproductive := row.CNRCount + row.DeniedCount + row.CalledCount
		worked := row.TotalActivity - unproductive
		if worked < 0 {
			worked = 0
		}
		summaryWorked += worked

		if presentEmpSet[row.EmployeeCode] && row.NewCount == 0 {
			zeroNewLeadsPresentCount++
		}
	}

	var prodPct float64
	if summaryActivity > 0 {
		prodPct = float64(summaryWorked) / float64(summaryActivity) * 100.0
	}

	response.DataUsage = DataUsageStats{
		NewLeads:          summaryNew,
		Worked:            summaryWorked,
		Used:              summaryActivity,
		Productivity:      prodPct,
		ZeroNewLeadsCount: zeroNewLeadsPresentCount,
	}

	// 4. Calls
	avgDuration := 0
	if callRow.CallCount > 0 {
		avgDuration = callRow.TotalDuration / callRow.CallCount
	}

	response.Calls = CallActivityStats{
		PresentCount:  presentCount,
		TotalCalls:    callRow.CallCount,
		TotalDuration: callRow.TotalDuration,
		AvgDuration:   avgDuration,
	}

	// 5. Tasks
	response.Tasks = ManagerTaskCardStats{
		VKYC:            tcRow.VKYC,
		BKYC:            tcRow.BKYC,
		Activation:      tcRow.Activation,
		Cards:           tcRow.Cards,
		OverdueTrainees: traineeRow.Count,
	}

	return c.JSON(http.StatusOK, response)
}
