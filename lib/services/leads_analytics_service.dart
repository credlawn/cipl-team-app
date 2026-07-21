import 'package:intl/intl.dart';
import '../core/pb_api.dart';
import 'employee_presence_service.dart';

class LeadsAnalyticsService {
  /// Get complete analytics data (summary + employees)
  static Future<Map<String, dynamic>> getAnalyticsData({
    String? filterType,
    String? date,
    String? employeeCode,
  }) async {
    final query = <String, String>{};
    
    if (filterType != null && filterType.isNotEmpty) {
      query['filter_type'] = filterType;
    }
    
    if (date != null && date.isNotEmpty) {
      query['date'] = date;
    }
    
    if (employeeCode != null && employeeCode.isNotEmpty) {
      query['employee_code'] = employeeCode;
    }

    final response = await PB.pb.send('/api/leads/pivot', query: query);
    return Map<String, dynamic>.from(response);
  }

  /// Get pivot table data (backward compatible - returns employees array)
  static Future<List<Map<String, dynamic>>> getPivotData({
    String? filterType,
    String? date,
    String? employeeCode,
  }) async {
    final data = await getAnalyticsData(
      filterType: filterType,
      date: date,
      employeeCode: employeeCode,
    );
    return List<Map<String, dynamic>>.from(data['employees'] ?? []);
  }

  /// Get count of PRESENT employees with 0 new leads
  static Future<int> getEmployeesWithZeroNewLeads() async {
    try {
      // Import needed for attendance check
      final presentData = await EmployeePresenceService.getPresentEmployees();
      final presentCodes = Set<String>.from(presentData['all'] ?? []);
      
      final data = await getPivotData(filterType: 'today');
      
      // Count only present employees with 0 new leads
      return data.where((e) {
        final employeeCode = e['employee_code'] as String?;
        final newLeads = e['new'] as int? ?? 0;
        return employeeCode != null && 
               presentCodes.contains(employeeCode) && 
               newLeads == 0;
      }).length;
    } catch (e) {
      return 0;
    }
  }
}
