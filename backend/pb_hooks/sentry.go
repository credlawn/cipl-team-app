package pb_hooks

import (
	"log"
	"time"

	"github.com/getsentry/sentry-go"
)

const BugsinkBackendDSN = "https://6beb055c5b7c49deb141b7732bac5dbe@error.cipl.me/2"

// InitSentry initializes the Sentry Go SDK for Bugsink logging
func InitSentry() {
	err := sentry.Init(sentry.ClientOptions{
		Dsn:              BugsinkBackendDSN,
		Environment:      "production",
		AttachStacktrace: true,
	})
	if err != nil {
		log.Printf("Sentry/Bugsink init failed: %v\n", err)
	} else {
		log.Println("[Bugsink] Backend Sentry logging initialized successfully")
	}
}

// FlushSentry flushes buffered error events before server shutdown
func FlushSentry() {
	sentry.Flush(2 * time.Second)
}

// CaptureError captures Go errors and logs them to Bugsink with optional module tags
func CaptureError(err error, tag string) {
	if err == nil {
		return
	}
	sentry.WithScope(func(scope *sentry.Scope) {
		if tag != "" {
			scope.SetTag("module", tag)
		}
		sentry.CaptureException(err)
	})
}
