import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import '../database/app_database.dart' as db;

class LoginCase {
  final String id;
  final String customerName;
  final String mobileNumber;
  final String leadStatus;
  final String employeeName;
  final String employeeCode;
  final DateTime leadStatusDate;
  final DateTime? arnDate;
  final String? arnNo;
  final String? leadId;

  LoginCase({
    required this.id,
    required this.customerName,
    required this.mobileNumber,
    required this.leadStatus,
    required this.employeeName,
    required this.employeeCode,
    required this.leadStatusDate,
    this.arnDate,
    this.arnNo,
    this.leadId,
  });

  bool get isApproved => leadStatus == 'IP Approved';

  factory LoginCase.fromJson(Map<String, dynamic> json) {
    return LoginCase(
      id: json['id'] ?? '',
      customerName: json['customer_name'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      leadStatus: json['lead_status'] ?? '',
      employeeName: json['employee_name'] ?? '',
      employeeCode: json['employee_code'] ?? '',
      leadStatusDate: DateTime.parse(json['lead_status_date']),
      arnDate: json['arn_date'] != null ? DateTime.parse(json['arn_date']) : null,
      arnNo: json['arn_no'],
      leadId: json['lead_id'],
    );
  }

  factory LoginCase.fromDrift(db.LoginCase driftRecord) {
    return LoginCase(
      id: driftRecord.id,
      customerName: driftRecord.customerName,
      mobileNumber: driftRecord.mobileNumber,
      leadStatus: driftRecord.leadStatus,
      employeeName: driftRecord.employeeName,
      employeeCode: driftRecord.employeeCode,
      leadStatusDate: driftRecord.leadStatusDate,
      arnDate: driftRecord.arnDate,
      arnNo: driftRecord.arnNo,
      leadId: driftRecord.leadId,
    );
  }

  db.LoginCasesCompanion toDrift() {
    return db.LoginCasesCompanion(
      id: drift.Value(id),
      customerName: drift.Value(customerName),
      mobileNumber: drift.Value(mobileNumber),
      leadStatus: drift.Value(leadStatus),
      employeeName: drift.Value(employeeName),
      employeeCode: drift.Value(employeeCode),
      leadStatusDate: drift.Value(leadStatusDate),
      arnDate: drift.Value(arnDate),
      arnNo: drift.Value(arnNo),
      leadId: drift.Value(leadId),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'mobile_number': mobileNumber,
      'lead_status': leadStatus,
      'employee_name': employeeName,
      'employee_code': employeeCode,
      'lead_status_date': leadStatusDate.toIso8601String(),
      'arn_date': arnDate?.toIso8601String(),
      'arn_no': arnNo,
      'lead_id': leadId,
    };
  }
}
