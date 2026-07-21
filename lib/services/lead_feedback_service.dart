import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../core/pb_api.dart';
import 'lead_service.dart';

class LeadFeedbackService {
  static AppDatabase get _db => LeadService.db;
  static final _uuid = const Uuid();
  static bool _isSyncingUp = false;
  static bool _isSyncingDown = false;

  static Future<void> addFeedback({
    required String leadId,
    required String customerName,
    required String mobileNo,
    required String leadStatus,
    required DateTime leadStatusDate,
    required String user,
    required String employeeName,
    required String employeeCode,
  }) async {
    try {
      // Idempotency check: if the same leadId + status was already saved
      // within the last 60 seconds, skip — safety net against double-tap
      // edge cases that slip past the processing guard in LeadService.
      final recent = await (_db.select(_db.leadFeedback)
        ..where((t) =>
          t.leadId.equals(leadId) &
          t.leadStatus.equals(leadStatus) &
          t.statusUpdateTime.isBiggerOrEqualValue(
            DateTime.now().subtract(const Duration(seconds: 60)),
          )
        )
        ..limit(1)
      ).getSingleOrNull();

      if (recent != null) return; // duplicate — silently skip

      final feedback = LeadFeedbackCompanion.insert(
        id: _uuid.v4(),
        leadId: leadId,
        customerName: customerName,
        mobileNo: mobileNo,
        leadStatus: leadStatus,
        leadStatusDate: leadStatusDate,
        statusUpdateTime: DateTime.now(),
        user: user,
        employeeName: employeeName,
        employeeCode: employeeCode,
        isSynced: const Value(false),
      );

      await _db.into(_db.leadFeedback).insert(feedback);
      
      syncUp();
    } catch (e) {
      debugPrint('[LeadFeedbackService] addFeedback error: $e');
    }
  }

  static Future<void> syncUp() async {
    if (_isSyncingUp) return;
    _isSyncingUp = true;

    try {
      final query = _db.select(_db.leadFeedback)
        ..where((t) => t.isSynced.equals(false));

      final pendingFeedbacks = await query.get();

      for (final feedback in pendingFeedbacks) {
        try {
          final pb = PB.pb;

          final data = {
            'lead_id': feedback.leadId,
            'customer_name': feedback.customerName,
            'mobile_no': feedback.mobileNo,
            'lead_status': feedback.leadStatus,
            'lead_status_date': feedback.leadStatusDate.toUtc().toIso8601String(),
            'status_update_time': feedback.statusUpdateTime.toUtc().toIso8601String(),
            'user': feedback.user,
            'employee_name': feedback.employeeName,
            'employee_code': feedback.employeeCode,
          };

          await pb.collection('lead_feedback').create(body: data);

          await (_db.update(_db.leadFeedback)
                ..where((t) => t.id.equals(feedback.id)))
              .write(const LeadFeedbackCompanion(isSynced: Value(true)));
        } catch (e) {
        }
      }
    } finally {
      _isSyncingUp = false;
    }
  }

  static Future<void> syncDown() async {
    if (_isSyncingDown) return;
    _isSyncingDown = true;

    try {
      final pb = PB.pb;
      final currentUser = pb.authStore.record;
      if (currentUser == null) return; // finally will reset _isSyncingDown

      // Filter by current user — only fetch this employee's feedback records,
      // not all employees' data (performance + privacy).
      final records = await pb.collection('lead_feedback').getFullList(
        filter: 'user = "${currentUser.id}"',
      );

      final serverIds = <String>{};
      for (final record in records) {
        serverIds.add(record.id);

        final existingQuery = _db.select(_db.leadFeedback)
          ..where((t) => t.id.equals(record.id));
        final existing = await existingQuery.getSingleOrNull();

        final feedback = LeadFeedbackCompanion(
          id: Value(record.id),
          leadId: Value(record.data['lead_id'] ?? ''),
          customerName: Value(record.data['customer_name'] ?? ''),
          mobileNo: Value(record.data['mobile_no'] ?? ''),
          leadStatus: Value(record.data['lead_status'] ?? ''),
          leadStatusDate: Value(_parseDateTime(record.data['lead_status_date']) ?? DateTime.now()),
          statusUpdateTime: Value(_parseDateTime(record.data['status_update_time']) ?? DateTime.now()),
          user: Value(record.data['user'] ?? ''),
          employeeName: Value(record.data['employee_name'] ?? ''),
          employeeCode: Value(record.data['employee_code'] ?? ''),
          isSynced: const Value(true),
        );

        if (existing == null) {
          await _db.into(_db.leadFeedback).insert(feedback);
        } else {
          await (_db.update(_db.leadFeedback)
                ..where((t) => t.id.equals(record.id)))
              .write(feedback);
        }
      }

      final allLocal = await _db.select(_db.leadFeedback).get();
      // Threshold: pending records older than 1 day are considered stuck
      final stuckThreshold = DateTime.now().subtract(const Duration(days: 1));

      for (final local in allLocal) {
        // Case 1: Already synced but server no longer has it — orphaned, delete
        final isOrphaned = local.isSynced && !serverIds.contains(local.id);
        // Case 2: Still pending but older than 1 day — stuck in error, delete
        final isStuck = !local.isSynced &&
            local.statusUpdateTime.isBefore(stuckThreshold);

        if (isOrphaned || isStuck) {
          await (_db.delete(_db.leadFeedback)
                ..where((t) => t.id.equals(local.id)))
              .go();
        }
        // Fresh pending (isSynced=false, < 1 day) — keep for syncUp retry
      }
    } finally {
      _isSyncingDown = false;
    }
  }





  static Future<List<Map<String, dynamic>>> getHistoryByMobile(String mobileNo) async {
    try {
      final cleanMobile = mobileNo.trim();
      final records = await PB.pb.collection('lead_feedback').getList(
        page: 1,
        perPage: 20,
        filter: 'mobile_no = "$cleanMobile"',
        sort: '-lead_status_date',
      );
      
      return records.items.map((e) {
        final data = Map<String, dynamic>.from(e.data);
        data['id'] = e.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('LeadFeedbackHistory Error: $e');
      return [];
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      if (value is String) {
        final utcTime = DateTime.parse(value);
        return utcTime.toLocal();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
