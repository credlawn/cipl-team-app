package pb_hooks

import (
	"net/http"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

func SetupPrivacyPolicy(app *pocketbase.PocketBase) {
	app.OnServe().BindFunc(func(e *core.ServeEvent) error {
		e.Router.GET("/privacy-policy", handlePrivacyPolicy)
		e.Router.GET("/data-deletion", handleDataDeletion)
		return e.Next()
	})
}

func handlePrivacyPolicy(c *core.RequestEvent) error {
	html := `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Privacy Policy - Credlawn CRM</title>
    <style>
        body { font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; line-height: 1.6; color: #202124; max-width: 800px; margin: 0 auto; padding: 20px; background-color: #f8f9fa; }
        .container { background: #ffffff; padding: 36px; border-radius: 12px; box-shadow: 0 2px 12px rgba(0,0,0,0.06); border: 1px solid #dadce0; }
        h1 { color: #1976D2; border-bottom: 2px solid #e8eaed; padding-bottom: 12px; font-size: 26px; }
        h2 { color: #202124; margin-top: 28px; font-size: 18px; }
        p, li { color: #5f6368; font-size: 15px; }
        ul { padding-left: 20px; }
        li { margin-bottom: 8px; }
        .last-updated { font-size: 0.9em; color: #70757a; font-style: italic; }
        .contact-card { background: #f1f3f4; padding: 18px; border-radius: 8px; margin-top: 24px; }
        a { color: #1976D2; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Privacy Policy for Credlawn CRM</h1>
        <p class="last-updated">Last Updated: July 27, 2026</p>

        <p>Credlawn India Private Limited ("Company", "we", "us", or "our") operates the <strong>Credlawn CRM</strong> mobile application and services. This Privacy Policy informs users ("Employees", "Managers", "Users") regarding our policies with the collection, use, and disclosure of Personal Information for users of our Enterprise Application.</p>

        <h2>1. Information We Collect</h2>
        <p>To provide sales team management, attendance verification, and customer relationship operations, we collect the following categories of information:</p>
        <ul>
            <li><strong>Personal Identification Data:</strong> Employee Name, Employee ID, Email Address, Mobile Number, Assigned Role, and Branch Location.</li>
            <li><strong>Location Data:</strong> Fine and Coarse GPS location data during employee Check-in/Check-out for attendance and geofenced verification.</li>
            <li><strong>Call Interaction Logs:</strong> Call durations, timestamps, and outgoing call status related to assigned sales lead records for performance analytics.</li>
            <li><strong>Device Telemetry:</strong> Device Model, Android/OS Version, Unique Device Identifier (Android ID), and FCM Push Notification Tokens.</li>
            <li><strong>Camera Images:</strong> Employee check-in selfie verification images and document scans (OCR) for KYC record management.</li>
        </ul>

        <h2>2. How We Use Information</h2>
        <p>The collected information is strictly used for legitimate corporate operations, including:</p>
        <ul>
            <li>Managing sales lead allocations, status updates, and customer interaction logs.</li>
            <li>Verifying employee daily attendance, GPS check-ins, and leave requests.</li>
            <li>Sending real-time push notifications regarding lead assignments and system updates.</li>
            <li>Preventing unauthorized account access through device bonding and security Sentinel checks.</li>
        </ul>

        <h2>3. Data Protection & Security</h2>
        <p>We implement industry-standard administrative, technical, and physical security measures to safeguard your data. All communications between the mobile application and our servers are encrypted in transit using TLS/HTTPS protocol. Data stored in our databases is access-restricted to authorized corporate administrators.</p>

        <h2>4. Data Sharing & Third Parties</h2>
        <p>Credlawn India Private Limited does <strong>NOT</strong> sell, trade, or rent personal data to third parties or marketing agencies. Data is shared only with trusted infrastructure providers strictly necessary for app functionality:</p>
        <ul>
            <li><strong>Firebase Cloud Messaging (Google):</strong> For delivering push notification payloads.</li>
            <li><strong>Bugsink Telemetry:</strong> For crash monitoring, stack trace logging, and system diagnostics.</li>
        </ul>

        <h2>5. Account & Data Deletion Policy</h2>
        <p>Credlawn CRM accounts are enterprise accounts provisioned by an employer. Employees who wish to request account deactivation, data removal, or data access queries may contact their System Administrator or submit a written request to our Data Protection team at <a href="mailto:info@credlawn.com">info@credlawn.com</a>.</p>

        <h2>6. Contact Us</h2>
        <div class="contact-card">
            <p>If you have any questions, concerns, or requests regarding this Privacy Policy, please contact us at:</p>
            <p><strong>Credlawn India Private Limited</strong><br>
            Email: <a href="mailto:info@credlawn.com">info@credlawn.com</a></p>
        </div>
    </div>
</body>
</html>`
	return c.HTML(http.StatusOK, html)
}

func handleDataDeletion(c *core.RequestEvent) error {
	html := `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Account Deactivation & Data Policy - Credlawn CRM</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #202124; max-width: 750px; margin: 0 auto; padding: 24px; background-color: #f8f9fa; }
        .container { background: #ffffff; padding: 32px; border-radius: 8px; border: 1px solid #dadce0; }
        h1 { color: #1a73e8; font-size: 24px; margin-bottom: 8px; }
        h3 { color: #202124; margin-top: 24px; font-size: 16px; }
        p, li { color: #3c4043; font-size: 15px; }
        ul { padding-left: 20px; }
        li { margin-bottom: 8px; }
        .notice { background: #e8f0fe; padding: 14px 18px; border-radius: 6px; margin: 20px 0; color: #174ea6; font-size: 14px; }
        .contact { background: #f1f3f4; padding: 16px; border-radius: 6px; margin-top: 24px; font-size: 14px; }
        a { color: #1a73e8; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Account Deactivation & Data Policy</h1>

        <div class="notice">
            <strong>Enterprise Application Notice:</strong> Credlawn CRM accounts are provisioned exclusively for active employees of Credlawn India Private Limited to perform official sales operations.
        </div>

        <h3>Active Employment Accounts</h3>
        <p>An active account is required during employment to perform official daily duties, access assigned sales leads, and log attendance. User accounts remain active for the duration of employment with the company.</p>

        <h3>Account Deactivation Upon Employment Departure</h3>
        <p>When an employee departs from the organization or completes their contractual term:</p>
        <ul>
            <li><strong>Standard Offboarding:</strong> Account access is deactivated by HR / IT Administration as part of the standard offboarding procedure.</li>
            <li><strong>Direct Request:</strong> Former employees may request prompt account deactivation by emailing <a href="mailto:info@credlawn.com">info@credlawn.com</a> with their full name and employee ID.</li>
        </ul>

        <h3>Corporate Record Retention</h3>
        <p>In accordance with corporate governance and applicable legal standards, operational data created during employment (including lead interaction history, sales updates, and attendance records) is property of Credlawn India Private Limited and retained for enterprise record compliance.</p>

        <div class="contact">
            <strong>Contact Support:</strong><br>
            For account queries or privacy requests, please contact HR Administration or email <a href="mailto:info@credlawn.com">info@credlawn.com</a>.
        </div>
    </div>
</body>
</html>`
	return c.HTML(http.StatusOK, html)
}
