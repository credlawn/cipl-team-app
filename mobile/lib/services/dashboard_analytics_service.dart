import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import '../database/app_database.dart';
import '../models/dashboard_analytics_model.dart';
import 'lead_service.dart';

enum DateFilter { today, week, month }

class DashboardAnalyticsService {
  static AppDatabase get _db => LeadService.db;

  static Future<DashboardAnalytics> getAnalytics(DateFilter filter) async {
    final dateRange = _getDateRange(filter);
    final startDate = dateRange['start']!;
    final endDate = dateRange['end']!;

    final keyMetrics = await _getKeyMetrics(startDate, filter);
    
    final callMetrics = await _getCallMetrics(startDate, endDate);
    
    final weeklyTrend = await _getWeeklyTrend();

    return DashboardAnalytics(
      ipaCount: keyMetrics['ipaCount']!,
      ipdCount: keyMetrics['ipdCount']!,
      loginCount: keyMetrics['loginCount']!,
      approvalRate: keyMetrics['approvalRate']!.toDouble(),
      approvalTrend: keyMetrics['trend']! > 0 ? 'up' : (keyMetrics['trend']! < 0 ? 'down' : 'neutral'),
      totalCalls: callMetrics['totalCalls']!,
      answeredCalls: callMetrics['answeredCalls']!,
      cnrCalls: callMetrics['cnrCalls']!,
      answerRate: callMetrics['answerRate']!.toDouble(),
      totalTalkTime: Duration(seconds: callMetrics['totalTalkTime']!),
      avgCallDuration: Duration(seconds: callMetrics['avgDuration']!),
      hourlyEfficiency: callMetrics['hourlyEfficiency']!.toDouble(),
      lastCallTime: callMetrics['lastCallTime'] as DateTime?,
      callsByDay: weeklyTrend['callsByDay']!,
      durationByDay: weeklyTrend['durationByDay']!,
    );
  }

  static Map<String, DateTime> _getDateRange(DateFilter filter) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (filter) {
      case DateFilter.today:
        start = DateTime(now.year, now.month, now.day);
        break;
      case DateFilter.week:
        start = now.subtract(const Duration(days: 7));
        break;
      case DateFilter.month:
        start = DateTime(now.year, now.month, 1);
        break;
    }

    return {'start': start, 'end': end};
  }

  static Future<Map<String, int>> _getKeyMetrics(DateTime startDate, DateFilter filter) async {
    final ipaLeads = await (_db.select(_db.leads)
          ..where((t) =>
              t.leadStatus.equals('IP Approved') &
              t.leadStatusDate.isBiggerOrEqualValue(startDate)))
        .get();

    final ipdLeads = await (_db.select(_db.leads)
          ..where((t) =>
              t.leadStatus.equals('IP Decline') &
              t.leadStatusDate.isBiggerOrEqualValue(startDate)))
        .get();

    final ipaCount = ipaLeads.length;
    final ipdCount = ipdLeads.length;
    final loginCount = ipaCount + ipdCount;
    final approvalRate = loginCount > 0 ? ((ipaCount / loginCount) * 100).round() : 0;

    DateTime previousStart;
    DateTime previousEnd;
    
    if (filter == DateFilter.today) {
      previousStart = startDate.subtract(const Duration(days: 1));
      previousEnd = startDate;
    } else {
      final daysDiff = DateTime.now().difference(startDate).inDays;
      previousStart = startDate.subtract(Duration(days: daysDiff));
      previousEnd = startDate;
    }

    final previousIpa = await (_db.select(_db.leads)
          ..where((t) =>
              t.leadStatus.equals('IP Approved') &
              t.leadStatusDate.isBiggerOrEqualValue(previousStart) &
              t.leadStatusDate.isSmallerThanValue(previousEnd)))
        .get();
    
    final previousIpd = await (_db.select(_db.leads)
          ..where((t) =>
              t.leadStatus.equals('IP Decline') &
              t.leadStatusDate.isBiggerOrEqualValue(previousStart) &
              t.leadStatusDate.isSmallerThanValue(previousEnd)))
        .get();

    final previousLogin = previousIpa.length + previousIpd.length;
    final previousRate = previousLogin > 0 ? ((previousIpa.length / previousLogin) * 100).round() : 0;
    final trend = approvalRate - previousRate;

    return {
      'ipaCount': ipaCount,
      'ipdCount': ipdCount,
      'loginCount': loginCount,
      'approvalRate': approvalRate,
      'trend': trend,
    };
  }

  static Future<Map<String, dynamic>> _getCallMetrics(
      DateTime startDate, DateTime endDate) async {
    final callLogs = await (_db.select(_db.callLogs)
          ..where((t) =>
              t.callTimestamp.isBiggerOrEqualValue(startDate) &
              t.callTimestamp.isSmallerOrEqualValue(endDate))
          ..orderBy([(t) => OrderingTerm.desc(t.callTimestamp)]))
        .get();

    final totalCalls = callLogs.length;
    final answeredCalls =
        callLogs.where((c) => c.callDuration > 0).length;
    final cnrCalls = callLogs
        .where((c) => c.callType == 'outgoing' && c.callDuration == 0)
        .length;
    final answerRate =
        totalCalls > 0 ? ((answeredCalls / totalCalls) * 100).round() : 0;

    final totalTalkTime = callLogs
        .where((c) => c.callDuration > 0)
        .map((c) => c.callDuration)
        .fold(0, (sum, duration) => sum + duration);

    final avgDuration = answeredCalls > 0 ? totalTalkTime ~/ answeredCalls : 0;

    final now = DateTime.now();
    final hoursWorked = now.difference(startDate).inHours.toDouble();
    final hourlyEfficiency =
        hoursWorked > 0 ? (totalCalls / hoursWorked * 10).round() / 10 : 0.0;

    final connectedCalls = callLogs.where((c) => c.callDuration > 0).toList();
    final lastCallTime = connectedCalls.isNotEmpty ? connectedCalls.first.callTimestamp : null;

    return {
      'totalCalls': totalCalls,
      'answeredCalls': answeredCalls,
      'cnrCalls': cnrCalls,
      'answerRate': answerRate,
      'totalTalkTime': totalTalkTime,
      'avgDuration': avgDuration,
      'hourlyEfficiency': hourlyEfficiency,
      'lastCallTime': lastCallTime,
    };
  }

  static Future<Map<String, Map<String, int>>> _getWeeklyTrend() async {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final weeklyLogs = await (_db.select(_db.callLogs)
          ..where((t) => t.callTimestamp.isBiggerOrEqualValue(weekAgo)))
        .get();

    final callsByDay = <String, int>{};
    final durationByDay = <String, int>{};
    
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dayName = DateFormat('EEE').format(date);
      callsByDay[dayName] = 0;
      durationByDay[dayName] = 0;
    }

    for (var log in weeklyLogs) {
      final day = DateFormat('EEE').format(log.callTimestamp);
      if (callsByDay.containsKey(day)) {
        if (log.callDuration > 0) {
          callsByDay[day] = callsByDay[day]! + 1;
          durationByDay[day] = durationByDay[day]! + log.callDuration;
        }
      }
    }

    return {
      'callsByDay': callsByDay,
      'durationByDay': durationByDay,
    };
  }
}
