package pb_hooks

import (
	"net/http"
	"os"
	"path/filepath"
	"strings"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/tools/osutils"
)

func SetupURLRedirect(app *pocketbase.PocketBase) {
	app.OnServe().BindFunc(func(e *core.ServeEvent) error {
		e.Router.GET("/{path...}", handleURLRedirect)
		return e.Next()
	})
}

func handleURLRedirect(c *core.RequestEvent) error {
	path := strings.TrimPrefix(c.Request.URL.Path, "/")

	if path != "" && !strings.Contains(path, ".") {
		record, err := c.App.FindFirstRecordByData("shortner", "short_code", path)
		if err == nil && record != nil {
			longURL := record.GetString("long_url")
			if longURL != "" {
				LogClick(c.App, path, longURL, c.Request)
				return c.Redirect(http.StatusFound, longURL)
			}
		}
	}

	publicDir := defaultPublicDir()
	return apis.Static(os.DirFS(publicDir), true)(c)
}

func defaultPublicDir() string {
	if osutils.IsProbablyGoRun() {
		return "./pb_public"
	}
	return filepath.Join(os.Args[0], "../pb_public")
}
