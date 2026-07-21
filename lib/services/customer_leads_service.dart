import '../core/pb_api.dart';

class CustomerLeadsService {
  static Future<Map<String, dynamic>> getCustomerLeads({
    int page = 1,
    int perPage = 20,
    String? status,
    String? employeeCode,
    bool excludeNegative = false,
    String? search,
  }) async {
    try {
      List<String> filters = [];
      
      filters.add('lead_status != "New" && lead_status != "Called"');
      
      if (excludeNegative) {
        filters.add('lead_status != "CNR" && lead_status != "Voicemail" && lead_status != "Denied"');
      }
      if (status != null && status != 'All') {
        filters.add('lead_status = "$status"');
      }
      if (employeeCode != null && employeeCode != 'All') {
        filters.add('employee_code = "$employeeCode"');
      }
      if (search != null && search.trim().isNotEmpty) {
        filters.add('(customer_name ~ "$search" || mobile_no ~ "$search")');
      }

      final filter = filters.join(' && ');

      final response = await PB.pb.collection('leads').getList(
        page: page,
        perPage: perPage,
        sort: '-lead_status_date',
        filter: filter,
        expand: 'employee_code',
      );

      return {
        'items': response.items.map((e) {
          final data = Map<String, dynamic>.from(e.data);
          data['id'] = e.id;
          data['expand'] = e.expand;
          return data;
        }).toList(),
        'totalItems': response.totalItems,
        'totalPages': response.totalPages,
      };
    } catch (e) {
      rethrow;
    }
  }

  static void subscribeToLeads(void Function(dynamic) onEvent) {
    PB.pb.collection('leads').subscribe('*', onEvent);
  }

  static void unsubscribeFromLeads() {
    PB.pb.collection('leads').unsubscribe('*');
  }
}
