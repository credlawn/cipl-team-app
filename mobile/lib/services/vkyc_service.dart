import 'dart:async';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../core/pb_api.dart';
import 'lead_service.dart';

class VkycService {
  static AppDatabase get _db => LeadService.db;
  static bool _isSyncing = false;

  static Stream<List<VkycRecord>> getVkycStream() {
    return (_db.select(_db.vkycRecords)
          ..orderBy([
            (t) => OrderingTerm(expression: t.updated, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  static Future<void> syncDown() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final employeeCode = PB.pb.authStore.record?.data['employee_code'];
      if (employeeCode == null) return;

      // 1. Fetch from PocketBase
      final records = await PB.pb.collection('vkyc').getFullList(
            filter: "employee_code = '$employeeCode' && remove_data = false",
          );

      final serverIds = <String>{};

      for (final r in records) {
        serverIds.add(r.id);
        
        // 2. Check local existence
        final local = await (_db.select(_db.vkycRecords)
              ..where((t) => t.id.equals(r.id)))
            .getSingleOrNull();

        // 3. Logic for data_status and preservation
        String? dataStatus = r.data['data_status'];
        String? userVkycStatus = r.data['user_vkyc_status'];
        String? userRemarks = r.data['user_remarks'];

        if (local != null && local.syncPending) {
          // Preserve local pending changes
          userVkycStatus = local.userVkycStatus;
          userRemarks = local.userRemarks;
          dataStatus = local.dataStatus;
        } else if (local == null) {
          // New record coming to device
          if (dataStatus == null || dataStatus.isEmpty) {
            dataStatus = 'Not Seen';
          }
        }

        // 4. Upsert
        await _db.into(_db.vkycRecords).insertOnConflictUpdate(
              VkycRecordsCompanion(
                id: Value(r.id),
                employeeName: Value(r.data['employee_name'] ?? ''),
                employeeCode: Value(r.data['employee_code'] ?? ''),
                customerName: Value(r.data['customer_name'] ?? ''),
                mobileNo: Value(r.data['mobile_no'] ?? ''),
                bankVkycStatus: Value(r.data['bank_vkyc_status'] ?? 'Pending'),
                userVkycStatus: Value(userVkycStatus ?? 'Pending'),
                userRemarks: Value(userRemarks),
                dataStatus: Value(dataStatus),
                vkycExpiryDate: Value(r.data['vkyc_expiry_date'] != null 
                    ? DateTime.parse(r.data['vkyc_expiry_date']).toLocal() 
                    : null),
                vkycLink: Value(r.data['vkyc_link']),
                arnNo: Value(r.data['arn_no']),
                removeData: Value(r.data['remove_data'] ?? false),
                created: Value(DateTime.parse(r.getStringValue('created')).toLocal()),
                updated: Value(DateTime.parse(r.getStringValue('updated')).toLocal()),
                syncPending: Value(local?.syncPending ?? (dataStatus == 'Not Seen')),
              ),
            );
      }

      // 5. Delete orphans (remote deletes or remove_data=true)
      final allLocal = await _db.select(_db.vkycRecords).get();
      for (final local in allLocal) {
        if (!serverIds.contains(local.id)) {
          await (_db.delete(_db.vkycRecords)..where((t) => t.id.equals(local.id))).go();
        }
      }
      
      // Try to push any auto-generated 'Not Seen' statuses
      await syncUp();

    } catch (e) {
      print('VkycSyncDown Error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  static Future<void> syncUp() async {
    final pending = await (_db.select(_db.vkycRecords)
          ..where((t) => t.syncPending.equals(true)))
        .get();

    for (final record in pending) {
      try {
        await PB.pb.collection('vkyc').update(record.id, body: {
          'user_vkyc_status': record.userVkycStatus,
          'user_remarks': record.userRemarks,
          'data_status': record.dataStatus,
        });

        await (_db.update(_db.vkycRecords)..where((t) => t.id.equals(record.id)))
            .write(const VkycRecordsCompanion(syncPending: Value(false)));
      } catch (e) {
        print('VkycSyncUp Error for ${record.id}: $e');
      }
    }
  }

  static Future<void> markAsSeen(String id) async {
    final record = await (_db.select(_db.vkycRecords)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    
    if (record == null || record.dataStatus == 'Seen') return;

    await (_db.update(_db.vkycRecords)..where((t) => t.id.equals(id)))
        .write(const VkycRecordsCompanion(
          dataStatus: Value('Seen'),
          syncPending: Value(true),
        ));
    
    // Non-blocking sync up
    unawaited(syncUp());
  }

  static Future<void> updateUserStatus(String id, String status, String? remarks) async {
    await (_db.update(_db.vkycRecords)..where((t) => t.id.equals(id)))
        .write(VkycRecordsCompanion(
          userVkycStatus: Value(status),
          userRemarks: Value(remarks),
          syncPending: const Value(true),
        ));
    
    // Non-blocking sync up
    unawaited(syncUp());
  }
}
