import 'dart:async';
import 'package:drift/drift.dart';
import 'package:pocketbase/pocketbase.dart' as pb_lib;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../core/pb_api.dart';
import 'lead_feedback_service.dart';

class LeadService {
  static late AppDatabase db;
  static bool _initialized = false;

  static Timer? _batchSyncTimer;
  static int _eventCount = 0;
  static DateTime? _firstEventTime;
  static const int _batchThreshold = 5;
  static const int _batchWindowSeconds = 3;
  // Guard: prevents the same lead from being processed more than once at a time
  // (double-tap protection — blocks a 2nd call before the 1st completes)
  static final Set<String> _processingLeads = {};

  static Future<void> init() async {
    if (_initialized) return;

    db = AppDatabase();
    _initialized = true;
    _startSyncManager();
  }

  static Stream<List<Lead>> getLeadsStream() {
    return db.select(db.leads).watch();
  }

  static Stream<Lead?> getLeadByIdStream(String id) {
    return (db.select(db.leads)..where((l) => l.id.equals(id)))
        .watchSingleOrNull();
  }

  static Stream<List<Lead>> getFilteredLeadsStream(List<String> statuses, {String? sortBy}) {
    final query = db.select(db.leads)..where((l) => l.leadStatus.isIn(statuses));
    
    if (sortBy == 'followup_time') {
      query.orderBy([(t) => OrderingTerm(expression: t.followupTime, mode: OrderingMode.desc)]);
    } else if (sortBy == 'lead_status_date') {
      query.orderBy([(t) => OrderingTerm(expression: t.leadStatusDate, mode: OrderingMode.desc)]);
    }
    
    return query.watch();
  }

  static Future<bool> hasPendingFeedback() async {
    final calledLeads = await (db.select(db.leads)
          ..where((l) => l.leadStatus.equals('Called')))
        .get();
    
    if (calledLeads.isNotEmpty) return true;

    final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
    final oldHoldLeads = await (db.select(db.leads)
          ..where((l) => l.leadStatus.equals('Hold') & l.leadStatusDate.isSmallerThanValue(twoDaysAgo)))
        .get();
    
    return oldHoldLeads.isNotEmpty;
  }

  static Future<String> createNewLead({
    required String customerName,
    required String mobileNo,
    required String city,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = const Uuid().v4().replaceAll('-', '').substring(0, 5);
    final leadId = '${timestamp.substring(timestamp.length - 10)}$random';
    
    final user = PB.pb.authStore.record;
    
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final now = DateTime.now();
    
    final companion = LeadsCompanion(
      id: Value(leadId),
      customerName: Value(customerName),
      mobileNo: Value(mobileNo),
      city: Value(city),
      segment: const Value(null),
      employer: const Value(null),
      declineReason: const Value(null),
      product: const Value(null),
      assignedTo: Value(user.id),
      assignedDate: Value(now),
      employeeName: Value(user.data['employee_name'] ?? ''),
      employeeCode: Value(user.data['employee_code'] ?? ''),
      leadStatus: const Value('New'),
      leadStatusDate: Value(now),
      dataStatus: const Value(null),
      followupTime: const Value(null),
      arnNo: const Value(null),
      dateOfBirth: const Value(null),
      remarks: const Value(null),
      syncPending: const Value(true),
    );

    await db.into(db.leads).insert(companion);
    
    return leadId;
  }

  static void _startSyncManager() {
    syncUp();
    syncDown();

    Connectivity().onConnectivityChanged.listen((status) {
      if (!status.contains(ConnectivityResult.none) && status.isNotEmpty) {
        syncUp();
        syncDown();
        if (!_isSubscribed) {
          subscribeToLeads();
        }
      }
    });

    subscribeToLeads();
  }

  static bool _isSyncingDown = false;

  static Future<void> syncDown({bool silent = false}) async {
    if (_isSyncingDown) return;
    _isSyncingDown = true;

    try {
      final user = PB.pb.authStore.record;
      if (user == null) return;

      List<pb_lib.RecordModel> records = [];
      int retryCount = 0;
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          records = await PB.pb.collection('leads').getFullList(
            filter: 'assigned_to = "${user.id}"',
          );
          break;
        } catch (e) {
          retryCount++;
          if (retryCount >= maxRetries) rethrow;
          await Future.delayed(Duration(seconds: 2 * retryCount));
        }
      }

      final serverLeadIds = records.map((r) => r.id).toSet();

      for (var record in records) {
        await _upsertSingleLead(record, isFromSyncDown: true);
      }

      final localLeads = await (db.select(db.leads)).get();
      // Threshold: pending leads older than 2 days are considered permanently stuck
      final stuckThreshold = DateTime.now().subtract(const Duration(days: 2));

      for (var localLead in localLeads) {
        if (!serverLeadIds.contains(localLead.id)) {
          // Check if this is a pending lead that has been stuck for over 2 days
          final isStuck = localLead.syncPending && localLead.leadStatusDate.isBefore(stuckThreshold);
          
          // Only delete if it's NOT pending (already synced but removed from server)
          // OR if it's permanently stuck in an error state
          if (!localLead.syncPending || isStuck) {
            await (db.delete(db.leads)..where((t) => t.id.equals(localLead.id))).go();
          }
        }
      }
    } catch (e) {
      PB.handleAuthError(e);
    } finally {
      _isSyncingDown = false;
    }
  }

  static bool _isSubscribed = false;

  static Future<void> subscribeToLeads() async {
    if (_isSubscribed) return;
    _isSubscribed = true;

    final user = PB.pb.authStore.record;
    if (user == null) {
      _isSubscribed = false;
      return;
    }

    PB.pb.realtime.subscribe('PB_CONNECT', (e) {});
    PB.pb.realtime.subscribe('PB_DISCONNECT', (e) {});

    try {
      final testLeads = await PB.pb.collection('leads').getFullList(
        filter: 'assigned_to = "${user.id}"',
      );

      if (testLeads.isNotEmpty) {
        try {
          await PB.pb.collection('leads').getOne(testLeads.first.id);
        } catch (e) {
          _isSubscribed = false;
          return;
        }
      }

      PB.pb.collection('leads').subscribe('*', (e) async {
        if (_shouldBatchSync()) {
          _scheduleBatchSync();
          return;
        }

        if (e.record != null) {
          final assignedTo = e.record!.data['assigned_to'];

          if (e.action == 'delete') {
            await _deleteLeadLocally(e.record!.id);
            return;
          }

          if (assignedTo == user.id) {
            await _upsertSingleLead(e.record!, isFromSyncDown: false);
          } else {
            final localLead = await (db.select(db.leads)..where((t) => t.id.equals(e.record!.id))).getSingleOrNull();

            if (localLead != null && localLead.syncPending) {
              try {
                await PB.pb.collection('leads').update(localLead.id, body: {
                  'lead_status': localLead.leadStatus,
                });
              } catch (e) {}
            }

            await _deleteLeadLocally(e.record!.id);
          }
        }
      });
    } catch (e, stackTrace) {
      _isSubscribed = false;
    }
  }

  static bool _shouldBatchSync() {
    _eventCount++;
    _firstEventTime ??= DateTime.now();

    final elapsed = DateTime.now().difference(_firstEventTime!);

    if (_eventCount > _batchThreshold && elapsed.inSeconds < _batchWindowSeconds) {
      return true;
    }

    if (elapsed.inSeconds > _batchWindowSeconds) {
      _eventCount = 0;
      _firstEventTime = null;
    }

    return false;
  }

  static void _scheduleBatchSync() {
    _batchSyncTimer?.cancel();

    _batchSyncTimer = Timer(Duration(seconds: _batchWindowSeconds), () async {
      await syncDown();
      _eventCount = 0;
      _firstEventTime = null;
    });
  }

  static Future<void> manualRefresh() async {
    await syncDown();
  }

  static Future<void> _deleteLeadLocally(String leadId) async {
    try {
      await (db.delete(db.leads)..where((t) => t.id.equals(leadId))).go();
    } catch (e) {}
  }

  static Future<void> _upsertSingleLead(pb_lib.RecordModel record, {required bool isFromSyncDown}) async {
    final String leadId = record.id;

    await db.transaction(() async {
      final existing = await (db.select(db.leads)..where((t) => t.id.equals(leadId))).getSingleOrNull();

      final now = DateTime.now();
      
      final companion = LeadsCompanion(
        id: Value(leadId),
        customerName: Value(record.data['customer_name'] ?? ''),
        mobileNo: Value(record.data['mobile_no'] ?? ''),
        city: Value(record.data['city']),
        segment: Value(record.data['segment']),
        employer: Value(record.data['employer']),
        declineReason: Value(record.data['decline_reason']),
        product: Value(record.data['product']),
        assignedTo: Value(record.data['assigned_to']),
        assignedDate: Value(_parseDateTime(record.data['assigned_date']) ?? now),
        employeeName: Value(record.data['employee_name']),
        employeeCode: Value(record.data['employee_code']),
        leadStatus: Value(record.data['lead_status'] ?? 'New'),
        leadStatusDate: Value(_parseDateTime(record.data['lead_status_date']) ?? now),
        dataStatus: Value(record.data['data_status']),
        followupTime: Value(_parseDateTime(record.data['followup_time'])),
        arnNo: Value(record.data['arn_no']),
        dateOfBirth: Value(_parseDateTime(record.data['date_of_birth'])),
        remarks: Value(record.data['remarks']),
        syncPending: const Value(false),
      );

      if (existing != null) {
        if (existing.syncPending) {
          return;
        }
        await (db.update(db.leads)..where((t) => t.id.equals(leadId))).write(companion);
      } else {
        await db.into(db.leads).insert(companion);
      }
    });
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null || value == '') return null;
    try {
      final utcTime = DateTime.parse(value.toString());
      return utcTime.toLocal();
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateLeadStatus(
    String leadId,
    String newStatus, {
    DateTime? followupTime,
    String? arnNo,
    DateTime? dateOfBirth,
    String? remarks,
  }) async {
    // Double-tap guard: if this lead is already being processed, ignore the call.
    if (_processingLeads.contains(leadId)) return;
    _processingLeads.add(leadId);

    try {
      final now = DateTime.now();

      final lead = await (db.select(db.leads)..where((t) => t.id.equals(leadId))).getSingleOrNull();
      if (lead == null) return;

      await (db.update(db.leads)..where((t) => t.id.equals(leadId))).write(
        LeadsCompanion(
          leadStatus: Value(newStatus),
          leadStatusDate: Value(now),
          followupTime: Value(followupTime),
          arnNo: Value(arnNo),
          dateOfBirth: Value(dateOfBirth),
          remarks: Value(remarks),
          syncPending: const Value(true),
        ),
      );

      final user = PB.pb.authStore.record;
      if (user != null) {
        await LeadFeedbackService.addFeedback(
          leadId: leadId,
          customerName: lead.customerName,
          mobileNo: lead.mobileNo,
          leadStatus: newStatus,
          leadStatusDate: now,
          user: user.id,
          employeeName: user.getStringValue('employee_name'),
          employeeCode: user.getStringValue('employee_code'),
        );
      }

      syncUp();
    } finally {
      _processingLeads.remove(leadId);
    }
  }

  static bool _isSyncingUp = false;

  static Future<void> syncUp() async {
    if (_isSyncingUp) return;
    _isSyncingUp = true;
    
    try {
      final pendingLeads = await (db.select(db.leads)..where((t) => t.syncPending.equals(true))).get();

      if (pendingLeads.isEmpty) return;

      for (var lead in pendingLeads) {
        try {
          final snapshotDate = lead.leadStatusDate;
          final body = {
            'customer_name': lead.customerName,
            'mobile_no': lead.mobileNo,
            'city': lead.city,
            'segment': lead.segment,
            'employer': lead.employer,
            'decline_reason': lead.declineReason,
            'product': lead.product,
            'assigned_to': lead.assignedTo,
            'assigned_date': lead.assignedDate.toUtc().toIso8601String(),
            'employee_name': lead.employeeName,
            'employee_code': lead.employeeCode,
            'lead_status': lead.leadStatus,
            'lead_status_date': lead.leadStatusDate.toUtc().toIso8601String(),
            'data_status': lead.dataStatus,
            'followup_time': lead.followupTime?.toUtc().toIso8601String(),
            'arn_no': lead.arnNo,
            'date_of_birth': lead.dateOfBirth != null 
                ? DateTime.utc(lead.dateOfBirth!.year, lead.dateOfBirth!.month, lead.dateOfBirth!.day).toIso8601String()
                : null,
            'remarks': lead.remarks,
          };

          try {
            await PB.pb.collection('leads').update(lead.id, body: body);
          } catch (e) {
            await PB.pb.collection('leads').create(body: {...body, 'id': lead.id});
          }

          // Strict Guard: Only clear syncPending if the user hasn't made another local update while the network request was flying
          await db.transaction(() async {
            final currentLocal = await (db.select(db.leads)..where((t) => t.id.equals(lead.id))).getSingleOrNull();
            if (currentLocal != null && currentLocal.syncPending) {
              if (currentLocal.leadStatusDate.millisecondsSinceEpoch == snapshotDate.millisecondsSinceEpoch) {
                await (db.update(db.leads)..where((t) => t.id.equals(lead.id))).write(
                  const LeadsCompanion(syncPending: Value(false)),
                );
              }
            }
          });
        } catch (e) {
          PB.handleAuthError(e);
        }
      }
    } catch (e) {
      PB.handleAuthError(e);
    } finally {
      _isSyncingUp = false;
    }
  }
}