import 'package:intl/intl.dart';
import '../core/pb_api.dart';

class ManagerCallLogService {
  // Get summary for dashboard card
  static Future<Map<String, dynamic>> getCallLogsSummary({
    DateTime? date,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(targetDate);
      
      final response = await PB.pb.send(
        '/api/call-logs/summary',
        query: {'date': dateStr},
      );
      
      return {
        'present_count': response['present_count'] ?? 0,
        'total_calls': response['total_calls'] ?? 0,
        'total_duration': response['total_duration'] ?? 0,
        'avg_per_hour': response['avg_per_hour'] ?? 0,
      };
    } catch (e) {
      return {
        'present_count': 0,
        'total_calls': 0,
        'total_duration': 0,
        'avg_per_hour': 0,
      };
    }
  }

  // Get detail for employee list
  static Future<List<Map<String, dynamic>>> getCallLogsDetail({
    required DateTime date,
  }) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      
      final response = await PB.pb.send(
        '/api/call-logs/detail',
        query: {'date': dateStr},
      );
      
      if (response is! List) {
        return [];
      }
      
      return response.map((item) {
        return {
          'employee_code': item['employee_code'] ?? '',
          'employee_name': item['employee_name'] ?? '',
          'wfh': item['wfh'] ?? false,
          'call_count': item['call_count'] ?? 0,
          'total_duration': item['total_duration'] ?? 0,
          'last_call_time': item['last_call_time'] != null && item['last_call_time'] != ''
              ? DateTime.parse(item['last_call_time']).toLocal()
              : null,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get hourly breakdown for employee
  static Future<List<Map<String, dynamic>>> getEmployeeCallHistoryHourly({
    required String employeeCode,
    required DateTime date,
  }) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      
      final response = await PB.pb.send(
        '/api/call-logs/hourly',
        query: {
          'employee_code': employeeCode,
          'date': dateStr,
        },
      );
      
      if (response is! List) {
        return [];
      }
      
      return response.map((item) {
        return {
          'hour': item['hour'] ?? 11,
          'call_count': item['call_count'] ?? 0,
          'total_duration': item['total_duration'] ?? 0,
          'idle_time': item['idle_time'] ?? 3600,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Format duration in seconds to readable string
  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }

  // Get relative time string (e.g., "10m ago")
  static String getRelativeTime(DateTime? callTime) {
    if (callTime == null) return '-';
    
    final now = DateTime.now();
    final diff = now.difference(callTime);
    
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      final minutes = diff.inMinutes % 60;
      if (minutes == 0) {
        return '${diff.inHours}h';
      }
      return '${diff.inHours}h ${minutes}m';
    } else {
      return '${diff.inDays}d';
    }
  }
}
