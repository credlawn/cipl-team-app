import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../database/app_database.dart';
import '../core/pb_api.dart';
import 'lead_service.dart';
import 'package:flutter/foundation.dart';

class LeaveService {
  static const _uuid = Uuid();
  static AppDatabase get _db => LeadService.db;

  static Future<void> applyLeave({
    required String leaveType,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
  }) async {
    final user = PB.pb.authStore.record;
    if (user == null) throw Exception('User not logged in');

    final days = toDate.difference(fromDate).inDays + 1;

    // 1. Check for Overlapping Leaves (Date Conflict)
    final existingLeaves = await (_db.select(_db.leaveRequests)
      ..where((t) => t.employeeId.equals(user.id))
      ..where((t) => t.status.isIn(['pending', 'approved']))).get();

    for (var oldLeave in existingLeaves) {
      bool hasConflict = (fromDate.isBefore(oldLeave.toDate) || fromDate.isAtSameMomentAs(oldLeave.toDate)) &&
                        (toDate.isAfter(oldLeave.fromDate) || toDate.isAtSameMomentAs(oldLeave.fromDate));
      
      if (hasConflict) {
        final start = DateFormat('dd MMM').format(oldLeave.fromDate);
        final end = DateFormat('dd MMM').format(oldLeave.toDate);
        if (oldLeave.status == 'pending') {
          throw Exception('You have already applied leave for $start - $end');
        } else {
          throw Exception('Your leave is already approved for $start - $end');
        }
      }
    }

    // Normalizing dates to UTC Noon (12:00 PM)
    final normalizedFrom = DateTime.utc(fromDate.year, fromDate.month, fromDate.day, 12, 0, 0);
    final normalizedTo = DateTime.utc(toDate.year, toDate.month, toDate.day, 12, 0, 0);
    final now = DateTime.now();
    final normalizedApplied = DateTime.utc(now.year, now.month, now.day, 12, 0, 0);

    if (leaveType == 'Paid') {
      final balance = getPaidLeaveBalance();
      if (balance < days) {
        throw Exception('Insufficient leave balance. Available: $balance days');
      }
    }

    if (fromDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      throw Exception('Cannot apply leave for past dates');
    }

    final leave = LeaveRequestsCompanion.insert(
      id: _uuid.v4(),
      employeeId: user.id,
      employeeCode: user.getStringValue('employee_code'),
      employeeName: user.getStringValue('employee_name'),
      leaveType: leaveType,
      fromDate: normalizedFrom,
      toDate: normalizedTo,
      daysCount: days,
      reason: reason,
      status: 'pending',
      appliedDate: normalizedApplied,
      syncPending: const Value(true),
    );

    await _db.into(_db.leaveRequests).insert(leave);
    
    // Attempt sync
    syncUp();
  }

  static int getPaidLeaveBalance() {
    return (PB.pb.authStore.record?.data['paid_leave_balance'] ?? 0).toInt();
  }

  static Future<void> syncUp() async {
    final pending = await (_db.select(_db.leaveRequests)
      ..where((t) => t.syncPending.equals(true))).get();

    for (var leave in pending) {
      try {
        await PB.pb.collection('leave_request').create(body: {
          'user': leave.employeeId,
          'employee_code': leave.employeeCode,
          'employee_name': leave.employeeName,
          'leave_type': leave.leaveType,
          'from_date': leave.fromDate.toIso8601String(),
          'to_date': leave.toDate.toIso8601String(),
          'days_count': leave.daysCount,
          'reason': leave.reason,
          'status': leave.status,
          'applied_date': leave.appliedDate.toIso8601String(),
        });

        await (_db.update(_db.leaveRequests)
          ..where((t) => t.id.equals(leave.id)))
          .write(const LeaveRequestsCompanion(syncPending: Value(false)));
      } catch (_) {
        // Silently fail for individual background sync tasks
      }
    }
  }

  static Future<void> syncDown() async {
    try {
      final records = await PB.pb.collection('leave_request').getFullList(
        filter: 'user = "${PB.pb.authStore.record?.id}"',
      );

      await _db.transaction(() async {
        for (var record in records) {
          await _db.into(_db.leaveRequests).insertOnConflictUpdate(
            LeaveRequestsCompanion.insert(
              id: record.id,
              employeeId: record.data['user'],
              employeeCode: record.data['employee_code'],
              employeeName: record.data['employee_name'],
              leaveType: record.data['leave_type'],
              fromDate: DateTime.parse(record.data['from_date']),
              toDate: DateTime.parse(record.data['to_date']),
              daysCount: record.data['days_count'],
              reason: record.data['reason'],
              status: record.data['status'],
              appliedDate: DateTime.parse(record.data['applied_date']),
              syncPending: const Value(false),
            ),
          );
        }
      });
    } catch (_) {
      // Sync down failure is ignored to allow offline use
    }
  }

  static Future<List<LeaveRequest>> getLeaveHistory() async {
    return await (_db.select(_db.leaveRequests)
      ..orderBy([(t) => OrderingTerm(expression: t.appliedDate, mode: OrderingMode.desc)])).get();
  }

  static Future<List<Map<String, dynamic>>> getAllLeaveRequests() async {
    try {
      final records = await PB.pb.collection('leave_request').getFullList(
        sort: '-applied_date',
      );
      return records.map((r) => r.toJson()).toList();
    } catch (e) {
      throw Exception('Failed to fetch leave requests: $e');
    }
  }

  static Future<void> approveLeaveRequest({
    required String requestId,
    required String employeeId,
    required int daysCount,
    required String leaveType,
    required String approverName,
  }) async {
    try {
      final now = DateTime.now();
      final noonDate = DateTime.utc(now.year, now.month, now.day, 12, 0, 0);

      await PB.pb.collection('leave_request').update(requestId, body: {
        'status': 'approved',
        'decision_date': noonDate.toIso8601String(),
        'approved_by': approverName,
      });

      if (leaveType == 'Paid') {
        final userRecord = await PB.pb.collection('users').getOne(employeeId);
        final currentBalance = (userRecord.data['paid_leave_balance'] ?? 0) as num;
        final newBalance = currentBalance.toInt() - daysCount;

        await PB.pb.collection('users').update(employeeId, body: {
          'paid_leave_balance': newBalance,
        });
      }
    } catch (e) {
      throw Exception('Failed to approve leave: $e');
    }
  }

  static Future<void> rejectLeaveRequest({
    required String requestId,
    required String reason,
    required String approverName,
  }) async {
    try {
      final now = DateTime.now();
      final noonDate = DateTime.utc(now.year, now.month, now.day, 12, 0, 0);

      await PB.pb.collection('leave_request').update(requestId, body: {
        'status': 'rejected',
        'rejection_reason': reason,
        'decision_date': noonDate.toIso8601String(),
        'approved_by': approverName,
      });
    } catch (e) {
      throw Exception('Failed to reject leave: $e');
    }
  }
}
