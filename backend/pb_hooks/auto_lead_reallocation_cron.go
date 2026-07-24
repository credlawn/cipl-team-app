package pb_hooks

import (
	"time"

	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

func SetupAutoLeadReallocationCron(app *pocketbase.PocketBase) {
	app.Cron().MustAdd("auto_lead_reallocation", "*/5 4-14 * * *", func() {
		allocated, skipped, errors := runAllocationCycle(app)

		if errors > 0 {
			app.Logger().Error("Auto Lead Reallocation completed with errors",
				"allocated", allocated,
				"skipped", skipped,
				"errors", errors,
			)
		}
	})
}

func runAllocationCycle(app *pocketbase.PocketBase) (int, int, int) {
	app.Logger().Info("Auto lead reallocation cycle started")

	updateLeadScores(app)

	employees, err := getEligibleEmployees(app)
	if err != nil {
		app.Logger().Error("Failed to fetch eligible employees", "error", err)
		return 0, 0, 1
	}

	if len(employees) == 0 {
		app.Logger().Info("No eligible employees found, skipping allocation")
		return 0, 0, 0
	}

	totalAllocated := 0
	totalSkipped := 0
	totalErrors := 0
	allocatedInCycle := make(map[string]bool)

	for _, emp := range employees {
		need := 6 - emp.NewLeadCount
		if need <= 0 {
			continue
		}

		leads, err := fetchLeadsForEmployee(app, emp.EmployeeCode, need)
		if err != nil {
			app.Logger().Error("Failed to fetch leads for employee", "code", emp.EmployeeCode, "error", err)
			totalErrors++
			continue
		}

		if len(leads) == 0 {
			app.Logger().Info("No leads available for employee", "code", emp.EmployeeCode)
			continue
		}

		a, s, e := allocateAll(app, leads, emp, allocatedInCycle)
		totalAllocated += a
		totalSkipped += s
		totalErrors += e

		app.Logger().Info("Employee allocation result",
			"employee_code", emp.EmployeeCode,
			"employee_name", emp.EmployeeName,
			"needed", need,
			"allocated", a)
	}

	app.Logger().Info("Auto lead reallocation cycle completed",
		"total_employees", len(employees),
		"total_allocated", totalAllocated,
		"total_skipped", totalSkipped,
		"total_errors", totalErrors)

	return totalAllocated, totalSkipped, totalErrors
}

func updateLeadScores(app *pocketbase.PocketBase) {
	_, err := app.DB().NewQuery(`
		UPDATE database 
		SET lead_score = (
			COALESCE((julianday('now') - julianday(lead_status_date)) * 24.0, 0)
			+ CASE WHEN lead_status = 'CNR' THEN 0.8 ELSE 0 END
			- (COALESCE(allocation_count, 0) * 0.3)
		)
		WHERE LOWER(data_status) = 'used'
		  AND lead_status IN ('CNR', 'Denied')
		  AND allocation_count >= 1
		  AND (no_reallocation IS NULL OR no_reallocation = false)
		  AND NOT EXISTS (
			SELECT 1 FROM custom_code_list 
			WHERE custom_code_list.custom_code = database.custom_code
			  AND custom_code_list.custom_code != ''
		)
	`).Execute()

	if err != nil {
		app.Logger().Error("Failed to update lead scores", "error", err)
	} else {
		app.Logger().Info("Lead scores updated successfully")
	}
}

type LeadInfo struct {
	ID           string `db:"id"`
	MobileNo     string `db:"mobile_no"`
	EmployeeCode string `db:"employee_code"`
}

func fetchLeadsForEmployee(app *pocketbase.PocketBase, empCode string, limit int) ([]LeadInfo, error) {
	query := `
		SELECT id, mobile_no, employee_code
		FROM database
		WHERE LOWER(data_status) = 'used'
		  AND lead_status IN ('CNR', 'Denied')
		  AND allocation_count >= 1
		  AND (no_reallocation IS NULL OR no_reallocation = false)
		  AND NOT EXISTS (
			SELECT 1 FROM custom_code_list 
			WHERE custom_code_list.custom_code = database.custom_code
			  AND custom_code_list.custom_code != ''
		)
		  AND id NOT IN (
			SELECT database_record_id FROM lead_allocation_history
			WHERE allocated_to_code = {:empCode}
		)
		ORDER BY lead_score DESC
		LIMIT {:limit}
	`

	var leads []LeadInfo
	err := app.DB().NewQuery(query).Bind(dbx.Params{
		"empCode": empCode,
		"limit":   limit,
	}).All(&leads)
	if err != nil {
		return nil, err
	}

	return leads, nil
}

func allocateAll(app *pocketbase.PocketBase, leads []LeadInfo, emp EmployeeInfo, allocatedInCycle map[string]bool) (int, int, int) {
	allocated := 0
	skipped := 0
	errors := 0

	for _, lead := range leads {
		if allocatedInCycle[lead.ID] {
			continue
		}
		allocatedInCycle[lead.ID] = true

		success, err := allocateSingleLead(app, lead, emp)
		if err != nil {
			errors++
		} else if success {
			allocated++
		} else {
			skipped++
		}
	}

	return allocated, skipped, errors
}

// EmployeeInfo holds employee information
type EmployeeInfo struct {
	EmployeeCode string `db:"employee_code"`
	EmployeeName string `db:"employee_name"`
	UserID       string `db:"user_id"`
	NewLeadCount int    `db:"new_lead_count"`
}

func getEligibleEmployees(app *pocketbase.PocketBase) ([]EmployeeInfo, error) {
	var totalUsers struct {
		Count int `db:"count"`
	}
	app.DB().NewQuery("SELECT COUNT(*) as count FROM users WHERE (LOWER(role) = 'employee' OR LOWER(role) = 'manager')").One(&totalUsers)
	app.Logger().Info("Employee query debug", "total_emp_or_mgr", totalUsers.Count)

	var notDisabled struct {
		Count int `db:"count"`
	}
	app.DB().NewQuery("SELECT COUNT(*) as count FROM users WHERE (LOWER(role) = 'employee' OR LOWER(role) = 'manager') AND disabled = false").One(&notDisabled)
	app.Logger().Info("Employee query debug", "not_disabled", notDisabled.Count)

	var withAtn struct {
		Count int `db:"count"`
	}
	app.DB().NewQuery("SELECT COUNT(*) as count FROM users WHERE (LOWER(role) = 'employee' OR LOWER(role) = 'manager') AND disabled = false AND no_atn = false").One(&withAtn)
	app.Logger().Info("Employee query debug", "with_attendance_tracking", withAtn.Count)

	var checkedIn struct {
		Count int `db:"count"`
	}
	app.DB().NewQuery(`SELECT COUNT(DISTINCT u.employee_code) as count FROM users u 
		INNER JOIN attendance a ON u.employee_code = a.employee_code 
		WHERE (LOWER(u.role) = 'employee' OR LOWER(u.role) = 'manager') 
		AND u.disabled = false 
		AND u.no_atn = false
		AND DATE(a.attendance_date) = DATE('now')
		AND a.check_in_time IS NOT NULL`).One(&checkedIn)
	app.Logger().Info("Employee query debug", "checked_in_today", checkedIn.Count)

	var notCheckedOut struct {
		Count int `db:"count"`
	}
	app.DB().NewQuery(`SELECT COUNT(DISTINCT u.employee_code) as count FROM users u 
		INNER JOIN attendance a ON u.employee_code = a.employee_code 
		WHERE (LOWER(u.role) = 'employee' OR LOWER(u.role) = 'manager') 
		AND u.disabled = false 
		AND u.no_atn = false
		AND DATE(a.attendance_date) = DATE('now')
		AND a.check_in_time IS NOT NULL
		AND (a.check_out_time IS NULL OR a.check_out_time = '')`).One(&notCheckedOut)
	app.Logger().Info("Employee query debug", "not_checked_out", notCheckedOut.Count)

	query := `
		SELECT 
			u.employee_code,
			u.employee_name,
			u.id as user_id,
			(SELECT COUNT(*) FROM leads WHERE employee_code = u.employee_code AND lead_status = 'New') as new_lead_count
		FROM users u
		WHERE 
			(LOWER(u.role) = 'employee' OR LOWER(u.role) = 'manager')
			AND u.disabled = false
			AND u.no_atn = false
			AND (u.stop_auto_leads IS NULL OR u.stop_auto_leads = false)
			AND EXISTS (
				SELECT 1 FROM attendance a 
				WHERE a.employee_code = u.employee_code 
				AND DATE(a.attendance_date) = DATE('now')
				AND a.check_in_time IS NOT NULL
				AND (a.check_out_time IS NULL OR a.check_out_time = '')
			)
			AND (SELECT COUNT(*) FROM leads WHERE employee_code = u.employee_code AND lead_status = 'New') <= 1
	`

	var employees []EmployeeInfo
	if err := app.DB().NewQuery(query).All(&employees); err != nil {
		app.Logger().Error("Failed to execute employee query", "error", err)
		return nil, err
	}

	app.Logger().Info("Final eligible employees", "count", len(employees))
	for _, emp := range employees {
		app.Logger().Info("Eligible employee",
			"code", emp.EmployeeCode,
			"name", emp.EmployeeName,
			"new_leads", emp.NewLeadCount)
	}

	return employees, nil
}

// allocateSingleLead allocates a single lead to employee
func allocateSingleLead(app *pocketbase.PocketBase, lead LeadInfo, emp EmployeeInfo) (bool, error) {
	dbRecord, err := app.FindRecordById("database", lead.ID)
	if err != nil {
		return false, err
	}

	mobileNo := dbRecord.GetString("mobile_no")
	customerName := dbRecord.GetString("customer_name")

	existingLead, _ := app.FindFirstRecordByFilter("leads", "mobile_no = {:mobile}", dbx.Params{"mobile": mobileNo})

	var leadRecord *core.Record
	var isNewLead bool

	if existingLead == nil {
		leadRecord, err = createNewLead(app, dbRecord, emp)
		if err != nil {
			return false, err
		}
		isNewLead = true
	} else {
		if existingLead.GetString("employee_code") == emp.EmployeeCode {
			return false, nil
		}

		leadRecord, err = updateExistingLead(app, existingLead, dbRecord, emp)
		if err != nil {
			return false, err
		}
		isNewLead = false
	}

	err = createAllocationHistory(app, lead.ID, leadRecord.Id, mobileNo, customerName, emp, isNewLead)
	if err != nil {
		return false, err
	}

	err = updateDatabaseRecord(app, lead.ID, emp)
	if err != nil {
		return false, err
	}

	return true, nil
}

// createNewLead creates a new lead in leads collection
func createNewLead(app *pocketbase.PocketBase, dbRecord *core.Record, emp EmployeeInfo) (*core.Record, error) {
	leadsCollection, err := app.FindCollectionByNameOrId("leads")
	if err != nil {
		return nil, err
	}

	newLead := core.NewRecord(leadsCollection)
	newLead.Set("customer_name", dbRecord.GetString("customer_name"))
	newLead.Set("mobile_no", dbRecord.GetString("mobile_no"))
	newLead.Set("city", dbRecord.GetString("city"))
	newLead.Set("employer", dbRecord.GetString("employer"))
	newLead.Set("product", dbRecord.GetString("product"))
	newLead.Set("segment", dbRecord.GetString("segment"))
	newLead.Set("decline_reason", dbRecord.GetString("decline_reason"))
	newLead.Set("data_code", dbRecord.GetString("data_code"))
	newLead.Set("data_sub_code", dbRecord.GetString("data_sub_code"))
	newLead.Set("custom_code", dbRecord.GetString("custom_code"))
	newLead.Set("employee_code", emp.EmployeeCode)
	newLead.Set("employee_name", emp.EmployeeName)
	newLead.Set("assigned_date", time.Now().UTC().Format(time.RFC3339))
	newLead.Set("assigned_to", emp.UserID)
	newLead.Set("lead_status", "New")
	newLead.Set("lead_status_date", time.Now().UTC().Format(time.RFC3339))

	if err := app.Save(newLead); err != nil {
		return nil, err
	}

	return newLead, nil
}

// updateExistingLead updates an existing lead
func updateExistingLead(app *pocketbase.PocketBase, existingLead *core.Record, dbRecord *core.Record, emp EmployeeInfo) (*core.Record, error) {
	if existingLead.GetString("data_code") == "" {
		existingLead.Set("data_code", dbRecord.GetString("data_code"))
	}
	if existingLead.GetString("data_sub_code") == "" {
		existingLead.Set("data_sub_code", dbRecord.GetString("data_sub_code"))
	}
	if existingLead.GetString("custom_code") == "" {
		existingLead.Set("custom_code", dbRecord.GetString("custom_code"))
	}

	existingLead.Set("employee_code", emp.EmployeeCode)
	existingLead.Set("employee_name", emp.EmployeeName)
	existingLead.Set("assigned_to", emp.UserID)
	existingLead.Set("assigned_date", time.Now().UTC().Format(time.RFC3339))
	existingLead.Set("lead_status", "New")
	existingLead.Set("lead_status_date", time.Now().UTC().Format(time.RFC3339))

	if err := app.Save(existingLead); err != nil {
		return nil, err
	}

	return existingLead, nil
}

// createAllocationHistory creates allocation history record
func createAllocationHistory(app *pocketbase.PocketBase, dbRecordID, leadRecordID, mobileNo, customerName string, emp EmployeeInfo, isNewLead bool) error {
	historyCollection, err := app.FindCollectionByNameOrId("lead_allocation_history")
	if err != nil {
		return err
	}

	allocationType := "reallocation"
	sequence := 1

	if !isNewLead {
		app.DB().NewQuery(`
			UPDATE lead_allocation_history 
			SET is_active = FALSE, deallocated_date = {:date} 
			WHERE lead_record_id = {:id} AND is_active = TRUE
		`).Bind(dbx.Params{
			"id":   leadRecordID,
			"date": time.Now().Format(time.RFC3339),
		}).Execute()

		var maxSeq struct {
			Seq int `db:"seq"`
		}
		app.DB().NewQuery(`
			SELECT COALESCE(MAX(allocation_sequence), 0) as seq 
			FROM lead_allocation_history 
			WHERE database_record_id = {:id}
		`).Bind(dbx.Params{"id": dbRecordID}).One(&maxSeq)

		sequence = maxSeq.Seq + 1
	} else {
		allocationType = "new_allocation"
	}

	historyRecord := core.NewRecord(historyCollection)
	historyRecord.Set("database_record_id", dbRecordID)
	historyRecord.Set("lead_record_id", leadRecordID)
	historyRecord.Set("mobile_no", mobileNo)
	historyRecord.Set("customer_name", customerName)
	historyRecord.Set("allocated_to_code", emp.EmployeeCode)
	historyRecord.Set("allocated_to_name", emp.EmployeeName)
	historyRecord.Set("allocated_by_code", "SYSTEM")
	historyRecord.Set("allocated_by_name", "Auto Reallocation Cron")
	historyRecord.Set("allocation_date", time.Now().Format(time.RFC3339))
	historyRecord.Set("allocation_type", allocationType)
	historyRecord.Set("is_active", true)
	historyRecord.Set("allocation_sequence", sequence)

	return app.Save(historyRecord)
}

// updateDatabaseRecord updates the database collection record
func updateDatabaseRecord(app *pocketbase.PocketBase, dbRecordID string, emp EmployeeInfo) error {
	var uniqueEmployees struct {
		Count int `db:"count"`
	}
	app.DB().NewQuery(`
		SELECT COUNT(DISTINCT allocated_to_code) as count 
		FROM lead_allocation_history 
		WHERE database_record_id = {:id}
	`).Bind(dbx.Params{"id": dbRecordID}).One(&uniqueEmployees)

	dbRecord, err := app.FindRecordById("database", dbRecordID)
	if err != nil {
		return err
	}

	currentCount := dbRecord.GetInt("allocation_count")

	_, err = app.DB().NewQuery(`
		UPDATE database 
		SET 
			allocation_count = {:count},
			employee_count = {:emp_count},
			employee_code = {:emp_code},
			employee_name = {:emp_name},
			lead_status = 'New',
			lead_status_date = {:status_date},
			data_status = 'used'
		WHERE id = {:id}
	`).Bind(dbx.Params{
		"count":       currentCount + 1,
		"emp_count":   uniqueEmployees.Count,
		"emp_code":    emp.EmployeeCode,
		"emp_name":    emp.EmployeeName,
		"status_date": time.Now().UTC().Format("2006-01-02 15:04:05"),
		"id":          dbRecordID,
	}).Execute()

	return err
}
