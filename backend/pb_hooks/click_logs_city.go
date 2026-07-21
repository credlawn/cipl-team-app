package pb_hooks

import (
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/tools/hook"
)

func SetupClickLogsCityHook(app core.App) {
	app.OnRecordAfterCreateSuccess("click_logs").Bind(&hook.Handler[*core.RecordEvent]{
		Func: func(e *core.RecordEvent) error {
			go func(event *core.RecordEvent) {
				defer func() {
					_ = recover()
				}()

				ip := event.Record.GetString("ip_address")
				if ip == "" {
					return
				}

				city, state, country, err := lookupCity(ip)
				if err != nil {
					return
				}

				recordID := event.Record.Id
				record, err := event.App.FindRecordById("click_logs", recordID)
				if err != nil || record == nil {
					return
				}

				if city != "" {
					record.Set("city", city)
				}
				if state != "" {
					record.Set("state", state)
				}
				if country != "" {
					record.Set("country", country)
				}

				location := ""
				if city != "" {
					location = city
				}
				if state != "" {
					if location != "" {
						location += " - "
					}
					location += state
				}
				if country != "" {
					if location != "" {
						location += " - "
					}
					location += country
				}
				if location != "" {
					record.Set("location", location)
				}

				event.App.Save(record)
			}(e)

			return e.Next()
		},
	})
}
