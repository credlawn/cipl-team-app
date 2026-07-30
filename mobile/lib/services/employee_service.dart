import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../core/pb_api.dart';

class EmployeeService {
  /// Fetch Office employees (active, wfh = false)
  static Future<List<Map<String, dynamic>>> getOfficeEmployees() async {
    try {
      final records = await PB.pb.collection('users').getFullList(
        filter: 'disabled = false && wfh = false && no_atn = false && designation != "Trainee"',
        sort: '-employee_code',
      );
      return records.map((r) => r.toJson()).toList();
    } catch (e) {
      throw Exception('Failed to fetch office employees: $e');
    }
  }

  /// Fetch WFH employees (active, wfh = true)
  static Future<List<Map<String, dynamic>>> getWFHEmployees() async {
    try {
      final records = await PB.pb.collection('users').getFullList(
        filter: 'disabled = false && wfh = true && no_atn = false && designation != "Trainee"',
        sort: '-employee_code',
      );
      return records.map((r) => r.toJson()).toList();
    } catch (e) {
      throw Exception('Failed to fetch WFH employees: $e');
    }
  }
  
  /// Fetch Trainee employees (active, designation = Trainee)
  static Future<List<Map<String, dynamic>>> getTraineeEmployees() async {
    try {
      final records = await PB.pb.collection('users').getFullList(
        filter: 'disabled = false && designation = "Trainee" && no_atn = false',
        sort: '-employee_code',
      );
      return records.map((r) => r.toJson()).toList();
    } catch (e) {
      throw Exception('Failed to fetch Trainee employees: $e');
    }
  }

  /// Count trainees who have completed 5 days of training and need action
  static Future<int> getOverdueTraineesCount() async {
    try {
      final now = DateTime.now();
      final fourDaysAgo = now.subtract(const Duration(days: 4));
      // PocketBase filter format for date
      final dateLimitStr = "${fourDaysAgo.year}-${fourDaysAgo.month.toString().padLeft(2, '0')}-${fourDaysAgo.day.toString().padLeft(2, '0')} 23:59:59";

      final records = await PB.pb.collection('users').getFullList(
        filter: 'disabled = false && designation = "Trainee" && no_atn = false && date_of_joining <= "$dateLimitStr"',
      );
      return records.length;
    } catch (_) {
      return 0;
    }
  }

  /// Fetch Pending employees (disabled = true, last_working_date not set)
  static Future<List<Map<String, dynamic>>> getPendingEmployees() async {
    try {
      final records = await PB.pb.collection('users').getFullList(
        filter: 'disabled = true && last_working_date = "" && no_atn = false',
        sort: '-employee_code',
      );
      return records.map((r) => r.toJson()).toList();
    } catch (e) {
      throw Exception('Failed to fetch pending employees: $e');
    }
  }

  /// Fetch Disabled employees (disabled = true, last_working_date is set within last 31 days)
  static Future<List<Map<String, dynamic>>> getDisabledEmployees() async {
    try {
      final now = DateTime.now();
      final thirtyOneDaysAgo = now.subtract(const Duration(days: 31));
      final dateLimitStr = thirtyOneDaysAgo.toUtc().toIso8601String();

      final records = await PB.pb.collection('users').getFullList(
        filter: 'disabled = true && last_working_date != "" && last_working_date >= "$dateLimitStr" && no_atn = false',
        sort: '-last_working_date',
      );
      return records.map((r) => r.toJson()).toList();
    } catch (e) {
      throw Exception('Failed to fetch disabled employees: $e');
    }
  }

  /// Generate the next trainee code (T26XXX)
  static Future<String> getNextTraineeCode() async {
    try {
      // Fetch the last record starting with 'T26' in trainee_code
      // We use getList with limit 1 and sort to get the latest numeric code
      final result = await PB.pb.collection('users').getList(
        page: 1,
        perPage: 1,
        filter: 'trainee_code ~ "T26%"',
        sort: '-trainee_code',
      );

      if (result.items.isEmpty) return 'T26001';

      final lastCode = result.items.first.data['trainee_code']?.toString() ?? '';
      if (lastCode.length < 6) return 'T26001';

      // Extract numeric part (e.g., '001' from 'T26001')
      final numStr = lastCode.substring(3);
      final num = int.tryParse(numStr);
      if (num == null) return 'T26001';

      // Increment and format to 3 digits
      final nextNum = (num + 1).toString().padLeft(3, '0');
      return 'T26$nextNum';
    } catch (_) {
      // If no records found (404), start with T26001
      return 'T26001';
    }
  }

  /// Generate the next numeric employee code (21XXXX)
  static Future<String> getNextEmployeeCode() async {
    try {
      // Fetch the last record starting with '21' (excluding Trainees)
      final result = await PB.pb.collection('users').getList(
        page: 1,
        perPage: 1,
        filter: 'employee_code ~ "21%" && designation != "Trainee"',
        sort: '-employee_code',
      );

      if (result.items.isEmpty) return '210001';

      final lastCode = result.items.first.data['employee_code']?.toString() ?? '';
      if (lastCode.length < 6) return '210001';

      final numStr = lastCode.substring(2); // After '21'
      final num = int.tryParse(numStr);
      if (num == null) return '210001';

      final nextNum = (num + 1).toString().padLeft(4, '0');
      return '21$nextNum';
    } catch (_) {
      return '210001';
    }
  }

  /// Confirm a trainee as a full-time employee
  static Future<void> confirmTrainee({
    required String userId,
    required String employeeCode,
    required String payrollStartDate,
    required String salary,
  }) async {
    try {
      await PB.pb.collection('users').update(userId, body: {
        'employee_code': employeeCode,
        'designation': 'Relationship Executive',
        'payroll_start_date': DateTime.utc(
          DateTime.parse(payrollStartDate).year,
          DateTime.parse(payrollStartDate).month,
          DateTime.parse(payrollStartDate).day,
          12, 0, 0
        ).toIso8601String(),
        'salary': salary,
        'role': 'Employee',
        'is_trainee': false, // Assuming there's a flag, but designation change is key
      });
    } catch (e) {
      throw Exception('Failed to confirm trainee: $e');
    }
  }


  /// Reject a trainee and disable account
  static Future<void> rejectTrainee({
    required String userId,
    required String lastWorkingDate,
  }) async {
    try {
      await PB.pb.collection('users').update(userId, body: {
        'disabled': true,
        'last_working_date': DateTime.utc(
          DateTime.parse(lastWorkingDate).year,
          DateTime.parse(lastWorkingDate).month,
          DateTime.parse(lastWorkingDate).day,
          12, 0, 0
        ).toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to reject trainee: $e');
    }
  }

  /// Check if mobile number already exists
  static Future<bool> isMobileExists(String mobileNo) async {
    try {
      final records = await PB.pb.collection('users').getList(
        page: 1,
        perPage: 1,
        filter: 'mobile_no = "$mobileNo"',
      );
      return records.items.isNotEmpty;
    } catch (e) {
      // In case of error, we can't be sure, but returning true is safer 
      // or we can rethrow. Let's return false and handle during create.
      return false;
    }
  }

  /// Check if email already exists
  static Future<bool> isEmailExists(String email) async {
    try {
      final records = await PB.pb.collection('users').getList(
        page: 1,
        perPage: 1,
        filter: 'email = "$email"',
      );
      return records.items.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Add new employee (manager creates, BH approves later)
  static Future<Map<String, dynamic>> addEmployee({
    required String employeeName,
    required String mobileNo,
    String? email,
    DateTime? dateOfBirth,
    DateTime? dateOfJoining,
    bool wfh = false,
    List<XFile>? aadharFiles,
  }) async {
    try {
      // Prepare data
      final data = {
        'username': mobileNo,
        'email': email ?? '',
        'emailVisibility': false,
        'verified': false,
        'name': employeeName,
        'employee_name': employeeName,
        'mobile_no': mobileNo,
        'password': 'Cred@2026',
        'passwordConfirm': 'Cred@2026',
        'must_change_password': true,
        'role': 'Employee',
        'designation': 'Trainee',
        'department': 'Sales',
        'vertical': 'Credit Card',
        'disabled': true,
        'wfh': wfh,
        'date_of_joining': DateTime.utc(
          (dateOfJoining ?? DateTime.now()).year,
          (dateOfJoining ?? DateTime.now()).month,
          (dateOfJoining ?? DateTime.now()).day,
          12, 0, 0
        ).toIso8601String(),
        'office_start_time': '10:15 AM',
        'office_end_time': '06:30 PM',
        'paid_leave_balance': 0,
      };

      if (dateOfBirth != null) {
        data['date_of_birth'] = DateTime.utc(
          dateOfBirth.year,
          dateOfBirth.month,
          dateOfBirth.day,
          12, 0, 0
        ).toIso8601String();
      }

      // Convert XFiles to MultipartFiles for PocketBase upload
      final List<http.MultipartFile> files = [];
      if (aadharFiles != null && aadharFiles.isNotEmpty) {
        for (var file in aadharFiles) {
          final multipartFile = await http.MultipartFile.fromPath(
            'aadhar_card', // Field name in PocketBase
            file.path,
          );
          files.add(multipartFile);
        }
      }

      final record = await PB.pb.collection('users').create(
        body: data,
        files: files,
      );
      return record.toJson();
    } catch (e) {
      throw Exception('Failed to add employee: $e');
    }
  }

  /// Update employee
  static Future<Map<String, dynamic>> updateEmployee({
    required String id,
    String? employeeName,
    String? mobileNo,
    String? email,
    DateTime? dateOfBirth,
    bool? wfh,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (employeeName != null) data['employee_name'] = employeeName;
      if (mobileNo != null) {
        data['mobile_no'] = mobileNo;
        data['username'] = mobileNo;
      }
      if (email != null) data['email'] = email;
      if (wfh != null) data['wfh'] = wfh;
      if (dateOfBirth != null) {
        data['date_of_birth'] = DateTime.utc(
          dateOfBirth.year,
          dateOfBirth.month,
          dateOfBirth.day,
          12, 0, 0
        ).toIso8601String();
      }

      final record = await PB.pb.collection('users').update(id, body: data);
      return record.toJson();
    } catch (e) {
      throw Exception('Failed to update employee: $e');
    }
  }
}
