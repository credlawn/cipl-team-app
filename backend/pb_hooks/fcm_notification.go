package pb_hooks

import (
	"context"
	"log"
	"os"
	"strings"

	"firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"google.golang.org/api/option"
)

var FCM *messaging.Client

func InitFirebase() {
	keyPath := os.Getenv("FIREBASE_KEY_PATH")
	if keyPath == "" {
		keyPath = "pb_data/firebase-key.json"
	}
	opt := option.WithCredentialsFile(keyPath)
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		CaptureError(err, "FirebaseInit")
		log.Fatal(err)
	}
	FCM, err = app.Messaging(context.Background())
	if err != nil {
		CaptureError(err, "FirebaseMessagingInit")
		log.Fatal(err)
	}
}

func SendNotification(token, title, body, channelId string) {
	if token == "" {
		return
	}
	ctx := context.Background()
	msg := &messaging.Message{
		Token: token,
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Data: map[string]string{
			"click_action": "FLUTTER_NOTIFICATION_CLICK",
			"channel_id":   channelId, // Added for foreground handling if needed
		},
		Android: &messaging.AndroidConfig{
			Priority: "high",
			Notification: &messaging.AndroidNotification{
				ChannelID: channelId,
				Sound:     "default",
			},
		},
	}
	_, err := FCM.Send(ctx, msg)
	if err != nil {
		// Filter out stale/unregistered token errors so Bugsink dashboard stays clean
		if messaging.IsUnregistered(err) || strings.Contains(err.Error(), "NotRegistered") || strings.Contains(err.Error(), "registration-token-not-registered") {
			log.Println("[FCM] Ignored unregistered/stale token:", token)
			return
		}

		log.Println("FCM error:", err)
		CaptureError(err, "FCMNotification")
	}
}