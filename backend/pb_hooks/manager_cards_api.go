package pb_hooks

import (
	"fmt"
	"net/http"
	"sort"
	"strings"
	"time"

	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

// SetupManagerCardsAPI registers the manager cards summary API endpoints
func SetupManagerCardsAPI(app *pocketbase.PocketBase) {
	app.OnServe().BindFunc(func(e *core.ServeEvent) error {
		e.Router.GET("/api/manager/cards/summary", handleManagerCardsSummary)
		return e.Next()
	})
}

type CardItemResponse struct {
	ID                   string `json:"id"`
	CustomerName         string `json:"customer_name"`
	ArnNo                string `json:"arn_no"`
	ArnDate              string `json:"arn_date"`
	DecisionMonth        string `json:"decision_month"`
	FinalDecisionDate    string `json:"final_decision_date"`
	CardType             string `json:"card_type"`
	ProductDescription   string `json:"product_description"`
	CardActivationStatus string `json:"card_activation_status"`
	IsActive             bool   `json:"is_active"`
	IsInactive           bool   `json:"is_inactive"`
	IsClosed             bool   `json:"is_closed"`
	MobileNo             string `json:"mobile_no"`
	EmployeeName         string `json:"employee_name"`
	EmployeeCode         string `json:"employee_code"`
	CustomerType         string `json:"customer_type"`
	DsaCode              string `json:"dsa_code"`
	SmCode               string `json:"sm_code"`
}

type EmployeeCardGroupResponse struct {
	EmployeeName  string             `json:"employee_name"`
	EmployeeCode  string             `json:"employee_code"`
	TotalCards    int                `json:"total_cards"`
	ActiveCards   int                `json:"active_cards"`
	InactiveCards int                `json:"inactive_cards"`
	ClosedCards   int                `json:"closed_cards"`
	WFH           bool               `json:"wfh"`
	Disabled      bool               `json:"disabled"`
	Designation   string             `json:"designation"`
	Cards         []CardItemResponse `json:"cards"`
}

func formatDecisionMonthString(t time.Time) string {
	return fmt.Sprintf("%s-%02d", t.Format("Jan"), t.Year()%100)
}

type UserRow struct {
	EmployeeCode string `db:"employee_code"`
	EmployeeName string `db:"employee_name"`
	WFH          bool   `db:"wfh"`
	Disabled     bool   `db:"disabled"`
	Designation  string `db:"designation"`
}

func handleManagerCardsSummary(c *core.RequestEvent) error {
	info, _ := c.RequestInfo()
	if info.Auth == nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"error": "Unauthorized"})
	}

	if info.Auth.GetBool("disabled") {
		return c.JSON(http.StatusForbidden, map[string]string{"error": "Account disabled"})
	}

	now := time.Now()
	currentMonthStr := formatDecisionMonthString(now)

	monthParam := strings.TrimSpace(c.Request.URL.Query().Get("month"))
	selectedMonth := monthParam
	if selectedMonth == "" {
		selectedMonth = currentMonthStr
	}

	// 1. Fetch available decision months from bank_approved_cards
	type MonthRow struct {
		Month string `db:"decision_month"`
	}
	var monthRows []MonthRow
	_ = c.App.DB().NewQuery(`
		SELECT DISTINCT decision_month 
		FROM bank_approved_cards 
		WHERE decision_month IS NOT NULL AND decision_month != ''
		ORDER BY decision_month DESC
	`).All(&monthRows)

	monthsSet := make(map[string]bool)
	monthsSet[currentMonthStr] = true
	var availableMonths []string
	availableMonths = append(availableMonths, currentMonthStr)

	for _, r := range monthRows {
		m := strings.TrimSpace(r.Month)
		if m != "" && !monthsSet[m] {
			monthsSet[m] = true
			availableMonths = append(availableMonths, m)
		}
	}

	sort.Slice(availableMonths, func(i, j int) bool {
		if availableMonths[i] == currentMonthStr {
			return true
		}
		if availableMonths[j] == currentMonthStr {
			return false
		}
		return availableMonths[i] > availableMonths[j]
	})

	// 2. Fetch users for employee status (WFH, disabled, designation)
	var userRows []UserRow
	err := c.App.DB().NewQuery(`
		SELECT 
			employee_code, 
			employee_name, 
			COALESCE(wfh, 0) as wfh, 
			COALESCE(disabled, 0) as disabled, 
			COALESCE(designation, '') as designation
		FROM users
	`).All(&userRows)

	if err != nil {
		c.App.Logger().Error("Failed to fetch users for cards summary", "error", err)
	}

	userMapByCode := make(map[string]UserRow)
	userMapByName := make(map[string]UserRow)

	for _, u := range userRows {
		code := strings.ToUpper(strings.TrimSpace(u.EmployeeCode))
		name := strings.ToLower(strings.TrimSpace(u.EmployeeName))

		if code != "" {
			userMapByCode[code] = u
		}
		if name != "" {
			userMapByName[name] = u
		}
	}

	// 3. Fetch cards for the selected month
	type CardRow struct {
		ID                   string `db:"id"`
		CustomerName         string `db:"customer_name"`
		ArnNo                string `db:"arn_no"`
		ArnDate              string `db:"arn_date"`
		DecisionMonth        string `db:"decision_month"`
		FinalDecisionDate    string `db:"final_decision_date"`
		CardType             string `db:"card_type"`
		ProductDescription   string `db:"product_description"`
		ProductCode          string `db:"product_code"`
		CardActivationStatus string `db:"card_activation_status"`
		MobileNo             string `db:"mobile_no"`
		EmployeeName         string `db:"employee_name"`
		EmployeeCode         string `db:"employee_code"`
		CustomerType         string `db:"customer_type"`
		DsaCode              string `db:"dsa_code"`
		SmCode               string `db:"sm_code"`
	}

	var cardRows []CardRow
	err = c.App.DB().NewQuery(`
		SELECT 
			id, customer_name, arn_no, arn_date, decision_month, final_decision_date,
			card_type, product_description, product_code, card_activation_status,
			mobile_no, employee_name, employee_code, customer_type, dsa_code, sm_code
		FROM bank_approved_cards
		WHERE LOWER(TRIM(decision_month)) = LOWER(TRIM({:month}))
		ORDER BY final_decision_date DESC, created DESC
	`).Bind(dbx.Params{"month": selectedMonth}).All(&cardRows)

	if err != nil {
		c.App.Logger().Error("Failed to fetch bank_approved_cards for summary", "error", err)
	}

	totalCards := len(cardRows)
	totalActive := 0
	totalInactive := 0
	totalClosed := 0

	type empBucket struct {
		EmployeeName  string
		EmployeeCode  string
		WFH           bool
		Disabled      bool
		Designation   string
		ActiveCards   int
		InactiveCards int
		ClosedCards   int
		Cards         []CardItemResponse
	}
	empBuckets := make(map[string]*empBucket)

	for _, card := range cardRows {
		rawStatus := strings.ToLower(strings.TrimSpace(card.CardActivationStatus))
		isClosed := strings.Contains(rawStatus, "closed")
		isInactive := rawStatus == "" || strings.Contains(rawStatus, "inactive") || strings.Contains(rawStatus, "pending")
		isActive := !isInactive && !isClosed && (strings.Contains(rawStatus, "txn") || strings.Contains(rawStatus, "v+") || strings.Contains(rawStatus, "v active") || strings.Contains(rawStatus, "done") || rawStatus == "active" || strings.Contains(rawStatus, "activated"))

		if isClosed {
			totalClosed++
		} else if isActive {
			totalActive++
		} else {
			totalInactive++
		}

		empCodeKey := strings.ToUpper(strings.TrimSpace(card.EmployeeCode))
		empName := strings.TrimSpace(card.EmployeeName)
		if empName == "" {
			empName = "Unknown"
		}

		bucketKey := empCodeKey
		if bucketKey == "" {
			bucketKey = strings.ToLower(empName)
		}

		prodDesc := strings.TrimSpace(card.ProductDescription)
		if prodDesc == "" {
			prodDesc = strings.TrimSpace(card.ProductCode)
		}

		item := CardItemResponse{
			ID:                   card.ID,
			CustomerName:         strings.TrimSpace(card.CustomerName),
			ArnNo:                strings.TrimSpace(card.ArnNo),
			ArnDate:              strings.TrimSpace(card.ArnDate),
			DecisionMonth:        strings.TrimSpace(card.DecisionMonth),
			FinalDecisionDate:    strings.TrimSpace(card.FinalDecisionDate),
			CardType:             strings.TrimSpace(card.CardType),
			ProductDescription:   prodDesc,
			CardActivationStatus: strings.TrimSpace(card.CardActivationStatus),
			IsActive:             isActive,
			IsInactive:           isInactive,
			IsClosed:             isClosed,
			MobileNo:             strings.TrimSpace(card.MobileNo),
			EmployeeName:         empName,
			EmployeeCode:         strings.TrimSpace(card.EmployeeCode),
			CustomerType:         strings.TrimSpace(card.CustomerType),
			DsaCode:              strings.TrimSpace(card.DsaCode),
			SmCode:               strings.TrimSpace(card.SmCode),
		}

		bucket, exists := empBuckets[bucketKey]
		if !exists {
			var u UserRow
			var hasUser bool

			if empCodeKey != "" {
				u, hasUser = userMapByCode[empCodeKey]
			}
			if !hasUser && empName != "" {
				u, hasUser = userMapByName[strings.ToLower(empName)]
			}

			wfh := false
			disabled := false
			designation := ""
			displayName := empName
			empCode := card.EmployeeCode

			if hasUser {
				wfh = u.WFH
				disabled = u.Disabled
				designation = u.Designation
				if strings.TrimSpace(u.EmployeeName) != "" {
					displayName = u.EmployeeName
				}
				if empCode == "" {
					empCode = u.EmployeeCode
				}
			} else {
				// Not found in users table -> Inactive
				disabled = true
			}

			bucket = &empBucket{
				EmployeeName: displayName,
				EmployeeCode: empCode,
				WFH:          wfh,
				Disabled:     disabled,
				Designation:  designation,
				Cards:        []CardItemResponse{},
			}
			empBuckets[bucketKey] = bucket
		}

		if isClosed {
			bucket.ClosedCards++
		} else if isActive {
			bucket.ActiveCards++
		} else {
			bucket.InactiveCards++
		}
		bucket.Cards = append(bucket.Cards, item)
	}

	var officeGroups []EmployeeCardGroupResponse
	var wfhGroups []EmployeeCardGroupResponse
	var inactiveGroups []EmployeeCardGroupResponse

	for _, b := range empBuckets {
		grp := EmployeeCardGroupResponse{
			EmployeeName:  b.EmployeeName,
			EmployeeCode:  b.EmployeeCode,
			TotalCards:    len(b.Cards),
			ActiveCards:   b.ActiveCards,
			InactiveCards: b.InactiveCards,
			ClosedCards:   b.ClosedCards,
			WFH:           b.WFH,
			Disabled:      b.Disabled,
			Designation:   b.Designation,
			Cards:         b.Cards,
		}

		if b.Disabled {
			inactiveGroups = append(inactiveGroups, grp)
		} else if b.WFH {
			wfhGroups = append(wfhGroups, grp)
		} else {
			officeGroups = append(officeGroups, grp)
		}
	}

	sortEmployees := func(list []EmployeeCardGroupResponse) {
		sort.Slice(list, func(i, j int) bool {
			if list[i].TotalCards != list[j].TotalCards {
				return list[i].TotalCards > list[j].TotalCards
			}
			return list[i].EmployeeName < list[j].EmployeeName
		})
	}

	sortEmployees(officeGroups)
	sortEmployees(wfhGroups)
	sortEmployees(inactiveGroups)

	return c.JSON(http.StatusOK, map[string]interface{}{
		"current_month":    currentMonthStr,
		"selected_month":   selectedMonth,
		"available_months": availableMonths,
		"summary": map[string]interface{}{
			"total_cards":    totalCards,
			"total_active":   totalActive,
			"total_inactive": totalInactive,
			"total_closed":   totalClosed,
		},
		"groups": map[string]interface{}{
			"office":   officeGroups,
			"wfh":      wfhGroups,
			"inactive": inactiveGroups,
		},
	})
}
