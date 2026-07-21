import '../core/pb_api.dart';
import '../models/dashboard_summary.dart';
import '../models/employee_performance.dart';

class ManagerDashboardService {
  static Future<DashboardSummary> getSummary() async {
    try {
      final response = await PB.pb.send('/api/dashboard/summary');
      return DashboardSummary.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load dashboard summary: $e');
    }
  }

  static Future<List<EmployeePerformance>> getEmployeePerformance({
    String? dateFilter,
  }) async {
    try {
      // Use pivot API which has proper date filtering
      final filterType = _getFilterTypeFromQuery(dateFilter);
      final pivotResponse = await PB.pb.send(
        '/api/leads/pivot',
        query: filterType != null ? {'filter_type': filterType} : {},
      );
      
      final statsQuery = dateFilter != null && dateFilter.isNotEmpty
          ? {'filter': dateFilter}
          : {'filter': "date(created)=date('now')"};
      
      final statsResponse = await PB.pb.send(
        '/api/employee/stats',
        query: statsQuery,
      );

      final pivotData = (pivotResponse as List)
          .map((e) => EmployeePerformance.fromLeadsJson(e as Map<String, dynamic>))
          .toList();

      final statsMap = <String, Map<String, int>>{};
      for (var stat in (statsResponse as List)) {
        final statData = stat as Map<String, dynamic>;
        statsMap[statData['employee_code']] = {
          'ipa': statData['ipa'] ?? 0,
          'ipd': statData['ipd'] ?? 0,
        };
      }

      final mergedData = pivotData.map((emp) {
        final stats = statsMap[emp.employeeCode];
        if (stats != null) {
          return emp.copyWith(
            ipa: stats['ipa'],
            ipd: stats['ipd'],
          );
        }
        return emp;
      }).toList();

      return mergedData;
    } catch (e) {
      throw Exception('Failed to load employee performance: $e');
    }
  }

  static String? _getFilterTypeFromQuery(String? query) {
    if (query == null || query.isEmpty) return 'today';
    if (query.contains("date('now')") && !query.contains('-')) return 'today';
    if (query.contains("'-1 day'")) return 'yesterday';
    if (query.contains("'-7 days'")) return 'this_week';
    return 'today';
  }

  static String getDateFilterQuery(String filter) {
    switch (filter) {
      case 'today':
        return "date(created)=date('now')";
      case 'yesterday':
        return "date(created)=date('now','-1 day')";
      case 'this_week':
        return "date(created)>=date('now','-7 days')";
      case 'this_month':
        return "date(created)>=date('now','start of month')";
      default:
        return "date(created)=date('now')";
    }
  }
}
