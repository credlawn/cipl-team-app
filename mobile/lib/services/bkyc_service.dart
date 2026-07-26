import 'dart:async';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../core/pb_api.dart';
import 'lead_service.dart';

class BkycService {
  static AppDatabase get _db => LeadService.db;
  static bool _isSyncing = false;

  static Stream<List<BkycRecord>> getBkycStream() {
    return (_db.select(_db.bkycRecords)
          ..orderBy([
            (t) => OrderingTerm(expression: t.updated, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  static DateTime? _safeParseDate(dynamic dateStr) {
    if (dateStr == null || dateStr.toString().trim().isEmpty) return null;
    try {
      return DateTime.parse(dateStr.toString()).toLocal();
    } catch (e) {
      print('BkycService: Error parsing date "$dateStr": $e');
      return null;
    }
  }

  static Future<void> syncDown() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final employeeCode = PB.pb.authStore.record?.data['employee_code'];
      if (employeeCode == null) return;

      // 1. Fetch from PocketBase
      final records = await PB.pb.collection('bkyc').getFullList(
            filter: "employee_code = '$employeeCode' && remove_data = false",
          );

      final serverIds = <String>{};

      for (final r in records) {
        serverIds.add(r.id);
        
        // 2. Check local existence
        final local = await (_db.select(_db.bkycRecords)
              ..where((t) => t.id.equals(r.id)))
            .getSingleOrNull();

        // 3. Logic for data_status and preservation
        String? dataStatus = r.data['data_status'];
        String? userStatus = r.data['user_status'];
        String? userRemarks = r.data['user_remarks'];
        DateTime? userStatusDate = _safeParseDate(r.data['user_status_date']);

        if (local != null && local.syncPending) {
          // Preserve local pending changes
          userStatus = local.userStatus;
          userRemarks = local.userRemarks;
          dataStatus = local.dataStatus;
          userStatusDate = local.userStatusDate;
        } else if (local == null) {
          // New record coming to device
          if (dataStatus == null || dataStatus.isEmpty) {
            dataStatus = 'Not Seen';
          }
        }

        // 4. Upsert
        await _db.into(_db.bkycRecords).insertOnConflictUpdate(
              BkycRecordsCompanion(
                id: Value(r.id),
                employeeName: Value(r.data['employee_name']),
                employeeCode: Value(r.data['employee_code']),
                customerName: Value(r.data['customer_name'] ?? ''),
                mobileNo: Value(r.data['mobile_no'] ?? ''),
                arnNo: Value(r.data['arn_no']),
                bankStatus: Value(r.data['bank_status'] ?? 'Pending'),
                bankRemarks: Value(r.data['bank_remarks']),
                userStatus: Value(userStatus ?? 'Pending'),
                userRemarks: Value(userRemarks),
                userStatusDate: Value(userStatusDate),
                dataStatus: Value(dataStatus),
                removeData: Value(r.data['remove_data'] ?? false),
                created: Value(_safeParseDate(r.created) ?? DateTime.now()),
                updated: Value(_safeParseDate(r.updated) ?? DateTime.now()),
                syncPending: Value(local?.syncPending ?? (dataStatus == 'Not Seen')),
              ),
            );
      }

      // 5. Delete orphans (remote deletes or remove_data=true)
      final allLocal = await _db.select(_db.bkycRecords).get();
      for (final local in allLocal) {
        if (!serverIds.contains(local.id)) {
          await (_db.delete(_db.bkycRecords)..where((t) => t.id.equals(local.id))).go();
        }
      }
      
      // Try to push any auto-generated 'Not Seen' statuses
      await syncUp();

    } catch (e) {
      print('BkycSyncDown Error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  static Future<void> syncUp() async {
    final pending = await (_db.select(_db.bkycRecords)
          ..where((t) => t.syncPending.equals(true)))
        .get();

    for (final record in pending) {
      try {
        await PB.pb.collection('bkyc').update(record.id, body: {
          'user_status': record.userStatus,
          'user_remarks': record.userRemarks,
          'data_status': record.dataStatus,
          'user_status_date': record.userStatusDate?.toUtc().toIso8601String(),
        });

        await (_db.update(_db.bkycRecords)..where((t) => t.id.equals(record.id)))
            .write(const BkycRecordsCompanion(syncPending: Value(false)));
      } catch (e) {
        print('BkycSyncUp Error for ${record.id}: $e');
      }
    }
  }

  static Future<void> markAsSeen(String id) async {
    final record = await (_db.select(_db.bkycRecords)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    
    if (record == null || record.dataStatus == 'Seen') return;

    await (_db.update(_db.bkycRecords)..where((t) => t.id.equals(id)))
        .write(const BkycRecordsCompanion(
          dataStatus: Value('Seen'),
          syncPending: Value(true),
        ));
    
    // Non-blocking sync up
    unawaited(syncUp());
  }

  static Future<void> updateUserStatus(String id, String status, String? remarks) async {
    final now = DateTime.now();
    await (_db.update(_db.bkycRecords)..where((t) => t.id.equals(id)))
        .write(BkycRecordsCompanion(
          userStatus: Value(status),
          userRemarks: Value(remarks),
          userStatusDate: Value(now),
          syncPending: const Value(true),
        ));
    
    // Non-blocking sync up
    unawaited(syncUp());
  }
}
