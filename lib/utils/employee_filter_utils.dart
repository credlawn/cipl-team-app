import '../core/pb_api.dart';

/// Utility class for filtering employee lists based on various criteria
class EmployeeFilterUtils {
  /// Filter employees to show only present ones
  /// Present = employees who are either in office or WFH (not absent)
  static List<T> filterPresentOnly<T>(
    List<T> employees, {
    required bool Function(T) isPresentCheck,
  }) {
    return employees.where(isPresentCheck).toList();
  }

  /// Filter call logs to show only present employees
  static List<Map<String, dynamic>> filterPresentCallLogs(
    List<Map<String, dynamic>> logs,
  ) {
    // Present employees have call_count > 0 or are marked as present
    return logs.where((log) {
      final callCount = log['call_count'] ?? 0;
      final totalDuration = log['total_duration'] ?? 0;
      // Employee is present if they have made calls or have duration
      return callCount > 0 || totalDuration > 0;
    }).toList();
  }

  /// Separate employees into Office and WFH categories
  static Map<String, List<Map<String, dynamic>>> separateByLocation(
    List<Map<String, dynamic>> employees,
  ) {
    final office = <Map<String, dynamic>>[];
    final wfh = <Map<String, dynamic>>[];
    
    for (var emp in employees) {
      if (emp['wfh'] == true) {
        wfh.add(emp);
      } else {
        office.add(emp);
      }
    }
    
    return {
      'office': office,
      'wfh': wfh,
    };
  }

  /// Sort employees by a numeric field (high to low)
  static void sortByField(
    List<Map<String, dynamic>> employees,
    String fieldName, {
    bool ascending = false,
  }) {
    employees.sort((a, b) {
      final aValue = (a[fieldName] ?? 0) as int;
      final bValue = (b[fieldName] ?? 0) as int;
      return ascending 
          ? aValue.compareTo(bValue)
          : bValue.compareTo(aValue);
    });
  }

  /// Filter and separate employees by location
  /// Set presentOnly to true to show only employees with call activity
  static Map<String, List<Map<String, dynamic>>> getPresentByLocation(
    List<Map<String, dynamic>> allEmployees, {
    bool presentOnly = true,
  }) {
    final employees = presentOnly 
        ? filterPresentCallLogs(allEmployees)
        : allEmployees;
    return separateByLocation(employees);
  }

  /// Filter EmployeePerformance list to show only present employees
  /// Present = employees with totalLeads > 0 (have worked on leads)
  static List<T> filterPresentEmployees<T>(
    List<T> employees, {
    required int Function(T) getTotalLeads,
  }) {
    return employees.where((emp) => getTotalLeads(emp) > 0).toList();
  }

  /// Get present employees with Office/WFH grouping based on attendance
  /// Returns Map with employee_codes grouped by location
  /// Reference: Attendance module pattern
  static Future<Map<String, List<String>>> getPresentEmployeesWithGrouping({
    DateTime? date,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();
      final today = DateTime(targetDate.year, targetDate.month, targetDate.day);
      
      
      // Get active employees
      final employees = await PB.pb.collection('users').getFullList(
        filter: '(role ~ "employee" || role ~ "manager") && disabled = false && no_atn = false',
        sort: 'employee_name',
      );
      
      // Get attendance for target date - use space-separated format for Pocketbase
      final startStr = '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')} 00:00:00';
      final tomorrow = today.add(const Duration(days: 1));
      final endStr = '${tomorrow.year.toString().padLeft(4, '0')}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')} 00:00:00';
      
      final attendanceRecords = await PB.pb.collection('attendance').getFullList(
        filter: 'attendance_date >= "$startStr" && attendance_date < "$endStr"',
      );
      
      // Create attendance map
      final attendanceMap = <String, Map<String, dynamic>>{};
      for (var record in attendanceRecords) {
        final empCode = record.data['employee_code'];
        if (empCode != null && empCode.toString().isNotEmpty) {
          attendanceMap[empCode.toString()] = record.toJson();
        }
      }
      
      // Filter present employees and group by location
      final officeEmployees = <String>[];
      final wfhEmployees = <String>[];
      
      for (var employee in employees) {
        final empCode = employee.data['employee_code']?.toString() ?? '';
        final isWFH = employee.data['wfh'] == true;
        
        if (empCode.isNotEmpty && attendanceMap.containsKey(empCode)) {
          final attendance = attendanceMap[empCode]!;
          
          // Check if employee has checked in
          if (attendance['check_in_time'] != null && 
              attendance['check_in_time'].toString().isNotEmpty) {
            if (isWFH) {
              wfhEmployees.add(empCode);
            } else {
              officeEmployees.add(empCode);
            }
          }
        }
      }
      
      return {
        'office': officeEmployees,
        'wfh': wfhEmployees,
        'all': [...officeEmployees, ...wfhEmployees],
      };
    } catch (e) {
      
      return {
        'office': [],
        'wfh': [],
        'all': [],
      };
    }
  }
}
