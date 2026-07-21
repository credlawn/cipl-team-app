package portal

import (
	"net/http"
	"time"

	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

func SetupOverviewAPI(app *pocketbase.PocketBase) {
	app.OnServe().BindFunc(func(e *core.ServeEvent) error {
		e.Router.GET("/api/portal/overview", handleOverview)
		e.Router.GET("/api/portal/overview/employees", handleEmployees)
		return e.Next()
	})
}

type overviewCount struct {
	IPA int `db:"ipa" json:"ipa"`
	IPD int `db:"ipd" json:"ipd"`
}

type overviewResponse struct {
	Today        overviewCount `json:"today"`
	Yesterday    overviewCount `json:"yesterday"`
	Change       overviewCount `json:"change"`
	TodayPct     float64       `json:"today_pct"`
	YesPct       float64       `json:"yes_pct"`
	ChangePct    float64       `json:"change_pct"`
	ZeroIPA      int           `json:"zero_ipa"`
	CheckedIn    int           `json:"checked_in"`
	AboveAvgIPD  int           `json:"above_avg_ipd"`
	BelowAvgIPA  int           `json:"below_avg_ipa"`
}

type employeeRow struct {
	EmployeeCode string  `db:"employee_code"`
	IPACount     int     `db:"ipa_count"`
	IPDCount     int     `db:"ipd_count"`
}

type employeeDetailRow struct {
	EmployeeCode string  `db:"employee_code" json:"employee_code"`
	EmployeeName string  `db:"employee_name" json:"employee_name"`
	TodayIPA     int     `db:"ipa_count" json:"today_ipa"`
	TodayIPD     int     `db:"ipd_count" json:"today_ipd"`
	YesIPA       int     `db:"yes_ipa_count" json:"yes_ipa"`
	YesIPD       int     `db:"yes_ipd_count" json:"yes_ipd"`
}

type employeesResponse struct {
	Employees   []employeeDetailRow `json:"employees"`
	CheckedIn   int                 `json:"checked_in"`
	AvgIPA      float64             `json:"avg_ipa"`
	AvgIPD      float64             `json:"avg_ipd"`
	ZeroIPA     int                 `json:"zero_ipa"`
	BelowAvgIPA int                 `json:"below_avg_ipa"`
	AboveAvgIPD int                 `json:"above_avg_ipd"`
}

func handleOverview(c *core.RequestEvent) error {
	info, _ := c.RequestInfo()
	if info.Auth == nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"error": "Unauthorized"})
	}
	if info.Auth.GetBool("disabled") {
		return c.JSON(http.StatusForbidden, map[string]string{"error": "Account disabled"})
	}

	now := time.Now().In(time.FixedZone("IST", 5*60*60+30*60))
	todayStartIST := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())
	todayEndIST := now

	// Convert to UTC for comparison (lead_status_date is stored in UTC)
	todayStartUTC := todayStartIST.UTC()
	todayEndUTC := todayEndIST.UTC()

	yesterdayStartUTC := todayStartUTC.AddDate(0, 0, -1)
	yesterdayEndUTC := todayEndUTC.AddDate(0, 0, -1)

	fmtStart := func(t time.Time) string { return t.Format("2006-01-02 15:04:05.000Z") }

	// Existing IPA/IPD counts
	query := `
		SELECT
			COALESCE(SUM(CASE WHEN lead_status = 'IP Approved' THEN 1 ELSE 0 END), 0) as ipa,
			COALESCE(SUM(CASE WHEN lead_status = 'IP Decline' THEN 1 ELSE 0 END), 0) as ipd
		FROM case_login
		WHERE lead_status_date >= {:start} AND lead_status_date < {:end}
	`

	var today overviewCount
	err := c.App.DB().NewQuery(query).
		Bind(dbx.Params{"start": fmtStart(todayStartUTC), "end": fmtStart(todayEndUTC)}).
		One(&today)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}

	var yesterday overviewCount
	err = c.App.DB().NewQuery(query).
		Bind(dbx.Params{"start": fmtStart(yesterdayStartUTC), "end": fmtStart(yesterdayEndUTC)}).
		One(&yesterday)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}

	// Employee-level query for zero_ipa, checked_in, above_avg_ipd
	todayDateStr := todayStartIST.Format("2006-01-02")
	empQuery := `
		SELECT u.employee_code,
			COALESCE(ipa.ipa_count, 0) as ipa_count,
			COALESCE(ipd.ipd_count, 0) as ipd_count
		FROM users u
		INNER JOIN attendance a ON u.employee_code = a.employee_code
		LEFT JOIN (
			SELECT employee_code, COUNT(*) as ipa_count
			FROM case_login
			WHERE lead_status = 'IP Approved'
			  AND lead_status_date >= {:todayStart}
			  AND lead_status_date < {:todayEnd}
			GROUP BY employee_code
		) ipa ON u.employee_code = ipa.employee_code
		LEFT JOIN (
			SELECT employee_code, COUNT(*) as ipd_count
			FROM case_login
			WHERE lead_status = 'IP Decline'
			  AND lead_status_date >= {:todayStart}
			  AND lead_status_date < {:todayEnd}
			GROUP BY employee_code
		) ipd ON u.employee_code = ipd.employee_code
		WHERE LOWER(u.role) = 'employee'
		  AND REPLACE(LOWER(u.vertical), ' ', '') LIKE '%creditcard%'
		  AND u.disabled = false
		  AND (a.check_in_time IS NOT NULL AND a.check_in_time != '')
		  AND a.attendance_date LIKE '` + todayDateStr + `%'
	`

	var rows []employeeRow
	err = c.App.DB().NewQuery(empQuery).
		Bind(dbx.Params{
			"todayStart": fmtStart(todayStartUTC),
			"todayEnd":   fmtStart(todayEndUTC),
		}).
		All(&rows)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}

	checkedIn := len(rows)
	zeroIPA := 0
	totalIPA := 0
	totalIPD := 0
	for _, r := range rows {
		if r.IPACount == 0 {
			zeroIPA++
		}
		totalIPA += r.IPACount
		totalIPD += r.IPDCount
	}

	var avgIPA, avgIPD float64
	if checkedIn > 0 {
		avgIPA = float64(totalIPA) / float64(checkedIn)
		avgIPD = float64(totalIPD) / float64(checkedIn)
	}

	belowAvgIPA := 0
	aboveAvgIPD := 0
	for _, r := range rows {
		if r.IPACount > 0 && float64(r.IPACount) < avgIPA {
			belowAvgIPA++
		}
		if float64(r.IPDCount) > avgIPD {
			aboveAvgIPD++
		}
	}

	totalToday := today.IPA + today.IPD
	totalYes := yesterday.IPA + yesterday.IPD

	var todayPct, yesPct, changePct float64
	if totalToday > 0 {
		todayPct = float64(today.IPA) / float64(totalToday) * 100
	}
	if totalYes > 0 {
		yesPct = float64(yesterday.IPA) / float64(totalYes) * 100
	}
	if totalYes > 0 {
		changePct = todayPct - yesPct
	} else if totalToday > 0 {
		changePct = todayPct
	}

	resp := overviewResponse{
		Today:     overviewCount{IPA: today.IPA, IPD: today.IPD},
		Yesterday: overviewCount{IPA: yesterday.IPA, IPD: yesterday.IPD},
		Change: overviewCount{
			IPA: today.IPA - yesterday.IPA,
			IPD: today.IPD - yesterday.IPD,
		},
		TodayPct:    todayPct,
		YesPct:      yesPct,
		ChangePct:   changePct,
		ZeroIPA:     zeroIPA,
		CheckedIn:   checkedIn,
		AboveAvgIPD: aboveAvgIPD,
		BelowAvgIPA: belowAvgIPA,
	}

	return c.JSON(http.StatusOK, resp)
}

func handleEmployees(c *core.RequestEvent) error {
	info, _ := c.RequestInfo()
	if info.Auth == nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"error": "Unauthorized"})
	}
	if info.Auth.GetBool("disabled") {
		return c.JSON(http.StatusForbidden, map[string]string{"error": "Account disabled"})
	}

	now := time.Now().In(time.FixedZone("IST", 5*60*60+30*60))
	todayStartIST := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())
	todayEndIST := now

	todayStartUTC := todayStartIST.UTC()
	todayEndUTC := todayEndIST.UTC()
	yesterdayStartUTC := todayStartUTC.AddDate(0, 0, -1)
	yesterdayEndUTC := todayEndUTC.AddDate(0, 0, -1)

	fmtStart := func(t time.Time) string { return t.Format("2006-01-02 15:04:05.000Z") }
	todayDateStr := todayStartIST.Format("2006-01-02")

	empQuery := `
		SELECT u.employee_code, u.employee_name,
			COALESCE(today_ipa.cnt, 0) as ipa_count,
			COALESCE(today_ipd.cnt, 0) as ipd_count,
			COALESCE(yes_ipa.cnt, 0) as yes_ipa_count,
			COALESCE(yes_ipd.cnt, 0) as yes_ipd_count
		FROM users u
		INNER JOIN attendance a ON u.employee_code = a.employee_code
		LEFT JOIN (
			SELECT employee_code, COUNT(*) as cnt
			FROM case_login
			WHERE lead_status = 'IP Approved'
			  AND lead_status_date >= {:todayStart}
			  AND lead_status_date < {:todayEnd}
			GROUP BY employee_code
		) today_ipa ON u.employee_code = today_ipa.employee_code
		LEFT JOIN (
			SELECT employee_code, COUNT(*) as cnt
			FROM case_login
			WHERE lead_status = 'IP Decline'
			  AND lead_status_date >= {:todayStart}
			  AND lead_status_date < {:todayEnd}
			GROUP BY employee_code
		) today_ipd ON u.employee_code = today_ipd.employee_code
		LEFT JOIN (
			SELECT employee_code, COUNT(*) as cnt
			FROM case_login
			WHERE lead_status = 'IP Approved'
			  AND lead_status_date >= {:yesStart}
			  AND lead_status_date < {:yesEnd}
			GROUP BY employee_code
		) yes_ipa ON u.employee_code = yes_ipa.employee_code
		LEFT JOIN (
			SELECT employee_code, COUNT(*) as cnt
			FROM case_login
			WHERE lead_status = 'IP Decline'
			  AND lead_status_date >= {:yesStart}
			  AND lead_status_date < {:yesEnd}
			GROUP BY employee_code
		) yes_ipd ON u.employee_code = yes_ipd.employee_code
		WHERE LOWER(u.role) = 'employee'
		  AND REPLACE(LOWER(u.vertical), ' ', '') LIKE '%creditcard%'
		  AND u.disabled = false
		  AND (a.check_in_time IS NOT NULL AND a.check_in_time != '')
		  AND a.attendance_date LIKE '` + todayDateStr + `%'
	`

	var rows []employeeDetailRow
	err := c.App.DB().NewQuery(empQuery).
		Bind(dbx.Params{
			"todayStart": fmtStart(todayStartUTC),
			"todayEnd":   fmtStart(todayEndUTC),
			"yesStart":   fmtStart(yesterdayStartUTC),
			"yesEnd":     fmtStart(yesterdayEndUTC),
		}).
		All(&rows)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}

	checkedIn := len(rows)
	totalIPA := 0
	totalIPD := 0
	zeroIPA := 0
	for _, r := range rows {
		if r.TodayIPA == 0 {
			zeroIPA++
		}
		totalIPA += r.TodayIPA
		totalIPD += r.TodayIPD
	}

	var avgIPA, avgIPD float64
	if checkedIn > 0 {
		avgIPA = float64(totalIPA) / float64(checkedIn)
		avgIPD = float64(totalIPD) / float64(checkedIn)
	}

	belowAvgIPA := 0
	aboveAvgIPD := 0
	for _, r := range rows {
		if r.TodayIPA > 0 && float64(r.TodayIPA) < avgIPA {
			belowAvgIPA++
		}
		if float64(r.TodayIPD) > avgIPD {
			aboveAvgIPD++
		}
	}

	resp := employeesResponse{
		Employees:   rows,
		CheckedIn:   checkedIn,
		AvgIPA:      avgIPA,
		AvgIPD:      avgIPD,
		ZeroIPA:     zeroIPA,
		BelowAvgIPA: belowAvgIPA,
		AboveAvgIPD: aboveAvgIPD,
	}

	return c.JSON(http.StatusOK, resp)
}
