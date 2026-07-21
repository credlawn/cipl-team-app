package pb_hooks

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"mime"
	"mime/multipart"
	"net/http"
	"net/textproto"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

// SetupWhatsAppMessaging registers database hooks for whatsapp_messages collection
func SetupWhatsAppMessaging(app *pocketbase.PocketBase) {
	// Synchronous hook to handle outgoing messages before they are saved to the database.
	// This prevents race conditions where WhatsApp status webhook updates (delivered/read)
	// arrive before the outbound goroutine saves the message_id.
	app.OnRecordCreate("whatsapp_messages").BindFunc(func(e *core.RecordEvent) error {
		if e.Record.GetString("direction") == "outgoing" && e.Record.GetString("status") == "pending" {
			convID := e.Record.GetString("conversation")
			conversation, err := app.FindFirstRecordByData("whatsapp_conversations", "id", convID)
			if err != nil {
				app.Logger().Error("Failed to find conversation for outgoing message", "error", err, "conv_id", convID)
				e.Record.Set("status", "failed")
				return e.Next()
			}

			toPhone := conversation.GetString("customer_phone")
			bodyText := e.Record.GetString("body")
			msgType := e.Record.GetString("type")
			replyToID := e.Record.GetString("reply_to_id")

			accessToken := os.Getenv("WHATSAPP_ACCESS_TOKEN")
			phoneID := os.Getenv("WHATSAPP_PHONE_NUMBER_ID")

			if accessToken == "" || phoneID == "" {
				app.Logger().Error("WhatsApp environment configuration is missing (access token or phone id)")
				e.Record.Set("status", "failed")
				return e.Next()
			}

			var metaMsgID string

			unsavedFiles := e.Record.GetUnsavedFiles("media_file")
			if len(unsavedFiles) > 0 && msgType != "text" {
				mediaFile := unsavedFiles[0]

				// 1. Get the file bytes
				if mediaFile.Reader == nil {
					app.Logger().Error("Unsaved media file has no reader available")
					e.Record.Set("status", "failed")
					return e.Next()
				}

				rc, err := mediaFile.Reader.Open()
				if err != nil {
					app.Logger().Error("Failed to open unsaved media file reader", "error", err)
					e.Record.Set("status", "failed")
					return e.Next()
				}
				fileBytes, err := io.ReadAll(rc)
				rc.Close()
				if err != nil {
					app.Logger().Error("Failed to read unsaved media file bytes", "error", err)
					e.Record.Set("status", "failed")
					return e.Next()
				}

				// 2. Resolve Content Type by extension first to avoid zip/bin detection issues (.xlsx, .docx etc)
				// We check OriginalName first because PocketBase renames unsaved files to have a ".bin" extension
				// if it cannot resolve the mime type on upload.
				ext := strings.ToLower(filepath.Ext(mediaFile.OriginalName))
				if ext == "" || ext == ".bin" {
					ext = strings.ToLower(filepath.Ext(mediaFile.Name))
				}

				contentType := ""
				if mimeType, ok := extensionMimeTypes[ext]; ok {
					contentType = mimeType
				} else {
					contentType = mime.TypeByExtension(ext)
				}

				if contentType == "" {
					contentType = http.DetectContentType(fileBytes)
				}

				app.Logger().Info("Resolved outgoing media MIME type", 
					"originalName", mediaFile.OriginalName, 
					"storedName", mediaFile.Name, 
					"extension", ext, 
					"resolvedMime", contentType,
				)

				// 3. Upload media to Meta
				metaMediaID, err := uploadMediaToMeta(phoneID, accessToken, fileBytes, mediaFile.OriginalName, contentType)
				if err != nil {
					app.Logger().Error("Failed to upload media to Meta", "error", err)
					e.Record.Set("status", "failed")
					return e.Next()
				}

				// Store the uploaded Meta Media ID in the record
				e.Record.Set("media_id", metaMediaID)
				e.Record.Set("mime_type", contentType)

				// 4. Send media message
				metaMsgID, err = sendWhatsAppMediaMessage(phoneID, accessToken, toPhone, msgType, metaMediaID, bodyText, mediaFile.OriginalName, replyToID)
				if err != nil {
					app.Logger().Error("Failed to send WhatsApp media message", "error", err)
					e.Record.Set("status", "failed")
					return e.Next()
				}
			} else {
				// Send to Meta Cloud API synchronously as a text message
				metaMsgID, err = sendWhatsAppMessage(phoneID, accessToken, toPhone, bodyText, replyToID)
				if err != nil {
					app.Logger().Error("Failed to send WhatsApp message via Meta Cloud API", "error", err, "recipient", toPhone)
					e.Record.Set("status", "failed")
					return e.Next()
				}
			}

			// Success: Populate the message ID and set the status to "sent" before record creation
			e.Record.Set("message_id", metaMsgID)
			e.Record.Set("status", "sent")

			// Update the conversation's last message details asynchronously to prevent transaction blocking
			go func(c *core.Record, body string) {
				c.Set("last_message", body)
				c.Set("last_message_time", time.Now().UTC().Format("2006-01-02 15:04:05.000Z"))
				if saveErr := app.Save(c); saveErr != nil {
					app.Logger().Error("Failed to update last message metadata in conversation", "error", saveErr)
				}
			}(conversation, bodyText)
		}
		return e.Next()
	})
}

// sendWhatsAppMessage makes an HTTP request to Meta WhatsApp Cloud API to send a text message
func sendWhatsAppMessage(phoneNumberID string, accessToken string, to string, body string, replyToID string) (string, error) {
	url := fmt.Sprintf("https://graph.facebook.com/v19.0/%s/messages", phoneNumberID)

	payload := map[string]interface{}{
		"messaging_product": "whatsapp",
		"recipient_type":    "individual",
		"to":                to,
		"type":              "text",
		"text": map[string]interface{}{
			"preview_url": false,
			"body":        body,
		},
	}

	if replyToID != "" {
		payload["context"] = map[string]interface{}{
			"message_id": replyToID,
		}
	}

	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		return "", err
	}

	req, err := http.NewRequest("POST", url, bytes.NewReader(payloadBytes))
	if err != nil {
		return "", err
	}
	req.Header.Set("Authorization", "Bearer "+accessToken)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	respBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return "", fmt.Errorf("api returned status %d: %s", resp.StatusCode, string(respBytes))
	}

	type MetaResponse struct {
		Messages []struct {
			ID string `json:"id"`
		} `json:"messages"`
	}

	var metaResp MetaResponse
	if err := json.Unmarshal(respBytes, &metaResp); err != nil {
		return "", err
	}

	if len(metaResp.Messages) == 0 {
		return "", fmt.Errorf("no message id returned by Meta API")
	}

	return metaResp.Messages[0].ID, nil
}

// uploadMediaToMeta performs a multipart/form-data POST upload to Meta media endpoint
func uploadMediaToMeta(phoneNumberID string, accessToken string, fileBytes []byte, filename string, mimeType string) (string, error) {
	url := fmt.Sprintf("https://graph.facebook.com/v19.0/%s/media", phoneNumberID)

	var buf bytes.Buffer
	writer := multipart.NewWriter(&buf)

	// Add messaging_product
	if err := writer.WriteField("messaging_product", "whatsapp"); err != nil {
		return "", err
	}

	// Add type
	if err := writer.WriteField("type", mimeType); err != nil {
		return "", err
	}

	// Add file using custom headers to specify the correct Content-Type (since Go's CreateFormFile defaults to application/octet-stream)
	h := make(textproto.MIMEHeader)
	h.Set("Content-Disposition", fmt.Sprintf(`form-data; name="%s"; filename="%s"`, "file", filename))
	h.Set("Content-Type", mimeType)

	part, err := writer.CreatePart(h)
	if err != nil {
		return "", err
	}
	if _, err := part.Write(fileBytes); err != nil {
		return "", err
	}

	if err := writer.Close(); err != nil {
		return "", err
	}

	req, err := http.NewRequest("POST", url, &buf)
	if err != nil {
		return "", err
	}
	req.Header.Set("Authorization", "Bearer "+accessToken)
	req.Header.Set("Content-Type", writer.FormDataContentType())

	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	respBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return "", fmt.Errorf("media upload returned status %d: %s", resp.StatusCode, string(respBytes))
	}

	type MetaMediaResponse struct {
		ID string `json:"id"`
	}

	var mediaResp MetaMediaResponse
	if err := json.Unmarshal(respBytes, &mediaResp); err != nil {
		return "", err
	}

	if mediaResp.ID == "" {
		return "", fmt.Errorf("no media id returned by Meta API: %s", string(respBytes))
	}

	return mediaResp.ID, nil
}

// sendWhatsAppMediaMessage calls Meta Cloud API to send a media message
func sendWhatsAppMediaMessage(phoneNumberID string, accessToken string, to string, mediaType string, mediaID string, caption string, filename string, replyToID string) (string, error) {
	url := fmt.Sprintf("https://graph.facebook.com/v19.0/%s/messages", phoneNumberID)

	whatsappType := mediaType
	if whatsappType == "voice" {
		whatsappType = "audio"
	} else if whatsappType != "image" && whatsappType != "video" && whatsappType != "audio" && whatsappType != "document" {
		whatsappType = "document"
	}

	mediaData := map[string]interface{}{
		"id": mediaID,
	}
	if (whatsappType == "image" || whatsappType == "video" || whatsappType == "document") && caption != "" {
		mediaData["caption"] = caption
	}
	if whatsappType == "document" && filename != "" {
		mediaData["filename"] = filename
	}

	payload := map[string]interface{}{
		"messaging_product": "whatsapp",
		"recipient_type":    "individual",
		"to":                to,
		"type":              whatsappType,
		whatsappType:        mediaData,
	}

	if replyToID != "" {
		payload["context"] = map[string]interface{}{
			"message_id": replyToID,
		}
	}

	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		return "", err
	}

	req, err := http.NewRequest("POST", url, bytes.NewReader(payloadBytes))
	if err != nil {
		return "", err
	}
	req.Header.Set("Authorization", "Bearer "+accessToken)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 15 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	respBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return "", fmt.Errorf("api returned status %d: %s", resp.StatusCode, string(respBytes))
	}

	type MetaResponse struct {
		Messages []struct {
			ID string `json:"id"`
		} `json:"messages"`
	}

	var metaResp MetaResponse
	if err := json.Unmarshal(respBytes, &metaResp); err != nil {
		return "", err
	}

	if len(metaResp.Messages) == 0 {
		return "", fmt.Errorf("no message id returned by Meta API")
	}

	return metaResp.Messages[0].ID, nil
}

// Map of common file extensions to Meta-supported MIME types
var extensionMimeTypes = map[string]string{
	".jpg":   "image/jpeg",
	".jpeg":  "image/jpeg",
	".png":   "image/png",
	".webp":  "image/webp",
	".gif":   "image/gif",
	".mp3":   "audio/mpeg",
	".aac":   "audio/aac",
	".amr":   "audio/amr",
	".ogg":   "audio/ogg",
	".opus":  "audio/ogg",
	".mp4":   "video/mp4",
	".3gp":   "video/3gpp",
	".pdf":   "application/pdf",
	".txt":   "text/plain",
	".doc":   "application/msword",
	".docx":  "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
	".xls":   "application/vnd.ms-excel",
	".xlsx":  "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
	".ppt":   "application/vnd.ms-powerpoint",
	".pptx":  "application/vnd.openxmlformats-officedocument.presentationml.presentation",
}
