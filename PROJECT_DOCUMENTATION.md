# Credlawn CRM - Complete Project Documentation

**Version:** 2.7.0  
**Last Updated:** May 17, 2026  
**Purpose:** Production-ready AI guide for understanding the entire application

---

## Table of Contents
1. [Project Overview](#project-overview)
2. [Tech Stack](#tech-stack)
3. [Architecture Overview](#architecture-overview)
4. [Backend (PocketBase)](#backend-pocketbase)
5. [Frontend (Flutter)](#frontend-flutter)
6. [Database Schema](#database-schema)
7. [API Endpoints](#api-endpoints)
8. [Sync Strategy](#sync-strategy)
9. [Business Logic Flows](#business-logic-flows)
10. [Security & Authentication](#security--authentication)
11. [File Structure Reference](#file-structure-reference)

---

## Project Overview

Credlawn CRM is a comprehensive mobile application for managing employees, leads, attendance, and customer interactions in a sales/customer relationship management context. The system supports:

- **Multi-role access**: Employees, Managers, BH (Branch Head), HR
- **Lead Management**: Allocation, reallocation, shuffling, status tracking
- **Attendance Tracking**: GPS-based check-in/out with selfie verification
- **Call Logging**: Automatic call tracking integrated with leads
- **Performance Analytics**: Real-time dashboards and reports
- **Offline-first**: Full offline capability with background sync
- **Realtime Updates**: PocketBase realtime subscriptions

---

## Tech Stack

### Frontend
- **Framework**: Flutter 3.10+ (Dart 3)
- **Local Database**: Drift (SQLite) with type-safe queries
- **Backend Client**: PocketBase SDK (v0.23.0+1)
- **State Management**: Streams (Rx-style) with Drift watch queries
- **Networking**: Dio, PocketBase HTTP client
- **Notifications**: Firebase Cloud Messaging (FCM)
- **Location**: Geolocator, Geocoding
- **Camera/Image**: Image Picker, Google ML Kit (OCR)
- **Permissions**: Permission Handler
- **UI**: Material Design, Google Fonts, FL Chart

### Backend
- **Platform**: PocketBase (Go-based)
- **Database**: SQLite (embedded) with planned PostgreSQL support
- **Hooks**: Custom Go hooks for business logic
- **Cron**: Built-in PocketBase cron scheduler
- **File Storage**: Local filesystem (pb_data/files)
- **Realtime**: WebSocket-based realtime subscriptions

### Cloud Services
- **Firebase**: Cloud Messaging (FCM)
- **N8N**: Workflow automation webhook integration

---

## Architecture Overview

### High-Level Design
```
┌─────────────────┐
│   Flutter App   │
│  (Mobile Client)│
└────────┬────────┘
         │ HTTPS/WebSocket
         ▼
┌─────────────────┐
│   PocketBase    │
│   (Backend)     │
└─────────────────┘
```

### Offline-First Pattern
The app implements a robust three-layer sync strategy:

1. **Local First**: All CRUD operations write to local SQLite immediately
2. **Sync Pending Flag**: Records marked with `syncPending` need server upload
3. **Background Sync**: Automatic sync on connectivity change and app lifecycle
4. **Conflict Resolution**: Last-write-wins with timestamp comparison
5. **Realtime Subscriptions**: Push updates from server to local DB

### Sync Architecture
```
User Action → Local DB (syncPending=true) → Background Sync → Server
Server Update ← Realtime Subscription ← Server Push ← Database Change
```

---

## Backend (PocketBase)

### PocketBase Collections (Database Tables)

#### Core Collections
- **users**: Employee/user accounts with role-based access
- **database**: Central lead/customer data pool (raw data)
- **leads**: Assigned leads with status tracking
- **lead_allocation_history**: Full audit trail of lead assignments
- **attendance**: Employee attendance records
- **call_logs**: Call history linked to leads
- **case_login**: IP Approved/IP Decline tracking
- **holiday**: Holiday definitions
- **leave_requests**: leave applications
- **lead_feedback**: Status change feedback
- **vkyc_records**: Video KYC records
- **bkyc_records**: Bio KYC records
- **activation_records**: Activation tracking
- **apply_links**: Quick links for managers
- **webhook_settings**: N8N integration configuration

### Hook Files (pb_hooks/)

#### Initialization & Setup
- **main.go**: Registers all hooks and sets up PocketBase server
- **fcm_notification.go**: Firebase Cloud Messaging client initialization

#### API Endpoints (`OnServe().BindFunc`)
- **leads_api.go**: 
  - `GET /api/leads/stats` - Lead status statistics
  - `GET /api/leads/breakdown` - Employee-wise lead breakdown
- **employee_leads_api.go**: `GET /api/employees/with-new-leads` - Employees with new lead counts
- **dashboard_api.go**: `GET /api/dashboard/summary` - Dashboard summary data
- **employee_stats_api.go**: `GET /api/employee/stats` - Employee performance stats (IPA/IPD)
- **call_logs_api.go**:
  - `GET /api/call-logs/summary` - Daily call statistics
  - `GET /api/call-logs/detail` - Employee call details
  - `GET /api/call-logs/hourly` - Hourly call breakdown
- **leads_pivot_api.go**: `GET /api/leads/pivot` - Comprehensive analytics pivot
- **leads_sync.go**:
  - `POST /api/sync-leads-to-database` - Manual sync from leads to database
  - `POST /api/sync-call-stats` - Sync call statistics to database

#### Lead Allocation Hooks
- **lead_allocation.go**: `POST /api/allocate-leads` - Manual allocation from database to leads (random selection)
- **mobile_lead_allocation.go**: `POST /api/mobile/allocate-leads` - Mobile allocation with filters (new data only, excludes inactive)
- **lead_reallocation.go**: `POST /api/reallocate-leads` - Manual reallocation (exclude today's allocations)
- **mobile_reallocate_available.go**: Check reallocation availability
- **auto_lead_reallocation_cron.go**: `*/5 4-14 * * *` - Auto-reallocate every 5 min (10 AM - 8 PM IST)
  - Targets employees with ≤1 "New" leads
  - Priority: CNR (66.67%), Denied (33.33%)
  - Minimum 3 leads per employee, allocates up to 6
  - Uses multi-level priority groups based on allocation_count and days gap
- **lead_shuffle.go**:
  - `POST /api/shuffle-preview` - Preview eligible leads for shuffling
  - `POST /api/shuffle-leads` - Shuffle leads between employees
  - Uses RP (Recency Performance) score for prioritization
  - Eligible: CNR/Denied statuses, min age days, excludes recently allocated

#### Data Management Hooks
- **database_sync_cron.go**: `0 1 * * *` - Daily sync at 1 AM
  - Sync allocation counts from `lead_allocation_history`
  - Sync call log stats from `call_logs`
  - Sync lead status from `leads` or `lead_feedback`
  - Set `data_status = 'inactive'` based on business rules
- **database_count.go**: Count utilities
- **database_filters.go**: Filter building utilities
- **n8n_sync.go**: Batch sync to N8N webhook (asynchronous queue)
  - Webhook triggered based on `webhook_settings` collection
  - Batch processing every 5 seconds
  - Retry logic with exponential backoff

#### Business Process Hooks
- **create_case_login.go**: After lead create/update
  - Status "IP Approved" → creates `case_login` record with ARN date parsing
  - Status "IP Decline" → creates `case_login` record
  - Duplicate mobile check for login_type
- **send_ipa_notification.go**: After `case_login` create
  - Sends FCM notification to `ipa_notification` user group
  - Only for today's IP approvals, between 9 AM - 8 PM IST
- **active_employee.go**: Employee active status logic
- **disable_user.go**: Auth hooks to prevent disabled users from logging in
- **set_call_count.go**: Update call count utility
- **call_logs_api.go**: Call logs analytics (already covered)

#### Cron Jobs Summary
| Job | Schedule | Purpose |
|-----|----------|---------|
| `database_sync` | Daily 1 AM | Sync aggregated data to database collection |
| `auto_lead_reallocation` | Every 5 min (10 AM-8 PM) | Auto-assign leads to employees with low lead count |

---

## Frontend (Flutter)

### Project Structure

```
lib/
├── main.dart                    # App entry point, initialization, routing
├── core/
│   └── pb_api.dart              # PocketBase wrapper with persistence & device headers
├── database/
│   ├── app_database.dart        # Drift database definition (schema)
│   ├── app_database.g.dart      # Generated code (DO NOT EDIT)
│   └── tables/
│       ├── call_logs_table.dart
│       └── login_cases_table.dart
├── models/
│   ├── attendance_record.dart
│   ├── dashboard_summary.dart
│   ├── employee_performance.dart
│   ├── login_case_model.dart
│   ├── profile_model.dart
│   └── ... (other UI models)
├── screens/                      # 50+ screens organized by feature
│   ├── login_screen.dart
│   ├── employee_dashboard.dart
│   ├── manager_dashboard.dart
│   ├── bh_dashboard_screen.dart
│   ├── hr_dashboard.dart
│   ├── allocate_leads_screen.dart
│   ├── leads_detail_screen.dart
│   ├── attendance_detail_screen.dart
│   └── ... (many more)
├── services/                     # 25+ business logic services
│   ├── lead_service.dart        # Core lead sync (offline-first)
│   ├── attendance_service.dart  # Attendance with GPS & selfie
│   ├── call_log_service.dart    # Call log scanning & sync
│   ├── employee_service.dart    # Employee management
│   ├── auth_service.dart        # Authentication
│   ├── fcm_service.dart         # Push notifications
│   ├── device_registration_service.dart
│   ├── profile_service.dart
│   ├── dashboard_analytics_service.dart
│   ├── lead_feedback_service.dart
│   ├── leave_service.dart
│   ├── holiday_service.dart
│   ├── login_case_service.dart
│   ├── apply_link_service.dart
│   ├── version_service.dart
│   ├── device_info_service.dart
│   ├── app_version_service.dart
│   ├── permission_service.dart
│   ├── native_camera_service.dart
│   ├── vkyc_service.dart
│   └── bkyc_service.dart
├── utils/                        # Helper utilities
│   ├── activation_share_util.dart
│   ├── bkyc_share_util.dart
│   ├── employee_filter_utils.dart
│   ├── ocr_helper.dart
│   ├── proper_case_text_formatter.dart
│   └── uppercase_text_formatter.dart
├── widgets/                      # Reusable UI components
│   ├── activity_list_item.dart
│   ├── allocate_mode_selection_dialog.dart
│   ├── analytics_skeleton_loader.dart
│   ├── approval_rate_bar.dart
│   ├── call_logs_card.dart
│   ├── date_of_birth_picker.dart
│   ├── follow_up_picker.dart
│   ├── hr/
│   │   ├── approve_employee_dialog.dart
│   │   ├── confirm_trainee_dialog.dart
│   │   ├── employee_card.dart
│   │   └── reject_trainee_dialog.dart
│   ├── login_case_card.dart
│   ├── manager/
│   │   ├── attendance_card.dart
│   │   ├── data_usage_card.dart
│   │   └── overview_card.dart
│   ├── metric_card.dart
│   ├── quick_stat_card.dart
│   ├── section_header.dart
│   ├── update_dialog.dart
│   └── weekly_trend_chart.dart
└── assets/
    └── images/                   # App icons, splash, logos
```

### Core Components

#### main.dart
- **Initialization** (parallel):
  - Firebase
  - PocketBase (token restore)
  - LeadService database
  - DeviceInfoService
  - AppVersionService
  - FCMService
  - DeviceRegistrationService
- **Start Screen Logic**: Determined by auth state + role + password reset flag
- **Global Auth Monitor**: Auto logout on token invalidation
- **Connectivity Monitor**: Triggers silent verification on network restore
- **App Lifecycle**: Background sync on resume, periodic call log scan
- **Realtime Subscriptions**: Lead updates, user status changes
- **Background Jobs**: 
  - Silent verification (every app resume)
  - Data sync orchestration (parallel syncUp/syncDown)
  - Update checks
  - Call log background scan (30s delayed)

#### pb_api.dart - PocketBase Wrapper
```dart
class PB {
  static final PocketBase pb = PocketBase('http://192.168.29.184:8090');
  
  static Future<void> init() // Token persistence
  
  static Future<void> logout() // Clear auth + FCM + profile
  
  static void handleAuthError(e) // Auto logout on 401/403
  
  static Future<Map<String, String>> getDeviceHeaders()
  // Returns: X-Device-Id, X-Device-Model, X-Android-Version
}
```

**Security**: Device binding via headers; account can be registered to only one device at a time.

---

## Database Schema

### Frontend Local Database (Drift/SQLite)

#### Tables

**Leads** (lib/database/tables/call_logs_table.dart - actually leads_table.dart is implied but not in the list)
- `id` (PK)
- `customer_name`, `mobile_no`, `city`, `segment`, `employer`
- `decline_reason`, `product`, `arn_no`, `date_of_birth`, `remarks`
- `assigned_to`, `assigned_date`, `employee_name`, `employee_code`
- `lead_status` (New, Called, CNR, Denied, IP Approved, etc.)
- `lead_status_date`
- `data_status` (new, used, inactive)
- `followup_time`
- `syncPending` (boolean, default false)

**CallLogs** (call_logs_table.dart)
- `id` (PK)
- `lead_id`, `employee_id`, `employee_code`, `employee_name`
- `phone_number`
- `call_timestamp`, `call_duration`, `ring_duration`, `session_duration`
- `call_type` (incoming/outgoing/missed), `call_status`
- `isSynced`

**Attendance** (app_database.dart lines 11-34)
- `id` (PK)
- `employee_id`, `employee_code`, `employee_name`
- `attendance_date` (date only)
- `check_in_time`, `check_in_selfie`, `check_in_latitude`, `check_in_longitude`
- `check_out_time`, `check_out_selfie`, `check_out_latitude`, `check_out_longitude`
- `address`
- `status`, `remarks`, `approval_type`
- `syncPending`

**LoginCases** (login_cases_table.dart)
- `id` (PK)
- `mobile_number`, `customer_name`, `lead_status`, `lead_status_date`
- `date_of_birth`, `arn_no`
- `employee_name`, `employee_code`
- `lead_id`, `user`, `login_type`

**LeaveRequests**
- `id`, `employee_id`, `employee_code`, `employee_name`
- `leave_type`, `from_date`, `to_date`, `days_count`
- `reason`, `status`, `applied_date`, `syncPending`

**Holidays**
- `id`, `holiday_name`, `holiday_date`, `active`

**LeadFeedback**
- `id`, `lead_id`, `customer_name`, `mobile_no`
- `lead_status`, `lead_status_date`, `status_update_time`
- `user`, `employee_name`, `employee_code`
- `isSynced`

**ApplyLinks**
- `id`, `link_name`, `link_url`, `is_default`

**VkycRecords** & **BkycRecords** & **ActivationRecords**
- Full audit trails for verification processes
- Fields: customer_name, mobile_no, arn_no, statuses, dates, syncPending

---

## API Endpoints

### Backend APIs (PocketBase Custom Routes)

#### Lead Management
```
GET  /api/leads/stats?filter=<date_filter>
GET  /api/leads/breakdown?status=<status>&filter=<date_filter>
GET  /api/leads/pivot?date=<YYYY-MM-DD>&filter_type=<today|yesterday>&employee_code=<code>

POST /api/allocate-leads
POST /api/mobile/allocate-leads
POST /api/reallocate-leads
POST /api/mobile/reallocate-leads
POST /api/shuffle-preview
POST /api/shuffle-leads
POST /api/sync-leads-to-database

GET  /api/employees/with-new-leads
```

#### Dashboard & Analytics
```
GET  /api/dashboard/summary
GET  /api/employee/stats?filter=<date_filter>
GET  /api/call-logs/summary?date=<YYYY-MM-DD>
GET  /api/call-logs/detail?date=<YYYY-MM-DD>
GET  /api/call-logs/hourly?employee_code=<code>&date=<YYYY-MM-DD>
```

#### Sync Operations
```
POST /api/sync-leads-to-database
POST /api/sync-call-stats
```

**Note**: All endpoints require authentication. Role-based checks enforced in hooks.

---

## Sync Strategy

### Three-Layer Sync Architecture

#### Layer 1: Local Write (Immediate)
- User action → Drift DB (with `syncPending = true`)
- UI updates instantly from local stream
- No network wait

#### Layer 2: Background Upload (Async)
- Triggered on:
  - App launch after login
  - Connectivity restored
  - App resume
  - Periodic timer (LeadService: batch sync for high-frequency events)
- `syncUp()`: Upload pending leads/attendance/feedback
- `syncDown()`: Pull server changes and reconcile

#### Layer 3: Realtime Push (Real-time)
- PocketBase realtime subscriptions
- Instant server→client updates for:
  - Lead status changes
  - New lead assignments
  - User disable events
- Batch processing for high-frequency events (e.g., rapid lead updates)

### Sync Rules by Service

**LeadService**:
- Downsync: Pull all leads assigned to current user (`assigned_to = user.id`)
- Delete local leads that exist on server but not in server response (unless `syncPending`)
- Stuck pending leads (>2 days) considered permanent error and deleted
- Realtime subscription: `leads` collection with `*` filter
- Batch sync threshold: 5 events within 3 seconds

**AttendanceService**:
- Check-in creates local record with temp UUID, selfie saved locally
- Sync creates server record, gets server ID, deletes local temp, inserts server record with selfie URL
- Check-out updates server with selfie
- Download: `attendance` with `remove_data = false` filter
- Schema mismatch wipe-and-retry for backwards compatibility

**CallLogService**:
- Background Android service scans call log
- Deduplication: phone number + ±1 min window + exact duration
- Realtime call logger via MethodChannel from native code
- Upload with 3 retries

**LeadFeedbackService**:
- Every status change creates feedback record
- Send feedback when lead status updates

### Conflict Resolution
- **Timestamp-based**: `lead_status_date` comparison
- **Last-write-wins** for concurrent updates
- **Lock mechanism**: `syncPending` prevents overwriting uncommitted changes

---

## Business Logic Flows

### Lead Allocation Flow

**Manual Allocation (Web/Mobile)**
1. Manager selects records from `database` collection (filtered by custom_code, data_code, data_sub_code, decline_reason)
2. Records allocated randomly to employees in specified count
3. For each record:
   - Check if mobile already exists in `leads` → skip if exists
   - Find user by `employee_code`
   - Create lead in `leads` collection with status "New"
   - Create `lead_allocation_history` with allocation_type="new_allocation"
   - Update `database` record:
     - `allocation_count += 1`
     - `employee_count = distinct(allocated_to_code)`
     - `data_status = 'used'`

**Auto Reallocation (Cron - Every 5 min)**
1. Find eligible employees:
   - Role: employee or manager
   - `disabled = false`, `no_atn = false`
   - `stop_auto_leads IS NULL OR false`
   - Has attendance today (checked in)
   - New lead count ≤ 1
2. For each employee, allocate 6 leads:
   - Priority pool: CNR (allocation_count 1-5, 3 groups by days gap: 1,2,3)
   - Secondary: Denied (same grouping)
   - 4 CNR + 2 Denied (67%/33% ratio)
   - Minimum threshold: 3 leads (skip if <3 available)
   - Allocate to oldest by `lead_status_date`
3. Each allocation:
   - Create lead if not exists
   - Update `database.lead_status = 'New'`, `lead_status_date = NOW`
   - Create history with allocation_type="reallocation"
   - Increment `allocation_count` and `employee_count`
   - Set `data_status='used'`

**Shuffle (Manual)**
1. Get eligible leads:
   - Status: CNR or Denied (configurable)
   - `lead_status_date` < (now - min_age_days)
   - Filter by allocation_count, employee_count (optional)
2. Calculate RP Score for each lead:
   ```
   RP = (days_since * 10) + (10 - connected_calls * 2) - (duration_minutes)
   ```
3. Sorted by RP descending
4. For each target employee:
   - Skip leads previously allocated to them
   - Skip leads currently assigned to them
   - Allocate in sorted order
   - Update `shuffle_count += 1` on database record
   - Set `data_status='inactive'` if:
     - Status is IP Approved/IP Decline, OR
     - Denied with employee_count >= 3, OR
     - CNR with (employee_count >= 3 OR total_calls >= 10)
5. Create history with allocation_type="shuffle"

### Attendance Flow

**Check-in**:
1. Request location permission + GPS accuracy (30s timeout)
2. Get current location (latitude, longitude)
3. Reverse geocode to address
4. Capture selfie via camera
5. Save to local `attendance` table (syncPending=true)
6. Start foreground service (Android) for location tracking
7. Sync to server (multipart upload with selfie)
8. On success: Replace local record with server record (server ID + selfie URL)
9. Delete local selfie file

**Check-out**:
1. Find today's check-in record
2. Capture checkout selfie
3. Update local record with checkout time + selfie
4. Sync to server (multipart with checkout selfie if exists)
5. On success: Update local record with server URL

**Status Calculation** (server-side via cron, client-side for display):
- **Present/Late**: Compare check-in time vs `office_start_time` (default 10:15 AM)
- **Holiday**: Check `holiday` table
- **On Leave**: Check `leave_requests` with status='approved' overlapping date
- **Absent**: None of the above

### Call Log Flow

**Background Scanning** (Android):
- Android JobService runs every 15 minutes (configurable)
- Reads system call log
- Filters: Outgoing calls, duration > 0, assigned employee (via phone→lead→employee mapping)
- Group by (phone_number, timestamp_seconds, duration, employee_code) for deduplication
- Save to local `call_logs` with `isSynced=false`
- Trigger realtime sync

**Real-time Call Logger** (During call):
- Native Android service monitors call state
- On call end, send event to Flutter via MethodChannel
- Includes: leadId, employee info, timestamps, durations
- Save to local DB (same deduplication logic)
- Sync to server with 3 retries

**Analytics**:
- Deduplication: Group by phone + timestamp_second + duration + employee
- Summary: present count, total calls, total duration, avg/hour (10 AM-7 PM)
- Hourly breakdown: 11 AM-7 PM (display) showing 10 AM-6 PM data

---

## Security & Authentication

### Authentication Flow
1. **Login**: Email/username + password with device headers
2. **Device Binding**: First login binds account to device (device_id stored in user profile)
   - Account can only be active on ONE device at a time
   - Subsequent logins from other devices rejected
3. **Token Refresh**: PocketBase JWT with refresh endpoint
4. **Session Validation**:
   - App startup: `authRefresh` with device headers
   - Check `disabled` flag → logout if true
   - Check `must_change_password` → redirect to change password
   - On auth errors (401/403) → auto logout

### Role-Based Access Control

**Roles** (stored in `users.role`):
- `Employee`: Can view own leads, log attendance, make calls
- `Manager`: Can allocate/reallocate/shuffle leads, view all employee data
- `BH` (Branch Head): Similar to manager + approvals
- `HR`: Employee management, leave approvals, holiday management
- `Admin`: Full access

**Enforcement**:
- Frontend: Route guards based on role
- Backend: Role checks in hook handlers (e.g., `if role != 'manager' return 403`)

### Data Security
- **Device Headers**: `X-Device-Id`, `X-Device-Model`, `X-Android-Version` sent with all API calls
- **Device ID**: Generated from `android_id` or device info, stored in SharedPreferences
- **One-Device-Per-Account**: Enforced by backend hooks, prevents multiple simultaneous logins
- **Disabled User Check**: Auth hooks reject login if `disabled = true`

---

## File Structure Reference

### Backend Files (pb_hooks/)

| File | Purpose | Key Functions | Endpoints/Triggers |
|------|---------|---------------|-------------------|
| main.go | App bootstrap | Register all hooks | PocketBase server start |
| leads_api.go | Lead analytics | `handleLeadsStats`, `handleLeadsBreakdown` | `/api/leads/stats`, `/api/leads/breakdown` |
| employee_leads_api.go | Employee lead counts | `handleEmployeeLeads` | `/api/employees/with-new-leads` |
| dashboard_api.go | Dashboard summary | `handleDashboardSummary` | `/api/dashboard/summary` |
| call_logs_api.go | Call analytics | `handleCallLogsSummary`, `handleCallLogsDetail`, `handleCallLogsHourly` | `/api/call-logs/*` |
| leads_pivot_api.go | Pivot analytics | `handleLeadsAnalytics` | `/api/leads/pivot` |
| lead_allocation.go | Manual allocation | Process allocation | `/api/allocate-leads` |
| mobile_lead_allocation.go | Mobile allocation | Allocate with filters | `/api/mobile/allocate-leads` |
| lead_reallocation.go | Manual reallocation | Reallocate leads | `/api/reallocate-leads` |
| mobile_reallocate_available.go | Reallocation check | Query params | `/api/mobile/reallocate-available` |
| lead_shuffle.go | Shuffle leads | Shuffle with RP score | `/api/shuffle-preview`, `/api/shuffle-leads` |
| leads_sync.go | Data sync | Sync leads→database, call stats | `/api/sync-leads-to-database`, `/api/sync-call-stats` |
| database_sync_cron.go | Daily cron | Sync aggregated data, set inactive | `0 1 * * *` |
| auto_lead_reallocation_cron.go | Auto-reallocation | Allocate 6 leads to low-count employees | `*/5 4-14 * * *` |
| n8n_sync.go | Webhook integration | Batch sync to N8N | On record create/update/delete |
| create_case_login.go | Case creation | Auto-create case_login for IP Approved/Decline | `OnRecordAfterCreateSuccess("leads")` |
| send_ipa_notification.go | IPA celebration | Send FCM on IP approval | `OnRecordAfterCreateSuccess("case_login")` |
| disable_user.go | Auth guard | Block disabled users | `OnRecordAuthRequest`, `OnRecordAuthRefreshRequest` |
| fcm_notification.go | Firebase init | `InitFirebase`, `SendNotification` | Used by other hooks |

### Frontend Files by Category

#### Core
- **main.dart**: App lifecycle, auth monitoring, background sync orchestration, routing
- **core/pb_api.dart**: PocketBase singleton, token persistence, device headers

#### Database
- **database/app_database.dart**: Drift database with 11 tables, schema version 22, migration strategy
- **database/tables/**: Individual table definitions

#### Models (UI Data Structures)
- Simple DTOs with `fromJson` factory methods
- Examples: `EmployeePerformance`, `DashboardSummary`, `AttendanceRecord`, `LoginCaseModel`

#### Services (Business Logic)
```dart
// Key Services (ordered by criticality)
LeadService              // Lead sync, subscriptions (454 lines)
AttendanceService        // Check-in/out with GPS (997 lines)
CallLogService           // Call scanning & sync (438 lines)
EmployeeService          // Employee CRUD, code generation (331 lines)
AuthService              // Simple login wrapper (24 lines)
FCMService               // Firebase notifications (156 lines)
DeviceRegistrationService // Device info + token (76 lines)
ProfileService           // User profile management
DashboardAnalyticsService // Dashboard data aggregation
LeadFeedbackService      // Feedback tracking
LeaveService             // Leave management
HolidayService           // Holiday sync
LoginCaseService         // Case login sync
ApplyLinkService         // Quick links
VersionService           // App version checks
DeviceInfoService        // Device metadata
AppVersionService        // Version tracking
PermissionService        // Permission status collection
NativeCameraService      // Camera operations
VkycService              // Video KYC
BkycService              // Bio KYC
```

Each service typically includes:
- `init()` static method for initialization
- `syncUp()` and `syncDown()` for offline sync
- Realtime subscriptions where needed
- Helper methods for specific operations

#### Screens (UI Pages)
- **Auth**: `login_screen.dart`, `change_password_screen.dart`, `permission_screen.dart`
- **Employee**: `employee_dashboard.dart`, `employee_detail_screen.dart`, `employee_list_screen.dart`
- **Manager**: `manager_dashboard.dart`, `manager/` subfolder specialized screens
- **BH**: `bh_dashboard_screen.dart`
- **HR**: `hr_dashboard.dart`, `hr/` dialogs
- **Lead Management**: 10+ screens (allocation, detail, pivot, feedback history, etc.)
- **Attendance**: Multiple screens (detail, history, certification)
- **BKYCVKYC**: `bkyc_screen.dart`, `vkyc_screen.dart`, `ipa_detail_screen.dart`
- **Utilities**: `profile_screen.dart`, `import_screen.dart`, `field_mapping_screen.dart`

#### Widgets (Reusable Components)
- Generic: `metric_card.dart`, `quick_stat_card.dart`, `call_logs_card.dart`, `weekly_trend_chart.dart`
- Manager-specific: `manager/attendance_card.dart`, `manager/overview_card.dart`, `manager/data_usage_card.dart`
- HR-specific: `hr/employee_card.dart`, `hr/approve_employee_dialog.dart`, etc.

#### Utils
- `ocr_helper.dart`: Text recognition from images
- `employee_filter_utils.dart`: Employee filtering logic
- `activation_share_util.dart`, `bkyc_share_util.dart`: Sharing utilities
- `proper_case_text_formatter.dart`, `uppercase_text_formatter.dart`: Input formatters

---

## Key Configuration

### pubspec.yaml
- **SDK**: Flutter ^3.10.0, Dart ^3.10.0
- **Critical Dependencies**:
  - `pocketbase:^0.23.0+1` - Backend client
  - `drift:^2.24.2` + `sqlite3_flutter_libs` - Local DB
  - `firebase_core:^4.2.1`, `firebase_messaging:^16.0.4` - Notifications
  - `connectivity_plus:^7.0.0` - Network monitoring
  - `permission_handler:^12.0.1` - Permissions
  - `geolocator:^14.0.2`, `geocoding:^4.0.0` - Location
  - `call_log:^6.0.1` - Call history
  - `google_mlkit_text_recognition:^0.15.0` - OCR
- **Version**: 2.7.0+1

### Build Configuration
- **Android**: Custom MainActivity with CallLog JobService, location services
- **iOS**: Standard Flutter setup, additional permissions in Info.plist
- **Assets**: `assets/images/` for icons and splash

### Environment
- Current backend URL: `http://192.168.29.184:8090` (local testing)
- **To switch to production**: Change in `pb_api.dart` line 11-12

---

## Production Readiness Checklist

Based on documentation analysis, see separate `PRODUCTION_SUGGESTIONS.md` for detailed recommendations.

### Critical Items
1. ✅ Offline-first architecture (implemented)
2. ✅ Realtime updates (implemented)
3. ✅ Security: Device binding (implemented)
4. ⚠️ Error handling: Add more granular exception handling
5. ⚠️ Monitoring: Add crash reporting (Firebase Crashlytics recommended)
6. ⚠️ Testing: No visible unit/integration tests
7. ⚠️ Secrets: Firebase key in repo (should be in env)
8. ⚠️ Scaling: Backend SQLite may not scale for production
9. ⚠️ CI/CD: No visible pipeline configuration
10. ⚠️ Code Quality: Some files very long (attendance_service.dart:997 lines)

---

## Conclusion

This documentation provides a comprehensive understanding of the Credlawn CRM application. For production deployment:

1. Update backend URL to production PocketBase instance
2. Migrate backend from SQLite to PostgreSQL
3. Implement proper secrets management
4. Add monitoring and alerting
5. Conduct load testing
6. Set up CI/CD pipelines
7. Implement comprehensive test suite

The codebase is well-structured with clear separation of concerns, robust offline capabilities, and sophisticated business logic for lead management and attendance tracking.

---

**Document Generated**: May 17, 2026  
**Files Analyzed**: 150+  
**Lines of Code Reviewed**: ~15,000+
