import 'dart:async';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart';
import '../core/pb_api.dart';
import '../models/login_case_model.dart' as model;
import '../database/app_database.dart';
import 'lead_service.dart';

enum DateFilterType { thisMonth, lastMonth }
enum StatusFilterType { all, approved, declined }

class LoginCaseService {
  static AppDatabase get _db => LeadService.db;
  static bool _isSubscribed = false;

  static void init() {
    if (PB.pb.authStore.isValid) {
      initializeRealtime();
    }
  }

  static void initializeRealtime() {
    if (_isSubscribed) return;
    
    final employeeCode = PB.pb.authStore.record?.data['employee_code'] ?? '';
    
    PB.pb.collection('case_login').subscribe('*', (e) async {
      if (e.record == null) return;
      
      final record = e.record!;
      final recordEmployeeCode = record.data['employee_code'];
      
      if (recordEmployeeCode != employeeCode) return;
      
      try {
        if (e.action == 'create') {
          final loginCase = model.LoginCase.fromJson(record.toJson());
          await _db.into(_db.loginCases).insert(loginCase.toDrift());
        } else if (e.action == 'update') {
          final loginCase = model.LoginCase.fromJson(record.toJson());
          await _db.update(_db.loginCases).replace(loginCase.toDrift());
        } else if (e.action == 'delete') {
          await (_db.delete(_db.loginCases)..where((t) => t.id.equals(record.id))).go();
        }
      } catch (_) {}
    }).then((unsubscribe) {
      _isSubscribed = true;
    }).catchError((_) {});
  }

  static Future<List<model.LoginCase>> fetchCases({
    required DateFilterType dateFilter,
    StatusFilterType statusFilter = StatusFilterType.all,
  }) async {
    final dateRange = getDateRange(dateFilter);
    final startDate = dateRange['start']!;
    final endDate = dateRange['end']!;

    var query = _db.select(_db.loginCases)
      ..where((t) =>
          t.leadStatusDate.isBiggerOrEqualValue(startDate) &
          t.leadStatusDate.isSmallerOrEqualValue(endDate));

    if (statusFilter == StatusFilterType.approved) {
      query = query..where((t) => t.leadStatus.equals('IP Approved'));
    } else if (statusFilter == StatusFilterType.declined) {
      query = query..where((t) => t.leadStatus.equals('IP Decline'));
    }

    query = query..orderBy([(t) => OrderingTerm.desc(t.leadStatusDate)]);

    final driftRecords = await query.get();
    return driftRecords.map((r) => model.LoginCase.fromDrift(r)).toList();
  }

  static Stream<List<model.LoginCase>> watchCases({
    required DateFilterType dateFilter,
    StatusFilterType statusFilter = StatusFilterType.all,
    String? searchQuery,
  }) {
    var query = _db.select(_db.loginCases);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query..where((t) =>
          t.customerName.like('%$searchQuery%') |
          t.mobileNumber.like('%$searchQuery%') |
          t.arnNo.like('%$searchQuery%'));
    } else {
      final dateRange = getDateRange(dateFilter);
      final startDate = dateRange['start']!;
      final endDate = dateRange['end']!;

      query = query..where((t) =>
          t.leadStatusDate.isBiggerOrEqualValue(startDate) &
          t.leadStatusDate.isSmallerOrEqualValue(endDate));

      if (statusFilter == StatusFilterType.approved) {
        query = query..where((t) => t.leadStatus.equals('IP Approved'));
      } else if (statusFilter == StatusFilterType.declined) {
        query = query..where((t) => t.leadStatus.equals('IP Decline'));
      }
    }

    query = query..orderBy([(t) => OrderingTerm.desc(t.leadStatusDate)]);

    return query.watch().map((driftRecords) =>
        driftRecords.map((r) => model.LoginCase.fromDrift(r)).toList());
  }

  static Future<void> syncFromServer() async {
    final employeeCode = PB.pb.authStore.record?.data['employee_code'] ?? '';
    
    final records = await PB.pb.collection('case_login').getFullList(
      filter: 'employee_code = "$employeeCode"',
      sort: '-lead_status_date',
    );

    final cases = records.map((r) => model.LoginCase.fromJson(r.toJson())).toList();

    await _db.transaction(() async {
      await _db.delete(_db.loginCases).go();
      
      await _db.batch((batch) {
        batch.insertAll(_db.loginCases, cases.map((c) => c.toDrift()).toList());
      });
    });
  }

  static Future<int> getTodayIpaCount() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final count = await (_db.selectOnly(_db.loginCases)
          ..addColumns([_db.loginCases.id.count()])
          ..where(_db.loginCases.leadStatus.equals('IP Approved') &
              _db.loginCases.leadStatusDate.isBiggerOrEqualValue(today) &
              _db.loginCases.leadStatusDate.isSmallerThanValue(tomorrow)))
        .getSingle();

    return count.read(_db.loginCases.id.count()) ?? 0;
  }

  static Future<int> getTodayIpdCount() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final count = await (_db.selectOnly(_db.loginCases)
          ..addColumns([_db.loginCases.id.count()])
          ..where(_db.loginCases.leadStatus.equals('IP Decline') &
              _db.loginCases.leadStatusDate.isBiggerOrEqualValue(today) &
              _db.loginCases.leadStatusDate.isSmallerThanValue(tomorrow)))
        .getSingle();

    return count.read(_db.loginCases.id.count()) ?? 0;
  }

  static Future<double> getTodayApprovalRate() async {
    final ipaCount = await getTodayIpaCount();
    final ipdCount = await getTodayIpdCount();
    final total = ipaCount + ipdCount;

    if (total == 0) return 0.0;
    return (ipaCount / total) * 100;
  }

  static Future<int> getIpaCount(DateTime startDate, DateTime endDate) async {
    final count = await (_db.selectOnly(_db.loginCases)
          ..addColumns([_db.loginCases.id.count()])
          ..where(_db.loginCases.leadStatus.equals('IP Approved') &
              _db.loginCases.leadStatusDate.isBiggerOrEqualValue(startDate) &
              _db.loginCases.leadStatusDate.isSmallerOrEqualValue(endDate)))
        .getSingle();

    return count.read(_db.loginCases.id.count()) ?? 0;
  }

  static Future<int> getIpdCount(DateTime startDate, DateTime endDate) async {
    final count = await (_db.selectOnly(_db.loginCases)
          ..addColumns([_db.loginCases.id.count()])
          ..where(_db.loginCases.leadStatus.equals('IP Decline') &
              _db.loginCases.leadStatusDate.isBiggerOrEqualValue(startDate) &
              _db.loginCases.leadStatusDate.isSmallerOrEqualValue(endDate)))
        .getSingle();

    return count.read(_db.loginCases.id.count()) ?? 0;
  }

  static Future<int> getTotalLoginCount(DateTime startDate, DateTime endDate) async {
    final count = await (_db.selectOnly(_db.loginCases)
          ..addColumns([_db.loginCases.id.count()])
          ..where(_db.loginCases.leadStatusDate.isBiggerOrEqualValue(startDate) &
              _db.loginCases.leadStatusDate.isSmallerOrEqualValue(endDate)))
        .getSingle();

    return count.read(_db.loginCases.id.count()) ?? 0;
  }

  static Future<double> getApprovalRate(DateTime startDate, DateTime endDate) async {
    final ipaCount = await getIpaCount(startDate, endDate);
    final ipdCount = await getIpdCount(startDate, endDate);
    final total = ipaCount + ipdCount;

    if (total == 0) return 0.0;
    return (ipaCount / total) * 100;
  }

  static Map<String, List<model.LoginCase>> groupByDate(List<model.LoginCase> cases) {
    final grouped = <String, List<model.LoginCase>>{};
    
    for (var loginCase in cases) {
      final key = _getDateKey(loginCase.leadStatusDate);
      
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(loginCase);
    }
    
    return grouped;
  }

  static String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final caseDate = DateTime(date.year, date.month, date.day);
    
    if (caseDate == today) return 'TODAY';
    if (caseDate == yesterday) return 'YESTERDAY';
    return DateFormat('dd MMM yyyy').format(date).toUpperCase();
  }

  static Map<String, DateTime> getDateRange(DateFilterType filterType) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (filterType) {
      case DateFilterType.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case DateFilterType.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        startDate = lastMonth;
        endDate = DateTime(now.year, now.month, 0, 23, 59, 59);
        break;
    }

    return {'start': startDate, 'end': endDate};
  }
}
