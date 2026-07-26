import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/pb_api.dart';

class DatabaseService {
  /// Get unique filter values for data_code, data_sub_code, custom_code
  static Future<Map<String, List<String>>> getFilterValues() async {
    try {
      final response = await PB.pb.send('/api/database-filter-values');
      
      return {
        'data_codes': List<String>.from(response['data_codes'] ?? []),
        'data_sub_codes': List<String>.from(response['data_sub_codes'] ?? []),
        'custom_codes': List<String>.from(response['custom_codes'] ?? []),
        'decline_reasons': List<String>.from(response['decline_reasons'] ?? []),
      };
    } catch (e) {
      print('Error fetching filter values: $e');
      return {
        'data_codes': [],
        'data_sub_codes': [],
        'custom_codes': [],
        'decline_reasons': [],
      };
    }
  }

  /// Get count breakdown by custom_code
  static Future<Map<String, dynamic>> getCountByCustomCode({
    required String dataStatus, // "new" or "used"
    List<String>? dataCodes,
    List<String>? dataSubCodes,
    List<String>? customCodes,
    List<String>? leadStatuses,
    List<String>? declineReasons, // NEW: For decline reason filtering
    int? minAllocCount,
    int? maxAllocCount,
    int? minEmpCount,
    int? maxEmpCount,
  }) async {
    try {
      final url = Uri.parse('${PB.pb.baseUrl}/api/database-count-by-custom-code');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': PB.pb.authStore.token,
        },
        body: json.encode({
          'data_status': dataStatus,
          'data_codes': dataCodes ?? [],
          'data_sub_codes': dataSubCodes ?? [],
          'custom_codes': customCodes ?? [],
          'lead_statuses': leadStatuses ?? [],
          'decline_reasons': declineReasons ?? [], // NEW
          'min_alloc_count': minAllocCount ?? 0,
          'max_alloc_count': maxAllocCount ?? 0,
          'min_emp_count': minEmpCount ?? 0,
          'max_emp_count': maxEmpCount ?? 0,
        }),
      );

      final data = json.decode(response.body);
      return {
        'breakdown': List<Map<String, dynamic>>.from(data['breakdown'] ?? []),
        'total_count': data['total_count'] ?? 0,
      };
    } catch (e) {
      print('Error fetching count breakdown: $e');
      return {
        'breakdown': [],
        'total_count': 0,
      };
    }
  }

  /// Allocate leads (new data) - Mobile endpoint
  static Future<Map<String, dynamic>> allocateLeads({
    required List<Map<String, dynamic>> selections,
    required List<Map<String, dynamic>> allocations,
  }) async {
    try {
      final authRecord = PB.pb.authStore.record;
      
      final url = Uri.parse('${PB.pb.baseUrl}/api/mobile/allocate-leads');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': PB.pb.authStore.token,
        },
        body: json.encode({
          'selections': selections,
          'allocations': allocations,
          'allocated_by_code': authRecord?.data['employee_code'] ?? '',
          'allocated_by_name': authRecord?.data['employee_name'] ?? '',
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      print('Error allocating leads: $e');
      rethrow;
    }
  }

  /// Check reallocation availability - Get max available per employee
  static Future<Map<String, dynamic>> getReallocationAvailability({
    required List<Map<String, dynamic>> selections,
  }) async {
    try {
      final url = Uri.parse('${PB.pb.baseUrl}/api/mobile/reallocate-available');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': PB.pb.authStore.token,
        },
        body: json.encode({
          'selections': selections,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      print('Error checking reallocation availability: $e');
      rethrow;
    }
  }

  /// Reallocate leads (used data) - Mobile endpoint
  static Future<Map<String, dynamic>> reallocateLeads({
    required List<Map<String, dynamic>> selections,
    required List<Map<String, dynamic>> allocations,
  }) async {
    try {
      final authRecord = PB.pb.authStore.record;
      
      final url = Uri.parse('${PB.pb.baseUrl}/api/mobile/reallocate-leads');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': PB.pb.authStore.token,
        },
        body: json.encode({
          'selections': selections,
          'allocations': allocations,
          'allocated_by_code': authRecord?.data['employee_code'] ?? '',
          'allocated_by_name': authRecord?.data['employee_name'] ?? '',
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      print('Error reallocating leads: $e');
      rethrow;
    }
  }
}
