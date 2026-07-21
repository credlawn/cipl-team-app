import 'dart:developer' as dev;
import 'dart:async';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../core/pb_api.dart';
import 'lead_service.dart';

class ActivationService {
  static const String collectionName = 'activation';
  
  static AppDatabase get _db => LeadService.db;
  static bool _isSyncing = false;

  static Stream<List<ActivationRecord>> getActivationStream() {
    return _db.select(_db.activationRecords).watch();
  }

  static DateTime? _safeParseDate(dynamic date) {
    if (date == null || date.toString().isEmpty) return null;
    try {
      return DateTime.parse(date.toString()).toLocal();
    } catch (e) {
      dev.log("ActivationSync Error: Invalid date format: $date");
      return null;
    }
  }

  static Future<void> syncDown() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pb = PB.pb;
      final employeeCode = pb.authStore.record?.data['employee_code'];
      
      if (employeeCode == null) return;

      final records = await pb.collection(collectionName).getFullList(
        filter: 'employee_code = "$employeeCode"',
        sort: '-updated',
      );

      final existingIds = (await _db.select(_db.activationRecords).get())
          .map((e) => e.id)
          .toSet();

      final serverIds = records.map((e) => e.id).toSet();

      // 1. Delete orphan records (removed from server)
      final toDelete = existingIds.difference(serverIds);
      if (toDelete.isNotEmpty) {
        await (_db.delete(_db.activationRecords)
              ..where((t) => t.id.isIn(toDelete)))
            .go();
      }

      // 2. Upsert server records
      for (final record in records) {
        final data = record.data;
        
        // Check local existence to preserve syncPending if necessary
        final local = await (_db.select(_db.activationRecords)
              ..where((t) => t.id.equals(record.id)))
            .getSingleOrNull();

        String? dataStatus = data['data_status'];
        // PocketBase returns "" (empty string) not null, so check both
        final isBlank = dataStatus == null || dataStatus.toString().trim().isEmpty;
        if (local == null) {
          dataStatus = isBlank ? 'Not Seen' : dataStatus;
        } else if (local.syncPending) {
          // Keep local status if sync is pending
          dataStatus = local.dataStatus;
        }

        await _db.into(_db.activationRecords).insertOnConflictUpdate(
          ActivationRecordsCompanion.insert(
            id: record.id,
            employeeName: Value(data['employee_name']),
            employeeCode: Value(data['employee_code']),
            customerName: data['customer_name'] ?? 'Unknown',
            mobileNo: data['mobile_no'] ?? '',
            arnNo: Value(data['arn_no']),
            decisionMonth: Value(data['decision_month']),
            decisionDate: Value(_safeParseDate(data['decision_date'])),
            bankStatus: Value(data['bank_status']),
            bankStatusDate: Value(_safeParseDate(data['bank_status_date'])),
            userStatus: Value(local?.syncPending == true ? local?.userStatus : (data['user_status'] ?? 'Pending')),
            userStatusDate: Value(local?.syncPending == true ? local?.userStatusDate : _safeParseDate(data['user_status_date'])),
            dataStatus: Value(dataStatus),
            removeData: Value(data['remove_data'] ?? false),
            userRemarks: Value(local?.syncPending == true ? local?.userRemarks : data['user_remarks']),
            followupDate: Value(local?.syncPending == true ? local?.followupDate : _safeParseDate(data['followup_date'])),
            created: _safeParseDate(record.created) ?? DateTime.now(),
            updated: _safeParseDate(record.updated) ?? DateTime.now(),
            syncPending: Value(local?.syncPending ?? (dataStatus == 'Not Seen')),
          ),
        );
      }
      
      // Try to push any auto-generated 'Not Seen' statuses
      await syncUp();
      dev.log("ActivationSync: Synced Down ${records.length} records.");
    } catch (e) {
      dev.log("ActivationSync Error (Down): $e");
    } finally {
      _isSyncing = false;
    }
  }

  static Future<void> syncUp() async {
    try {
      final pb = PB.pb;
      final pending = await (_db.select(_db.activationRecords)
            ..where((t) => t.syncPending.equals(true)))
          .get();

      for (final record in pending) {
        await pb.collection(collectionName).update(record.id, body: {
          'user_status': record.userStatus,
          'user_remarks': record.userRemarks,
          'user_status_date': record.userStatusDate?.toUtc().toIso8601String(),
          'followup_date': record.followupDate?.toUtc().toIso8601String(),
          'data_status': record.dataStatus,
        });

        await (_db.update(_db.activationRecords)
              ..where((t) => t.id.equals(record.id)))
            .write(const ActivationRecordsCompanion(syncPending: Value(false)));
      }
    } catch (e) {
      dev.log("ActivationSync Error (Up): $e");
    }
  }

  static Future<void> updateStatus({
    required String id,
    required String status,
    required String remarks,
    DateTime? followupDate,
  }) async {
    final now = DateTime.now();
    await (_db.update(_db.activationRecords)
          ..where((t) => t.id.equals(id)))
        .write(ActivationRecordsCompanion(
      userStatus: Value(status),
      userRemarks: Value(remarks),
      userStatusDate: Value(now),
      followupDate: Value(followupDate),
      syncPending: const Value(true),
      updated: Value(now),
    ));
    
    unawaited(syncUp());
  }

  static Future<void> markAsSeen(String id) async {
    final record = await (_db.select(_db.activationRecords)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();

    if (record != null && record.dataStatus == 'Not Seen') {
      await (_db.update(_db.activationRecords)
            ..where((t) => t.id.equals(id)))
          .write(const ActivationRecordsCompanion(
        dataStatus: Value('Seen'),
        syncPending: Value(true),
      ));
      unawaited(syncUp());
    }
  }
}
