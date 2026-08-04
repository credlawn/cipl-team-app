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
    <title>Enterprise Privacy Notice & Data Protection Policy - Credlawn CRM</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; line-height: 1.65; color: #1f2937; max-width: 860px; margin: 0 auto; padding: 32px 20px; background-color: #f9fafb; }
        .container { background: #ffffff; padding: 48px; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.08); border: 1px solid #e5e7eb; }
        .header { border-bottom: 2px solid #e5e7eb; padding-bottom: 20px; margin-bottom: 28px; }
        h1 { color: #1e3a8a; font-size: 26px; font-weight: 700; margin: 0 0 8px 0; letter-spacing: -0.01em; }
        .company-name { font-size: 15px; color: #4b5563; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; }
        .doc-meta { font-size: 0.88em; color: #6b7280; margin-top: 6px; }
        h2 { color: #1e293b; margin-top: 32px; font-size: 18px; font-weight: 600; border-bottom: 1px solid #f1f5f9; padding-bottom: 6px; }
        p, li { color: #374151; font-size: 14.5px; }
        ul { padding-left: 22px; margin-bottom: 16px; }
        li { margin-bottom: 8px; }
        strong { color: #111827; }
        .legal-notice { background-color: #f0f9ff; border-left: 4px solid #0284c7; padding: 16px 20px; border-radius: 4px; margin: 24px 0; }
        .legal-notice p { margin: 0; color: #0369a1; font-size: 14px; font-weight: 500; }
        .contact-box { background-color: #f8fafc; border: 1px solid #e2e8f0; padding: 24px; border-radius: 8px; margin-top: 36px; }
        a { color: #2563eb; text-decoration: none; font-weight: 500; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="company-name">Credlawn India Private Limited</div>
            <h1>Enterprise Privacy Notice & Data Protection Policy</h1>
            <div class="doc-meta">Document Reference: CIPL-SEC-POL-001 | Effective Date: July 1, 2026 | App: Credlawn CRM</div>
        </div>

        <div class="legal-notice">
            <p><strong>Notice to Users:</strong> Credlawn CRM is a proprietary enterprise application intended exclusively for authorized employees, personnel, and representatives of Credlawn India Private Limited. This policy governs the processing of workplace data collected through the application.</p>
        </div>

        <h2>1. Scope & Purpose</h2>
        <p>Credlawn India Private Limited ("Company", "we", "us", or "our") is committed to protecting the privacy, confidentiality, and security of personal and operational data. This Enterprise Privacy Notice outlines our standards and practices regarding the collection, processing, storage, and protection of information obtained from users ("Employees", "Personnel", "Users") through the <strong>Credlawn CRM</strong> mobile application.</p>

        <h2>2. Legal Basis for Processing</h2>
        <p>We process personal and employment data pursuant to legitimate business interests, contractual obligations under employment agreements, statutory compliance requirements, and operational necessity for executing authorized corporate functions.</p>

        <h2>3. Categories of Information Collected</h2>
        <p>In accordance with data minimization principles, we collect only such information as is strictly necessary for operational delivery, workforce management, and enterprise security:</p>
        <ul>
            <li><strong>Employment Identifiers & Credentials:</strong> Full Name, Employee ID, Corporate Email Address, Registered Phone Number, Designated Role, and Work Division/Branch assignment.</li>
            <li><strong>Geolocation & Duty Status Data:</strong> Time-stamped geographical location coordinates captured strictly during attendance check-in, check-out, and active duty execution to verify workplace attendance and field operations. Continuous location tracking outside designated duty hours is explicitly prohibited.</li>
            <li><strong>Operational Interaction Logs:</strong> Log entries including timestamp, call duration, and call status metadata generated via the application's workflow tools for lead management and customer relationship administration.</li>
            <li><strong>Verification Media:</strong> Facial verification images submitted during check-in authentication and document images uploaded for business verification procedures.</li>
            <li><strong>Device Telemetry & Performance Metrics:</strong> Technical metadata including device model, operating system version, app diagnostic logs, and push notification tokens necessary to maintain application security, stability, and message delivery.</li>
        </ul>

        <h2>4. Purposes of Data Processing</h2>
        <p>Collected data is processed exclusively for official business purposes, including but not limited to:</p>
        <ul>
            <li>Facilitating sales lead allocation, customer follow-up tracking, and pipeline management.</li>
            <li>Authenticating employee check-in/check-out, verifying field visits, and processing payroll-related attendance records.</li>
            <li>Transmitting critical operational notifications, workflow alerts, and system updates.</li>
            <li>Enforcing enterprise security standards, preventing unauthorized system access, and maintaining audit logs.</li>
        </ul>

        <h2>5. Data Security & Storage Architecture</h2>
        <p>We employ administrative, technical, and physical safeguards designed to protect personal and corporate data against unauthorized access, disclosure, alteration, or destruction. All data transmissions between the application and enterprise servers are secured using industry-standard Transport Layer Security (TLS/HTTPS) encryption. Access to stored data is restricted to authorized HR, managerial, and IT administrative personnel based on defined Role-Based Access Control (RBAC) principles.</p>

        <h2>6. Disclosure of Data to Third Parties</h2>
        <p><strong>Credlawn India Private Limited does not sell, lease, trade, or commercialize employee or workplace data.</strong> Information is disclosed to third-party service providers (such as cloud hosting and push notification delivery infrastructure) strictly to the extent necessary to operate the application. All such service providers operate under formal contractual data processing and confidentiality agreements.</p>

        <h2>7. Data Retention & Account Offboarding</h2>
        <p>User accounts and associated personal data are maintained for the duration of employment with Credlawn India Private Limited. Upon separation or termination of employment:</p>
        <ul>
            <li>Application access credentials are immediately revoked via administrative offboarding protocols.</li>
            <li>Operational work records (such as sales logs, interaction history, and attendance records) are retained in accordance with corporate governance requirements, statutory audit mandates, and legal compliance obligations.</li>
        </ul>

        <h2>8. Grievance Officer & Contact Information</h2>
        <div class="contact-box">
            <p style="margin-top:0;"><strong>Data Protection & HR Administration</strong></p>
            <p>For inquiries, access requests, or privacy concerns regarding this policy, please contact our administrative team at:</p>
            <p><strong>Credlawn India Private Limited</strong><br>
            Attention: Data Protection Officer / HR Administration<br>
            Corporate Email: <a href="mailto:info@credlawn.com">info@credlawn.com</a></p>
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
    <title>Account Offboarding & Data Governance Policy - Credlawn CRM</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; line-height: 1.65; color: #1f2937; max-width: 860px; margin: 0 auto; padding: 32px 20px; background-color: #f9fafb; }
        .container { background: #ffffff; padding: 48px; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.08); border: 1px solid #e5e7eb; }
        .header { border-bottom: 2px solid #e5e7eb; padding-bottom: 20px; margin-bottom: 28px; }
        h1 { color: #1e3a8a; font-size: 26px; font-weight: 700; margin: 0 0 8px 0; letter-spacing: -0.01em; }
        .company-name { font-size: 15px; color: #4b5563; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; }
        .doc-meta { font-size: 0.88em; color: #6b7280; margin-top: 6px; }
        h2 { color: #1e293b; margin-top: 32px; font-size: 18px; font-weight: 600; border-bottom: 1px solid #f1f5f9; padding-bottom: 6px; }
        p, li { color: #374151; font-size: 14.5px; }
        ul { padding-left: 22px; margin-bottom: 16px; }
        li { margin-bottom: 8px; }
        strong { color: #111827; }
        .notice-box { background-color: #f0f9ff; border-left: 4px solid #0284c7; padding: 16px 20px; border-radius: 4px; margin: 24px 0; }
        .notice-box p { margin: 0; color: #0369a1; font-size: 14px; font-weight: 500; }
        .contact-box { background-color: #f8fafc; border: 1px solid #e2e8f0; padding: 24px; border-radius: 8px; margin-top: 36px; }
        a { color: #2563eb; text-decoration: none; font-weight: 500; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="company-name">Credlawn India Private Limited</div>
            <h1>Account Offboarding & Data Governance Policy</h1>
            <div class="doc-meta">Document Reference: CIPL-SEC-POL-002 | Effective Date: July 1, 2026 | App: Credlawn CRM</div>
        </div>

        <div class="notice-box">
            <p><strong>Enterprise Notice:</strong> User accounts within Credlawn CRM are enterprise assets created exclusively for active personnel of Credlawn India Private Limited to conduct authorized corporate operations.</p>
        </div>

        <h2>1. Scope & Applicability</h2>
        <p>This policy details the framework for user account lifecycle management, access revocation, account deactivation, and data retention governance governing the <strong>Credlawn CRM</strong> mobile application operated by <strong>Credlawn India Private Limited</strong> ("Company", "we", "us").</p>

        <h2>2. Employment Account Provisioning</h2>
        <p>User accounts are provisioned by corporate IT Administration upon the commencement of employment or contractual service. An active account is required to execute assigned sales operations, log attendance, access workflow tools, and receive corporate communications.</p>

        <h2>3. Separation & Access Revocation Protocols</h2>
        <p>Upon an employee's resignation, retirement, contract conclusion, or employment separation:</p>
        <ul>
            <li><strong>Automated Access Revocation:</strong> Application access credentials and system authorization tokens are systematically revoked by HR and IT Administration as part of the mandatory corporate offboarding checklist.</li>
            <li><strong>Immediate Deactivation:</strong> Once deactivated, former personnel can no longer authenticate into the application or access corporate databases.</li>
        </ul>

        <h2>4. Account Deactivation & Deletion Requests</h2>
        <p>Former employees or authorized personnel wishing to verify the status of their account deactivation or submit inquiries regarding user data deletion may contact HR Administration or submit a formal written request via corporate email to <a href="mailto:info@credlawn.com">info@credlawn.com</a> providing their Full Name and Employee Identification Number.</p>

        <h2>5. Corporate Data Retention & Compliance</h2>
        <p>Operational data, customer interaction logs, attendance records, and transaction history created during the course of employment constitute proprietary corporate business records of Credlawn India Private Limited. Such data is preserved in accordance with enterprise record retention schedules, statutory audit requirements, and applicable legal mandates.</p>

        <h2>6. Governance & Support Contact</h2>
        <div class="contact-box">
            <p style="margin-top:0;"><strong>IT Administration & Data Governance</strong></p>
            <p>For questions regarding account offboarding, credential revocation, or enterprise data retention policies, please contact:</p>
            <p><strong>Credlawn India Private Limited</strong><br>
            Attention: HR & IT Compliance Division<br>
            Corporate Email: <a href="mailto:info@credlawn.com">info@credlawn.com</a></p>
        </div>
    </div>
</body>
</html>`
	return c.HTML(http.StatusOK, html)
}
