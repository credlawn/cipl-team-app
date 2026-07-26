import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../core/pb_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:call_log/call_log.dart' as cl;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../services/lead_service.dart';

class CallLogService {
  static Future<List<Map<String, dynamic>>> getCallHistoryByPhone(String phoneNumber) async {
    try {
      final records = await PB.pb.collection('call_logs').getList(
        page: 1,
        perPage: 30,
        filter: 'phone_number = "$phoneNumber"',
        sort: '-call_timestamp',
      );
      return records.items.map((e) => e.toJson()).toList();
    } catch (e) {
      return [];
    }
  }

  static const callChannel = MethodChannel('com.credlawn.cipl/call_state');
  static AppDatabase get _db => LeadService.db;
  static final _uuid = const Uuid();

  static void init() {
    callChannel.setMethodCallHandler((call) async {
      if (call.method == 'onCallEnded') {
        final data = Map<String, dynamic>.from(call.arguments);
        final leadId = data['leadId'] as String?;
        final employeeId = data['employeeId'] as String?;
        final employeeCode = data['employeeCode'] as String?;
        final employeeName = data['employeeName'] as String?;
        
        if (leadId != null && employeeId != null && employeeCode != null && employeeName != null) {
          await saveCallLog(
            leadId: leadId,
            employeeId: employeeId,
            employeeCode: employeeCode,
            employeeName: employeeName,
            phoneNumber: data['phoneNumber'],
            callTimestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp']),
            callDuration: data['callDuration'],
            ringDuration: data['ringDuration'],
            sessionDuration: data['sessionDuration'] as int? ?? 0,
            callType: data['callType'],
            callStatus: data['callStatus'],
          );
        }
      }
    });
  }

  static Future<void> saveCallLog({
    required String leadId,
    required String employeeId,
    required String employeeCode,
    required String employeeName,
    required String phoneNumber,
    required DateTime callTimestamp,
    required int callDuration,
    required int ringDuration,
    required int sessionDuration,
    required String callType,
    required String callStatus,
  }) async {

    // Normalize phone number to last 10 digits to match background sync logic
    String normalizeNumber(String phone) {
      return phone.replaceAll(RegExp(r'\D'), '').substring(
        (phone.replaceAll(RegExp(r'\D'), '').length > 10) 
          ? phone.replaceAll(RegExp(r'\D'), '').length - 10 
          : 0
      );
    }
    
    final normalizedPhone = normalizeNumber(phoneNumber);

    _isSaving = true;
    try {
      // Bulletproof duplicate check:
      // Query by phone + ±1 min time window ONLY — callType is intentionally
      // excluded because real-time path (Android native) and background scan
      // (OS call_log package) can report different callType for the same call,
      // which would make the query return 0 rows and bypass the duplicate guard.
      // Second-level check (same second + same duration) handles false positives.
      final windowStart = callTimestamp.subtract(const Duration(minutes: 1));
      final windowEnd   = callTimestamp.add(const Duration(minutes: 1));

      final duplicateCheck = await (_db.select(_db.callLogs)
        ..where((t) =>
          t.phoneNumber.equals(normalizedPhone) &
          t.callTimestamp.isBiggerOrEqualValue(windowStart) &
          t.callTimestamp.isSmallerOrEqualValue(windowEnd)
        )).get();

      bool isDuplicate = false;
      for (var log in duplicateCheck) {
        // Strip milliseconds and compare at the second level + exact duration match.
        // A human cannot dial the same number twice in 1 second with identical duration.
        final secDiff = (log.callTimestamp.millisecondsSinceEpoch ~/ 1000) -
                        (callTimestamp.millisecondsSinceEpoch ~/ 1000);
        if (secDiff.abs() <= 1 && log.callDuration == callDuration) {
          isDuplicate = true;
          break;
        }
      }

      if (isDuplicate) {
        return; // Skip if already saved by background sync
      }

      final callLog = CallLogsCompanion.insert(
        id: _uuid.v4(),
        leadId: leadId,
        employeeId: employeeId,
        employeeCode: employeeCode,
        employeeName: employeeName,
        phoneNumber: normalizedPhone,
        callTimestamp: callTimestamp,
        callDuration: callDuration,
        ringDuration: ringDuration,
        sessionDuration: Value(sessionDuration),
        callType: callType,
        callStatus: callStatus,
        isSynced: const Value(false),
      );

      try {
        await _db.into(_db.callLogs).insert(callLog);
      } catch (e) {
        // Silently fail or log to crashlytics
        return; 
      }

      _syncCallLogToPocketBase(callLog);
    } finally {
      _isSaving = false;
    }
  }

  static Future<void> _syncCallLogToPocketBase(CallLogsCompanion callLog) async {
    int attempts = 0;
    while (attempts < 3) {
      try {
        final pb = PB.pb;
        
        final data = {
          'lead_id': callLog.leadId.value,
          'employee_id': callLog.employeeId.value,
          'employee_code': callLog.employeeCode.value,
          'employee_name': callLog.employeeName.value,
          'phone_number': callLog.phoneNumber.value,
          'call_timestamp': callLog.callTimestamp.value.toUtc().toIso8601String(),
          'call_duration': callLog.callDuration.value,
          'ring_duration': callLog.ringDuration.value,
          'session_duration': callLog.sessionDuration.value,
          'call_type': callLog.callType.value,
          'call_status': callLog.callStatus.value,
        };

        await pb.collection('call_logs').create(body: data);

        await (_db.update(_db.callLogs)
              ..where((t) => t.id.equals(callLog.id.value)))
            .write(const CallLogsCompanion(isSynced: Value(true)));
        return; // Success, exit function
      } catch (e) {
        attempts++;
        if (attempts >= 3) {
          // Failed after 3 attempts
        } else {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }
  }

  static Future<List<CallLog>> getCallLogsForLead(String leadId) async {
    final query = _db.select(_db.callLogs)
      ..where((t) => t.leadId.equals(leadId))
      ..orderBy([(t) => OrderingTerm.desc(t.callTimestamp)]);

    final results = await query.get();

    return results;
  }

  static Stream<List<CallLog>> watchRecentCallLogsForLead(String leadId) {
    return (_db.select(_db.callLogs)
      ..where((t) => t.leadId.equals(leadId) & t.callDuration.isBiggerThanValue(0))
      ..orderBy([(t) => OrderingTerm.desc(t.callTimestamp)])
      ..limit(3))
      .watch();
  }

  static Future<void> syncPendingCallLogs() async {
    if (_isSaving) {
      return;
    }
    if (_isSyncingPending) {
      return;
    }
    
    _isSyncingPending = true;
    
    try {
      final query = _db.select(_db.callLogs)
        ..where((t) => t.isSynced.equals(false));

      final pendingLogs = await query.get();

      for (final log in pendingLogs) {
        await _syncCallLogToPocketBase(CallLogsCompanion(
          id: Value(log.id),
          leadId: Value(log.leadId),
          employeeId: Value(log.employeeId),
          employeeCode: Value(log.employeeCode),
          employeeName: Value(log.employeeName),
          phoneNumber: Value(log.phoneNumber),
          callTimestamp: Value(log.callTimestamp),
          callDuration: Value(log.callDuration),
          ringDuration: Value(log.ringDuration),
          sessionDuration: Value(log.sessionDuration),
          callType: Value(log.callType),
          callStatus: Value(log.callStatus),
        ));
      }
    } finally {
      _isSyncingPending = false;
    }
  }
  
  static Future<void> maybeCleanupIfNeeded() async {
    try {
      final today = DateTime.now();
      final todayKey = today.year * 10000 + today.month * 100 + today.day;

      final prefs = await SharedPreferences.getInstance();
      final lastCleanupKey = prefs.getInt('call_log_last_cleanup_date') ?? 0;

      if (lastCleanupKey == todayKey) {
        return; // Already cleaned today
      }

      await cleanupOldLogs();
      await prefs.setInt('call_log_last_cleanup_date', todayKey);
    } catch (e) {
      // If SharedPreferences fails, cleanup on next attempt.
      // Don't crash the app over a cleanup failure.
      debugPrint('maybeCleanupIfNeeded error: $e');
    }
  }

  static Future<void> cleanupOldLogs() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 3));
      await (_db.delete(_db.callLogs)
        ..where((t) => t.callTimestamp.isSmallerThanValue(cutoffDate)))
        .go();
    } catch (e) {
      debugPrint('Call log cleanup error: $e');
    }
  }

  static bool _isScanning = false;
  static bool _isSaving = false;
  static bool _isSyncingPending = false;
  // In-memory lead map cache — avoids reading 500-2000 SQLite rows on every scan
  static Map<String, String>? _cachedLeadMap;
  static DateTime? _lastLeadMapBuildTime;
  // Throttle guard — prevents the scan from running more than once per 30 seconds
  static DateTime? _lastScanTime;

  /// Call this after leads are synced from the server so the cache is rebuilt
  /// with the latest phone-to-leadId mapping on the next background scan.
  static void invalidateLeadCache() {
    _cachedLeadMap = null;
  }

  static Future<void> scanAndSyncBackgroundLogs() async {
    if (_isScanning) {
      return;
    }

    // Throttle guard: don't run more than once every 30 seconds
    if (_lastScanTime != null &&
        DateTime.now().difference(_lastScanTime!).inSeconds < 30) {
      return;
    }

    _isScanning = true;
    _lastScanTime = DateTime.now();

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastScanTimeMillis = prefs.getInt('last_call_log_scan_time');
      
      if (lastScanTimeMillis == null) {
        await prefs.setInt('last_call_log_scan_time', DateTime.now().millisecondsSinceEpoch);
        return;
      }
      
      final DateTime fromDate = DateTime.fromMillisecondsSinceEpoch(lastScanTimeMillis);

      // Number normalizer — strips non-digits, keeps last 10 digits
      String normalizeNumber(String phone) {
        return phone.replaceAll(RegExp(r'\D'), '').substring(
          (phone.replaceAll(RegExp(r'\D'), '').length > 10) 
            ? phone.replaceAll(RegExp(r'\D'), '').length - 10 
            : 0
        );
      }

      // Use in-memory cache to avoid expensive full-table SQLite scan on every run.
      // Cache is rebuilt if null (invalidated after lead server-sync) or older than 5 min.
      if (_cachedLeadMap == null ||
          _lastLeadMapBuildTime == null ||
          DateTime.now().difference(_lastLeadMapBuildTime!).inMinutes >= 5) {
        final allLeads = await _db.select(_db.leads).get();
        _cachedLeadMap = { for (var l in allLeads) normalizeNumber(l.mobileNo): l.id };
        _lastLeadMapBuildTime = DateTime.now();
      }
      final Map<String, String> leadMap = Map.from(_cachedLeadMap!);

      if (leadMap.isEmpty) {
        return;
      }

      final Iterable<cl.CallLogEntry> entries = await cl.CallLog.query(
        dateFrom: fromDate.millisecondsSinceEpoch + 10,
      );

      bool newLogsFound = false;
      DateTime? latestCallEndTime;
      final user = PB.pb.authStore.record;
      if (user == null) {
        return;
      }

      for (var entry in entries) {
        if (entry.number == null || entry.timestamp == null) continue;

        final normalizedPhone = normalizeNumber(entry.number!);
        
        if (!leadMap.containsKey(normalizedPhone)) continue;
        
        final leadId = leadMap[normalizedPhone]!;
        final callType = _mapCallType(entry.callType);
        final callDuration = entry.duration ?? 0;
        final callTimestamp = DateTime.fromMillisecondsSinceEpoch(entry.timestamp!);
        final callEndTime = DateTime.fromMillisecondsSinceEpoch(
          entry.timestamp! + (callDuration * 1000)
        );

        // Bulletproof duplicate check: phone + ±1 min timestamp window ONLY.
        // callType is intentionally excluded — real-time path and background scan
        // can report different callType for the same call, causing 0 rows returned
        // and the duplicate guard being bypassed entirely.
        final dupWindowStart = callTimestamp.subtract(const Duration(minutes: 1));
        final dupWindowEnd   = callTimestamp.add(const Duration(minutes: 1));

        final duplicateCheck = await (_db.select(_db.callLogs)
          ..where((t) =>
            t.phoneNumber.equals(normalizedPhone) &
            t.callTimestamp.isBiggerOrEqualValue(dupWindowStart) &
            t.callTimestamp.isSmallerOrEqualValue(dupWindowEnd)
          )).get();

        bool isDuplicate = false;
        for (var log in duplicateCheck) {
          // Strip milliseconds (compare at second level) + exact duration match
          final secDiff = (log.callTimestamp.millisecondsSinceEpoch ~/ 1000) -
                          (callTimestamp.millisecondsSinceEpoch ~/ 1000);
          if (secDiff.abs() <= 1 && log.callDuration == callDuration) {
            isDuplicate = true;
            break;
          }
        }

        if (isDuplicate) {
          continue;
        }
        
        final callLog = CallLogsCompanion.insert(
          id: _uuid.v4(),
          leadId: leadId,
          employeeId: user.id,
          employeeCode: user.getStringValue('employee_code'),
          employeeName: user.getStringValue('employee_name'),
          phoneNumber: normalizedPhone,
          callTimestamp: callTimestamp,
          callDuration: callDuration,
          ringDuration: 0,
          sessionDuration: Value(callDuration),
          callType: callType,
          callStatus: 'completed',
          isSynced: const Value(false),
        );

        await _db.into(_db.callLogs).insert(callLog);
        newLogsFound = true;
        
        if (latestCallEndTime == null || callEndTime.isAfter(latestCallEndTime)) {
          latestCallEndTime = callEndTime;
        }
      }

      if (latestCallEndTime != null) {
        await prefs.setInt('last_call_log_scan_time', latestCallEndTime.millisecondsSinceEpoch);
      }

      if (newLogsFound) {
        syncPendingCallLogs();
      }

    } catch (e) {
      debugPrint('[CallLogService] scanAndSyncBackgroundLogs error: $e');
    } finally {
      _isScanning = false;
    }
  }

  static String _mapCallType(cl.CallType? type) {
    switch (type) {
      case cl.CallType.incoming: return 'incoming';
      case cl.CallType.outgoing: return 'outgoing';
      case cl.CallType.missed: return 'missed';
      case cl.CallType.rejected: return 'rejected';
      case cl.CallType.blocked: return 'blocked';
      default: return 'unknown';
    }
  }
}
