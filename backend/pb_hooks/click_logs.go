package pb_hooks

import (
	"encoding/json"
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase/core"
)

func LogClick(app core.App, shortCode string, longURL string, r *http.Request) {
	ua := r.UserAgent()
	if isBot(ua) {
		return
	}

	ip := extractIP(r)
	browser := parseBrowser(ua)
	device := parseDevice(ua)

	records, _ := app.FindRecordsByFilter("click_logs",
		"short_code = {:code} && ip_address = {:ip}",
		"", 1, 0,
		dbx.Params{"code": shortCode, "ip": ip})

	clickType := "New"
	if len(records) > 0 {
		clickType = "Return"
	}

	collection, err := app.FindCollectionByNameOrId("click_logs")
	if err != nil {
		return
	}
	record := core.NewRecord(collection)
	record.Set("short_code", shortCode)
	record.Set("destination", longURL)
	record.Set("ip_address", ip)
	record.Set("click_type", clickType)
	record.Set("device", device)
	record.Set("browser", browser)
	record.Set("user_agent", ua)

	app.Save(record)
}

func extractIP(r *http.Request) string {
	forwarded := r.Header.Get("X-Forwarded-For")
	if forwarded != "" {
		parts := strings.Split(forwarded, ",")
		return strings.TrimSpace(parts[0])
	}
	realIP := r.Header.Get("X-Real-IP")
	if realIP != "" {
		return realIP
	}
	addr := r.RemoteAddr
	if strings.HasPrefix(addr, "[") {
		if idx := strings.Index(addr, "]"); idx != -1 {
			return addr[1:idx]
		}
	} else if idx := strings.LastIndex(addr, ":"); idx != -1 {
		return addr[:idx]
	}
	return addr
}

func parseBrowser(ua string) string {
	ua = strings.ToLower(ua)
	switch {
	case strings.Contains(ua, "edg/"):
		return "Edge"
	case (strings.Contains(ua, "chrome/") || strings.Contains(ua, "chromium/")) &&
		!strings.Contains(ua, "opr/") && !strings.Contains(ua, "brave"):
		return "Chrome"
	case strings.Contains(ua, "firefox/"):
		return "Firefox"
	case strings.Contains(ua, "opr/") || strings.Contains(ua, "opera"):
		return "Opera"
	case strings.Contains(ua, "safari/") && !strings.Contains(ua, "chrome/"):
		return "Safari"
	case strings.Contains(ua, "brave"):
		return "Brave"
	default:
		return "Unknown"
	}
}

func parseDevice(ua string) string {
	ua = strings.ToLower(ua)
	switch {
	case strings.Contains(ua, "iphone"):
		return "iPhone"
	case strings.Contains(ua, "ipad"):
		return "iPad"
	case strings.Contains(ua, "android"):
		if strings.Contains(ua, "mobile") {
			return "Android Phone"
		}
		return "Android Tablet"
	case strings.Contains(ua, "windows"):
		return "Windows"
	case strings.Contains(ua, "macintosh") || strings.Contains(ua, "mac os"):
		return "Mac"
	case strings.Contains(ua, "linux"):
		return "Linux"
	default:
		return "Unknown"
	}
}

func isBot(ua string) bool {
	ua = strings.ToLower(ua)
	bots := []string{
		"googlebot", "googlepreview", "google-safety",
		"facebookexternalhit", "facebot", "metaexternalagent",
		"twitterbot",
		"telegrambot",
		"slackbot", "slack-imgproxy",
		"discordbot",
		"linkedinbot",
		"applebot",
		"bingpreview",
		"whatsapp",
		"headless",
		"curl", "wget", "python-requests", "python-urllib", "go-http-client",
		"axios", "okhttp",
		"scrapy", "crawler", "spider", "scan",
	}
	for _, b := range bots {
		if strings.Contains(ua, b) {
			return true
		}
	}
	return false
}

func lookupCity(ip string) (city, state, country string, err error) {
	if net.ParseIP(ip) == nil {
		return "", "", "", fmt.Errorf("invalid IP: %s", ip)
	}
	if isPrivateIP(ip) {
		return "", "", "", nil
	}
	apiKey := os.Getenv("IP_API_KEY")
	if apiKey == "" {
		return "", "", "", fmt.Errorf("IP_API_KEY not set")
	}
	url := fmt.Sprintf("https://api.ipgeolocation.io/v3/ipgeo?apiKey=%s&ip=%s", apiKey, ip)
	client := &http.Client{Timeout: 5 * time.Second}
	resp, err := client.Get(url)
	if err != nil {
		return "", "", "", err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return "", "", "", fmt.Errorf("ipgeolocation returned status %d", resp.StatusCode)
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", "", "", err
	}
	var result struct {
		Location struct {
			City      string `json:"city"`
			StateProv string `json:"state_prov"`
			CountryName string `json:"country_name"`
		} `json:"location"`
	}
	if err := json.Unmarshal(body, &result); err != nil {
		return "", "", "", err
	}
	return result.Location.City, result.Location.StateProv, result.Location.CountryName, nil
}

func isPrivateIP(ipStr string) bool {
	ip := net.ParseIP(ipStr)
	if ip == nil {
		return false
	}
	privateBlocks := []*net.IPNet{
		{IP: net.IPv4(10, 0, 0, 0), Mask: net.CIDRMask(8, 32)},
		{IP: net.IPv4(172, 16, 0, 0), Mask: net.CIDRMask(12, 32)},
		{IP: net.IPv4(192, 168, 0, 0), Mask: net.CIDRMask(16, 32)},
		{IP: net.IPv4(127, 0, 0, 0), Mask: net.CIDRMask(8, 32)},
		{IP: net.IPv6loopback, Mask: net.CIDRMask(128, 128)},
	}
	for _, block := range privateBlocks {
		if block.Contains(ip) {
			return true
		}
	}
	return false
}
