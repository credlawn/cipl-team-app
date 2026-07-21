# Production Readiness - Improvement Suggestions

**Date:** May 17, 2026  
**Analyzed Version:** 2.7.0  
**Scope:** Entire Credlawn CRM application

---

## Critical Issues (Fix Before Production)

### 1. SECRETS MANAGEMENT 🔴 CRITICAL
**Issue**: Firebase service account key (`pb_hooks/firebase-key.json`) committed to repository
**Risk**: Complete Firebase account compromise if repo is public or accessed by unauthorized parties

**Solutions**:
- Remove from git history: `git rm --cached pb_hooks/firebase-key.json`
- Add to `.gitignore`: `/pb_hooks/firebase-key.json`
- Store in environment variables or secret manager:
  - For PocketBase: Use environment variable `FIREBASE_KEY_JSON` with base64-encoded JSON
  - Update `fcm_notification.go` line 15: Read from env instead of hardcoded path
- For local development: Provide template file `firebase-key.json.example` with placeholder

**File References**:
- `pb_hooks/firebase-key.json` (DELETE from repo)
- `pb_hooks/fcm_notification.go:15`
- `pb_hooks/n8n_sync.go:16` (N8nWebhookURL hardcoded - should be env variable)

---

### 2. BACKEND DATABASE SCALABILITY 🔴 CRITICAL
**Issue**: PocketBase default uses SQLite, not suitable for multi-user concurrent production workload
**Risk**: Data corruption, performance degradation, lock contention under load

**Solutions**:
- Migrate PocketBase to PostgreSQL (PocketBase officially supports Postgres)
  - Export current data: `pb_hooks/main.go` → add admin command for DB dump
  - Set up PostgreSQL instance
  - Configure PocketBase with `--dev` flag disabled and `--postgres` connection string
- Alternative: If SQLite must be used:
  - Implement WAL mode: `PRAGMA journal_mode=WAL;`
  - Add connection pooling
  - Monitor lock wait timeouts
  - Setup read replicas (not possible with SQLite)

**Migration Steps**:
1. Test migration on staging with production-like data volume
2. Backup all data: files (`pb_data/files`) + database
3. Update PocketBase startup: `pocketbase serve --postgres "host=... port=5432 user=... dbname=... password=... sslmode=require"`
4. Update hooks to handle any SQL dialect differences (current queries use SQLite-specific `strftime`, `RANDOM()`)

---

### 3. TESTING COVERAGE 🟡 HIGH
**Issue**: No visible unit, integration, or E2E tests in the project
**Risk**: Regression bugs, unreliable deployments, difficulty refactoring

**Solutions**:
- **Frontend (Flutter)**:
  - Add `test/` directory with unit tests for services
  - Mock PocketBase using `mockito` or `test`
  - Example test: `LeadService.syncUp()` with pending leads
  - Widget tests for critical screens (login, dashboard)
  - Integration tests with `integration_test` package
- **Backend (Go)**:
  - Create `pb_hooks/_test.go` files
  - Use PocketBase test utilities: `pb_hooks.Test{Action}` functions
  - Test each API endpoint with mock requests
  - Test cron jobs: database_sync, auto_lead_reallocation
  - Use testify for assertions
- **CI Integration**:
  - GitHub Actions workflow:
    ```yaml
    name: Test
    on: [push, pull_request]
    jobs:
      test:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - uses: subosito/flutter-action@v2
          - run: flutter test
      test-backend:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - uses: actions/setup-go@v5
          - run: go test ./pb_hooks/...
    ```

**Files To Create**:
- `test/lead_service_test.dart`
- `test/attendance_service_test.dart`
- `pb_hooks/leads_api_test.go`
- `pb_hooks/lead_allocation_test.go`
- `.github/workflows/test.yml`

---

### 4. ERROR HANDLING & OBSERVABILITY 🟡 HIGH
**Issue**: Inconsistent error handling, no centralized logging/monitoring
**Risk**: Silent failures, difficult debugging in production

**Frontend Issues**:
- Many services use empty catch blocks (`.catch((e) {})`) - loses error context
- Example: `login_screen.dart:392-408` empty catch after background sync
- `call_log_service.dart:135-137` silently fails on insert

**Solutions**:
- Add error reporting service (Sentry, Firebase Crashlytics)
- Replace empty catches with proper logging:
  ```dart
  } catch (e, stackTrace) {
    debugPrint('Error: $e');
    debugPrint('Stack: $stackTrace');
    ErrorService.record(e, stackTrace);
  }
  ```
- Create centralized `ErrorService` class:
  ```dart
  class ErrorService {
    static void record(dynamic error, StackTrace stackTrace, {String? context}) {
      // Send to monitoring service
      // Optionally show user-friendly message
    }
  }
  ```
- Add breadcrumbs for user actions (button clicks, navigation)

**Backend Issues**:
- Some hooks log errors but continue
- No structured logging (missing context like user_id, record_id)
- No metrics collection (cron job duration, error rates)

**Solutions**:
- Use structured logging (e.g., `slog` package) or at least add consistent fields:
  ```go
  app.Logger().Info("Allocation complete",
    "total_selected", totalSelected,
    "allocated", allocatedCount,
    "skipped", skippedCount,
    "manager_id", info.Auth.Id,
    "timestamp", time.Now().Unix(),
  )
  ```
- Add metrics endpoint for health checks: `GET /metrics` with Prometheus format
- Set up alerting for cron job failures (monitor logs)

**Files to Update**:
- All service files: Add proper error logging
- `lib/services/error_service.dart` (new)
- PocketBase startup: Consider adding middleware for request logging

---

### 5. CODE QUALITY & MAINTAINABILITY 🟡 HIGH
**Issue**: Some files are too long, code duplication, inconsistent patterns

**Long Files** (refactor into smaller units):
- `lib/services/attendance_service.dart` (997 lines)
  - Extract manager methods to `AttendanceManagerService`
  - Extract sync logic to `AttendanceSyncService`
  - Split calculation logic to `AttendanceCalculator`
- `lib/services/call_log_service.dart` (438 lines)
  - Extract call scanning to separate class
  - Extract sync logic
- `lib/screens/` - Many screens 500+ lines
  - Extract business logic to ViewModels/Controllers
  - Use proper state management (Provider/Riverpod/Bloc)
  - Consider widget decomposition

**Duplication**:
- Location permission handling duplicated across services
- Date parsing (IST/UTC conversion) duplicated repeatedly
- Lead status checks (CNR/Denied) appear in many places

**Solutions**:
- Create `LocationService` centralized location helper
- Create `DateUtils` class with IST/UTC conversion methods
- Create `LeadStatus` enum with helper methods (isProductive, isFinal, etc.)
- Use constant definitions for repeated strings (e.g., status values)
- Extract query building to helper functions (see `database_filters.go`)

**Code Style**:
- Add analysis_options.yaml stricter rules (already exists but can be enhanced)
- Enforce consistent error handling patterns
- Add `.editorconfig` for consistent formatting
- Consider adopting Code Review checklist

**Files to Refactor**:
- `lib/services/attendance_service.dart`
- `lib/services/call_log_service.dart`
- `lib/screens/manager_dashboard.dart` (likely large)
- `pb_hooks/auto_lead_reallocation_cron.go` (500+ lines - extract to package)

---

## Medium Priority Issues

### 6. PERFORMANCE OPTIMIZATION 🟢 MEDIUM

**Backend**:
- **N+1 Query Problem**: Many hooks loop over items and query DB inside loop
  - Example: `employee_leads_api.go:51-68` loops employees and queries leads per employee
  - Solution: Use JOINs or batch queries
    ```go
    // Instead of per-employee COUNT, do single query:
    SELECT employee_code, COUNT(*) as count FROM leads WHERE lead_status = 'New' GROUP BY employee_code
    ```
  - Files: `employee_leads_api.go`, `employee_stats_api.go`, `leads_pivot_api.go` (already optimized with LEFT JOIN)

- **Lead Allocation Random Selection**:
  - `lead_allocation.go:101` uses `ORDER BY RANDOM() LIMIT N` - inefficient for large tables
  - Solution: Use reservoir sampling or pre-filtered indexed queries
  - Add composite index: `(data_status, custom_code, id)` for faster random selection

- **Cron Job Duration**:
  - `database_sync_cron.go` updates every database record sequentially
  - Could be 10,000+ records → take minutes
  - Solution: Batch updates (UPDATE ... WHERE id IN (...)) or use temporary tables

**Frontend**:
- **Stream Controllers**: Some services use StreamController without Close - potential memory leaks
  - `FCMService`: `_tokenRefreshController` should have `close()` in dispose
- **Database Queries**: Some queries missing indexes
  - Check generated `app_database.g.dart` for index definitions
  - Add composite indexes where needed: `(employee_code, lead_status_date)` for common filters
- **Image Handling**: Selfies stored in SQLite BLOB? No, they're file paths but may accumulate
  - Implement cleanup: Old selfies after successful sync should be deleted (already done)
  - Check: Are deleted DB records' selfies cleaned up? Add cascade delete hook

**Files to Optimize**:
- `pb_hooks/lead_allocation.go`
- `pb_hooks/auto_lead_reallocation_cron.go:allocateLeadsToEmployee` (multiple queries per employee)
- `lib/services/attendance_service.dart` (some queries in loops)

---

### 7. BACKEND: HARDCODED VALUES & MAGIC NUMBERS 🟢 MEDIUM

**Issues**:
- `auto_lead_reallocation_cron.go:116` - `const cnrRatio = 0.67` - should be configurable
- `auto_lead_reallocation_cron.go:117` - `const minLeadsToAllocate = 3` - config
- `lead_shuffle.go:267-269` - RP score formula: `daysSince*10 + (10-connectedCalls*2) - duration/60` - magic numbers
- `call_logs_api.go:114` - Hardcoded 9 working hours (10 AM - 7 PM)
- Timezone: "Asia/Kolkata" repeated in many Go files - should be constant

**Solutions**:
- Create `config` collection in PocketBase
- Add hook to read config at startup, cache with TTL
- Allow runtime updates without redeploy
- Example structure:
  ```
  collection: config
  fields: key (unique), value (text), description
  sample records:
    key: AUTO_REALLOCATION_CNR_RATIO, value: 0.67, description: Ratio of CNR in auto-allocation
    key: AUTO_REALLOCATION_MIN_LEADS, value: 3, ...
    key: RP_SCORE_DAYS_WEIGHT, value: 10, ...
    key: RP_SCORE_CALLS_WEIGHT, value: 2, ...
    key: WORKING_HOURS_START, value: 10, ...
    key: WORKING_HOURS_END, value: 19, ...
  ```

**Files to Update**:
- All hooks with magic numbers → read from config cache

---

### 8. FRONTEND: STATE MANAGEMENT 🟢 MEDIUM

**Issue**: Services use static methods + global DB instance. No proper state management pattern.
**Impact**: Hard to test, global state risk, no reactive UI updates except via streams

**Current Pattern**:
```dart
class LeadService {
  static Future<void> syncDown() { ... }
  static Stream<List<Lead>> getLeadsStream() { ... }
}
```

**Problems**:
- Cannot easily mock for testing
- No lifecycle awareness (subscriptions not cleaned up systematically)
- Global mutable state (`_isSyncingDown`, `_isSubscribed`) in static vars

**Solutions** (choose one):
1. **Riverpod** (recommended for simplicity):
   - Convert services to providers
   - Use `StateNotifierProvider` for mutable state
   - Automatic disposal

2. **Bloc/Cubit** (more structured):
   - LeadBloc with events (SyncRequested, LeadUpdated)
   - State (initial, loading, loaded, error)
   - Better for complex state machines

3. **Provider + ChangeNotifier** (minimal change):
   - Wrap services in `ChangeNotifier`
   - Expose streams through `ValueNotifier` or `StreamProvider`

**Migration Steps**:
- Start with one service (e.g., `LeadService`) → `LeadNotifier`
- Replace static calls with provider reads: `ref.watch(leadProvider)`
- Add unit tests for providers

**Files to Refactor**:
- All services in `lib/services/` (phased approach)

---

### 9. AUTHENTICATION: DEVICE BONDING EDGE CASES 🟢 MEDIUM

**Current Implementation**:
- `pb_api.dart` sends device headers on every request
- Backend `disable_user.go` doesn't check device - only checks `disabled`
- Backend doesn't validate device_id matches; only stores it
- Device bonding logic appears missing from backend hooks

**Issue**: Multiple devices can potentially use same account if device_id not enforced

**Review Needed**:
- Check if there's a hook that validates device binding (`pb_hooks/*` - search for "device_id")
- `pb_hooks/main.go` doesn't show device registration hook
- Look for `OnRecordAuthRequest` hook that validates device_id

**Found**: `disable_user.go` only checks `disabled`, not device

**Solution**:
1. Add device validation hook:
```go
app.OnRecordAuthRequest().BindFunc(func(e *core.RecordAuthRequestEvent) error {
  user := e.Record
  deviceId := e.Request.Header.Get("X-Device-Id")
  
  // Check if device matches stored device_id
  storedDevice := user.GetString("device_id")
  if storedDevice != "" && storedDevice != deviceId {
    return apis.NewBadRequestError("Account already registered to another device", nil)
  }
  
  // First login: store device_id
  if storedDevice == "" && deviceId != "" {
    user.Set("device_id", deviceId)
    app.Save(user)
  }
  
  return e.Next()
})
```

2. Add device_id field to users collection (if not exists)
3. Allow manager override: Admin can "force logout" from device (clear device_id)

**Files to Create/Update**:
- `pb_hooks/device_bonding.go` (new)
- `pb_hooks/disable_user.go` (expand to check device if needed)
- `lib/core/pb_api.dart` (ensure device headers always sent)

---

### 10. SYNC IDEMPOTENCY & RETRY LOGIC 🟢 MEDIUM

**Current Retry**:
- `LeadService.syncDown`: Retries 3 times with `Future.delayed(2 * retryCount)`
- `CallLogService._syncCallLogToPocketBase`: 3 retries with 2s delay
- Other services: No retry on sync failures

**Issues**:
- Inconsistent retry policies
- No exponential backoff with jitter
- No circuit breaker pattern (prevents hammering failing server)
- Sync errors may leave records in inconsistent syncPending state

**Solutions**:
- Create `RetryService` with configurable backoff strategy:
```dart
class RetryService {
  static Future<T> retry<T>(
    Future<T> Function() fn, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffFactor = 2.0,
  }) async {
    int attempt = 0;
    while (true) {
      try {
        return await fn();
      } catch (e) {
        attempt++;
        if (attempt >= maxAttempts) rethrow;
        final delay = Duration(
          milliseconds: (initialDelay.inMilliseconds * math.pow(backoffFactor, attempt - 1)).toInt(),
        );
        await Future.delayed(delay + Duration(milliseconds: random.nextInt(200))); // jitter
      }
    }
  }
}
```

- Use across all sync operations
- Add circuit breaker: After 5 consecutive failures, stop trying for 5 minutes
- Add diagnostic logging: Track retry counts

**Files to Update**:
- All services with `syncUp()`, `syncDown()`

---

## Lower Priority / Nice-to-Have

### 11. INTERNATIONALIZATION 🟡 LOW
**Issue**: Hardcoded strings throughout app (English only)
**Solution**: Use `intl` package with ARB files for future language support

**Files Affected**: 50+ screens - major effort

---

### 12. ACCESSIBILITY 🟡 LOW
**Issue**: Minimal accessibility labels, no screen reader support
**Solutions**:
- Add `Semantics` widgets for interactive elements
- Set `semanticLabel` on IconButtons
- Ensure proper heading hierarchy
- Test with TalkBack/VoiceOver

---

### 13. ANALYTICS & TRACKING 🟢 MEDIUM
**Issue**: No user behavior analytics (feature usage, drop-off points)
**Solution**: Integrate Firebase Analytics or Mixpanel
- Track: Screen views, button clicks, allocation actions, status changes
- Create custom events: `lead_allocated`, `shuffle_completed`, `attendance_checkin`
- Build dashboard for product decisions

---

### 14. FILE STRUCTURE: DART CODE ORGANIZATION 🟢 MEDIUM

**Current Structure**:
- Screens: flat directory (50+ files)
- Services: flat directory (25+ files)
- Widgets: flat + subdirectories by feature

**Suggested**:
- Group by feature/domain:
  ```
  lib/
  ├── features/
  │   ├── auth/
  │   │   ├── screens/
  │   │   ├── widgets/
  │   │   └── services/
  │   ├── leads/
  │   │   ├── screens/
  │   │   ├── widgets/
  │   │   ├── models/
  │   │   └── services/
  │   ├── attendance/
  │   ├── employees/
  │   └── dashboard/
  ├── core/ (keep as is)
  ├── shared/ (common widgets, utils)
  └── main.dart
  ```

**Benefits**: Easier navigation, clearer feature boundaries, team ownership

---

### 15. POCKETBASE UPGRADE PATH 🟢 MEDIUM

**Current**: PocketBase v0.23.0+1 (as of Nov 2024)
**Issue**: Not pinned to exact version, may have breaking changes
**Action**: 
- Check `pubspec.lock` for exact version
- Review PocketBase changelog for breaking changes since current version
- Test upgrade on staging before production
- Pin version in `pubspec.yaml`: `pocketbase: 0.23.0+1` (remove ^)

---

### 16. FRONTEND: ERROR BOUNDARIES 🟢 MEDIUM

**Issue**: No widget-level error handling - entire screen crashes on unhandled exception
**Solution**: Implement `ErrorWidget.builder` and `FlutterError.onError`
```dart
void main() {
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
    ErrorService.record(details.exception, details.stack);
  };
  ErrorWidget.builder = (details) => ErrorScreen(error: details);
  runApp(MyApp());
}
```

---

### 17. PERFORMANCE: DATABASE MIGRATIONS 🟢 MEDIUM

**Current**: `app_database.dart:194-262` has migration strategy with many `onUpgrade` steps
**Issue**: Migration from very old version (schemaVersion 22) - each app upgrade runs ALL migrations sequentially
**Impact**: First launch after months could be slow

**Solutions**:
- Keep migrations as-is (necessary) but:
- Add migration progress indicator (if > 5 migrations needed)
- Log migration start/end times
- Consider writing tests that verify migrations from old versions

---

### 18. PERFORMANCE: STREAM SUBSCRIPTIONS 🟢 MEDIUM

**Issue**: Multiple services open realtime subscriptions without clear cleanup
- `LeadService.subscribeToLeads()`: Called on init, onConnectivityChanged, on app resume
- No visible unsubscribe on logout or app dispose

**Risk**: Memory leaks, duplicate subscriptions, phantom updates after logout

**Solution**:
- Track all subscriptions in a `SubscriptionManager`
- Clear all on logout: `SubscriptionManager.dispose()`
- Ensure `isSubscribed` flag prevents duplicate subscriptions (already exists in LeadService)

**Files**:
- `lib/services/lead_service.dart:185-248` - add proper cleanup
- Other services with subscriptions: `LoginCaseService`, etc.

---

### 19. INPUT VALIDATION 🟢 MEDIUM

**Frontend**: Marginally addressed via form validators
**Backend**: Some validation in hooks but not comprehensive
- `pb_hooks/leads_api.go:124` - checks status param, but no length/pattern validation
- Parameter injection risk: `employeeCode` used directly in queries (parameterized, so safe)
- But length check only on `employeeCode` (max 50) in `leads_pivot_api.go:51`

**Solutions**:
- Backend: Add comprehensive validation middleware:
```go
func validateStringParam(value, name string, maxLen int) error {
  if len(value) > maxLen {
    return apis.NewBadRequestError(fmt.Sprintf("%s too long", name), nil)
  }
  if !regexp.MustCompile(`^[a-zA-Z0-9_]*$`).MatchString(value) {
    return apis.NewBadRequestError(fmt.Sprintf("%s invalid characters", name), nil)
  }
  return nil
}
```
- Apply to all query params
- Frontend: Already has form validation - keep improving

---

### 20. API DOCUMENTATION 🟢 LOW-MEDIUM

**Issue**: No API documentation (OpenAPI/Swagger)
**Impact**: Hard for frontend developers to understand endpoints, or for external integrations

**Solution**:
- Create OpenAPI 3.0 spec for custom endpoints
- Document request/response schemas
- Include authentication requirements
- Generate client code or interactive docs (Swagger UI)
- Could be manual or use `swaggo` for Go

**File to Create**: `docs/api/openapi.yaml` (or similar)

---

## Specific File Recommendations

### Files to Delete/Remove
1. `pb_hooks/firebase-key.json` - Move to secrets
2. Build artifacts in version control: `.flutter-plugins-dependencies`, `.dart_tool/`, `build/`, `ios/Pods/`
3. `.DS_Store` files
4. `push_adobe_dump_data.py` - Old utility? Move to `scripts/` if needed

### Files to Split (Refactor)
- `lib/services/attendance_service.dart` → 3-4 files
- `lib/services/call_log_service.dart` → 2 files
- `pb_hooks/auto_lead_reallocation_cron.go` → `allocation/`, `shuffle/` packages
- `pb_hooks/lead_shuffle.go` → separate package

### Files to Add
1. **Secrets Management**:
   - `.env.example` (template)
   - `.gitignore` update to include secrets
   - CI/CD secret injection instructions

2. **Testing**:
   - `test/` directory with sample tests
   - `.github/workflows/test.yml`
   - `Makefile` or `justfile` for common tasks

3. **Configuration**:
   - `config/` directory for environment configs (dev/staging/prod)
   - `config/pocketbase.hcl` or similar

4. **Monitoring/Observability**:
   - `lib/services/error_service.dart`
   - `lib/services/analytics_service.dart` (if adding analytics)
   - Backend: `pb_hooks/metrics.go` for Prometheus endpoint

5. **Documentation**:
   - `PRODUCTION_DEPLOYMENT.md` - Step-by-step deployment guide
   - `API_CHANGELOG.md` - Track endpoint changes
   - `MIGRATION_GUIDE.md` - For future PocketBase/dependency upgrades
   - Inline code comments in complex sections (auto_reallocation, shuffle)

---

## Deployment Checklist

### Pre-Deployment (Staging)
- [ ] Migrate backend to PostgreSQL (test on staging)
- [ ] Remove secrets from git history (BFG or filter-branch)
- [ ] Add environment-based configuration (PocketBase URL, N8N webhook)
- [ ] Run full test suite (write tests first if missing)
- [ ] Load test: Simulate 50+ concurrent users allocating leads
- [ ] Verify cron jobs: Check daily sync logs, auto-allocation logs
- [ ] Test device bonding: Login from two devices should reject second
- [ ] Verify FCM notifications: Test IPA notifications
- [ ] Test offline scenario: Disable network, perform actions, re-enable
- [ ] Check file uploads: Selfies, Aadhar cards - storage space

### Production Deployment
- [ ] Use environment-specific PocketBase instance (not dev IP)
- [ ] Enable HTTPS with valid SSL certificate
- [ ] Configure firewall: Only allow API ports (8090) from known IPs or VPN
- [ ] Set up database backups: Automated daily backup PostgreSQL
- [ ] Enable PocketBase logging to file (not just stdout)
- [ ] Set up log aggregation (Loki, ELK, or CloudWatch)
- [ ] Configure N8N webhook with retry logic
- [ ] Setup monitoring alerts:
  - Cron job failures
  - High error rate (5xx responses)
  - Database connection pool exhaustion
  - Storage capacity >80%
- [ ] Enable Firebase App Check for mobile app (prevent unauthorized clients)
- [ ] Review user roles: Ensure no excessive permissions
- [ ] Run security scan: `flutter analyze`, `gosec` for Go code

### Post-Deployment
- [ ] Smoke test all critical flows:
  - Login → Dashboard → Allocate leads → Shuffle → Attendance
- [ ] Check realtime subscriptions working
- [ ] Verify sync on poor network (3G)
- [ ] Monitor error reporting for first 24h
- [ ] Review user feedback and crash reports
- [ ] Schedule regular backups verification (restore test monthly)

---

## Monitoring & Alerting

### Key Metrics to Track

**Backend (PocketBase)**:
- Requests/sec, response time p95/p99
- Error rate (4xx, 5xx)
- Active realtime connections
- Database query duration (slow query log)
- Storage usage growth
- Cron job duration and failure count

**Frontend**:
- App crash rate (Firebase Crashlytics)
- Screen rendering times
- Sync success rate
- Offline duration (time spent offline)
- API call success rate by endpoint

**Business KPIs**:
- Daily active users (DAU)
- Leads allocated/day
- Attendance compliance rate
- IPA/IPD counts
- Call connect rate

---

## Cost Optimization

- **PocketBase Hosting**: Can self-host on cheap VPS ($5-10/mo) vs app server cost
- **Firebase**: FCM free, but storage for selfies can grow → implement auto-cleanup
- **N8N**: Self-hosted or cloud - consider rate limits
- **Backup Storage**: Compress and lifecycle old backups to S3 Glacier

---

## Security Audit Checklist

- [ ] HTTPS everywhere (no HTTP URLs in production)
- [ ] Certificate pinning? (optional for mobile)
- [ ] Sensitive data in logs? (password, tokens) - should be redacted
- [ ] SQL injection: All queries parameterized? (✅ Yes, uses dbx.Params)
- [ ] XSS: Flutter web target? (web/ folder exists - review separately)
- [ ] Secrets in client: Firebase config is public by design, but service account should be server-only
- [ ] Rate limiting: Not implemented - could add nginx rate limiting or PocketBase middleware
- [ ] Input sanitization: Cross-site scripting via customer_name? Should sanitize before display
- [ ] File upload validation: Ensure uploaded files are images only, size limits

---

## Appendix: Quick Wins (30 minutes or less)

1. Remove `firebase-key.json` from git and add to `.gitignore`
2. Add `.env.example` with placeholder values
3. Replace empty catch blocks with `debugPrint` in `login_screen.dart`
4. Add `FlutterError.onError` handler to `main.dart`
5. Add health check endpoint: `GET /api/health` returning OK and version
6. Harden device bonding: Add `device_id` validation hook (see section 9)
7. Add loading indicator for long-running screen loads (some screens may freeze)
8. Fix magic numbers: Extract `const workHoursStart = 10; const workHoursEnd = 19;` in call log hooks
9. Add retry with backoff to `AttendanceService.syncPendingAttendance()` (missing)
10. Add logs to cron jobs: Include start/end timestamps and record counts

---

## Conclusion

The application is **well-architected** with solid offline-first design and sophisticated business logic. However, before production:

1. **Fix secrets leakage** (immediate)
2. **Migrate to PostgreSQL** (critical for scale)
3. **Add monitoring and tests** (quality)
4. **Refactor long files** (maintainability)
5. **Implement device bonding** (security completeness)
6. **Standardize error handling** (observability)

Once these are addressed, the app will be **production-ready** for medium-scale deployments (100-500 concurrent users).

---

**Prepared by**: AI Code Assistant  
**Next Review**: After implementing critical issues
