import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'dart:async';
import 'core/app_theme.dart';
import 'core/pb_api.dart';
import 'core/app_logger.dart';
import 'services/lead_service.dart';
import 'services/call_log_service.dart';
import 'services/login_case_service.dart';
import 'services/attendance_service.dart';
import 'services/leave_service.dart';
import 'services/holiday_service.dart';
 import 'services/fcm_service.dart';
 import 'services/lead_feedback_service.dart';
 import 'services/profile_service.dart';
 import 'services/apply_link_service.dart';
 import 'services/version_service.dart';
 import 'services/device_info_service.dart';
 import 'services/app_version_service.dart';
 import 'services/device_registration_service.dart';
import 'widgets/update_dialog.dart';
import 'screens/login_screen.dart';
import 'screens/employee_dashboard.dart';
import 'screens/manager_dashboard.dart';
import 'screens/permission_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/leads_detail_screen.dart';
import 'screens/leads_pivot_table_screen.dart';
import 'screens/employee_lead_detail_screen.dart';
import 'screens/aggregate_status_breakdown_screen.dart';
import 'screens/status_employee_breakdown_screen.dart';
import 'screens/ipa_detail_screen.dart';
import 'screens/attendance_detail_screen.dart';
import 'screens/call_logs_detail_screen.dart';
import 'screens/employee_call_history_screen.dart';
import 'core/config_service.dart';
import 'screens/config_error_screen.dart';
import 'screens/bh_dashboard_screen.dart';
import 'screens/allocate_leads_screen.dart';
import 'screens/customer_details_screen.dart';
import 'screens/lead_feedback_history_screen.dart';
import 'package:permission_handler/permission_handler.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = AppLogger.bugsinkDsn;
      options.environment = kReleaseMode ? 'production' : 'development';
      options.attachStacktrace = true;
      options.sendDefaultPii = false;
      options.debug = false; // Silences verbose Sentry Android logcat messages
      options.enableUserInteractionBreadcrumbs = false;
      options.beforeSend = AppLogger.filterError;
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();
      
      // Load Dynamic Remote Config from Cloudflare
      await ConfigService.init();

      if (!ConfigService.isConfigured) {
        runApp(MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: ConfigErrorScreen(onRetry: () => main()),
        ));
        return;
      }

      // Parallel Core Initialization
      await Future.wait([
        Firebase.initializeApp(),
        PB.init(),
        LeadService.init(),
        DeviceInfoService.init(),
        AppVersionService.init(),
      ]);
      
      LoginCaseService.init();
      CallLogService.init();
      CallLogService.maybeCleanupIfNeeded();

      // Initialize device registration service (sets up token refresh listener)
      DeviceRegistrationService.initialize();

      // Instant Start Screen Determination (Optimistic Cache-based)
      Widget startScreen = const LoginScreen();
      bool isAuthValid = PB.pb.authStore.isValid;
      
      if (isAuthValid) {
        final user = PB.pb.authStore.record;
        if (user != null) {
          final role = user.data['role']?.toString().toLowerCase() ?? '';
          
          // Check for forced password reset from LOCAL store
          if (user.data['must_change_password'] == true) {
            startScreen = const ChangePasswordScreen();
          } else if (role == 'manager') {
            startScreen = const ManagerDashboard();
          } else {
            startScreen = const EmployeeDashboard();
          }
        }
      }

      // Permission Check (Non-blocking UI fallback)
      final status = await Permission.phone.status;
      if (!status.isGranted) {
        runApp(MaterialApp(
          debugShowCheckedModeBanner: false,
          home: PermissionScreen(onPermissionsGranted: () => main()),
        ));
        return;
      }

      runApp(MyApp(startScreen: startScreen));
    },
  );
}

class MyApp extends StatefulWidget {
  final Widget startScreen;
  const MyApp({required this.startScreen, super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final connectivity = Connectivity();
  Timer? _bgSyncTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Global Auth Monitor (Immediate reactive logout)
    PB.pb.authStore.onChange.listen((event) {
      if (event.token.isEmpty && mounted) {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    });

    // Connectivity & Background Jobs
    connectivity.onConnectivityChanged.listen((status) {
      if (status != ConnectivityResult.none) {
        _triggerSilentVerification();
      }
    });

    // Start Silent Verification & Sync immediately after UI renders
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (PB.pb.authStore.isValid) {
        await FCMService.initialize();
        await DeviceRegistrationService.register();
        _triggerSilentVerification();
        _checkForUpdate();
        LeadService.subscribeToLeads();
        _startRealtimeMonitor();
      }
    });
  }

  // Layer 2: Silent Server Verification (Background Guard)
  // This refreshes the session and ejects the user if their status changed
  Future<void> _triggerSilentVerification() async {
    if (!PB.pb.authStore.isValid) return;

    try {
      final headers = await PB.getDeviceHeaders();
      final refreshed = await PB.pb.collection('users').authRefresh(headers: headers);
      
      // Strict Security Sentinel
      if (refreshed.record != null) {
        final data = refreshed.record!.data;
        if (data['disabled'] == true) {
          await PB.logout();
        } else if (data['must_change_password'] == true) {
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            (route) => false,
          );
        } else {
          // If everything is fine, run a silent sync
          _runBackgroundDataSync();
        }
      }
    } on ClientException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        await PB.logout();
      }
    } catch (_) {}
  }

  // Layer 3: Real-time Subscriber (Instant Action)
  void _startRealtimeMonitor() {
    final user = PB.pb.authStore.record;
    if (user != null) {
      PB.pb.collection('users').subscribe(user.id, (e) {
        if (e.record != null && e.record!.data['disabled'] == true) {
          PB.logout();
        }
      });
    }
  }

  // Orchestrated Parallel Background Sync
  Future<void> _runBackgroundDataSync() async {
    try {
      await Future.wait([
        ProfileService.refreshProfile(),
        LeadService.syncUp(),
        LeadFeedbackService.syncUp(),
        AttendanceService.syncUp(),
        LeaveService.syncUp(),
        LoginCaseService.syncFromServer(),
        ApplyLinkService.syncDown(),
        HolidayService.syncDown(),
      ]);
      
      // Trigger down-sync after up-sync completes to ensure consistency
      await LeadService.syncDown(silent: true);
      CallLogService.invalidateLeadCache(); // Rebuild lead map on next scan with fresh data
      await LeadFeedbackService.syncDown();
      await AttendanceService.syncDown();
      await LeaveService.syncDown();
    } catch (e, stackTrace) {
      AppLogger.captureException(e, stackTrace: stackTrace, tag: 'BackgroundSync');
      PB.handleAuthError(e, stackTrace);
    }
  }

  Future<void> _checkForUpdate() async {
    try {
      final versionInfo = await VersionService.checkForUpdate();
      if (versionInfo != null && mounted) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => UpdateDialog(versionInfo: versionInfo),
          ),
        );
      }
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _triggerSilentVerification();
      CallLogService.syncPendingCallLogs();
      CallLogService.maybeCleanupIfNeeded();
      LoginCaseService.initializeRealtime();
      LeadService.subscribeToLeads();
      
      // 30-second one-shot timer: real-time tracking captures calls immediately;
      // this background scan is just the safety net backup.
      _bgSyncTimer = Timer(const Duration(seconds: 30), () {
        CallLogService.scanAndSyncBackgroundLogs();
      });
    } else {
      _bgSyncTimer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bgSyncTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      navigatorObservers: [SentryNavigatorObserver()],
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: widget.startScreen,
      routes: {
        '/manager/leads-detail': (context) => const LeadsDetailScreen(),
        '/manager/leads-pivot': (context) => const LeadsPivotTableScreen(),
        '/manager/employee-lead-detail': (context) => const EmployeeLeadDetailScreen(),
        '/manager/aggregate-status-breakdown': (context) => const AggregateStatusBreakdownScreen(),
        '/status-employee-breakdown': (context) => const StatusEmployeeBreakdownScreen(),
        '/manager/ipa-detail': (context) => const IpaDetailScreen(),
        '/manager/attendance-detail': (context) => const AttendanceDetailScreen(),
        '/manager/call-logs-detail': (context) => const CallLogsDetailScreen(),
        '/manager/employee-call-history': (context) => const EmployeeCallHistoryScreen(),
        '/bh-dashboard': (context) => const BHDashboardScreen(),
        '/allocate-leads': (context) => const AllocateLeadsScreen(),
        '/manager/customer-details': (context) => const CustomerDetailsScreen(),
        '/manager/lead-feedback-history': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return LeadFeedbackHistoryScreen(
            mobileNo: args['mobileNo'],
            customerName: args['customerName'],
          );
        },
      },
    );
  }
}