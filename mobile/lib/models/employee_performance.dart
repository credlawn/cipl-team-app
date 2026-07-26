class EmployeePerformance {
  final String employeeCode;
  final String employeeName;
  final bool wfh;
  final String productivity;
  final int newLeadsCount;
  final int totalLeads;
  final int workedLeads;
  final int ipa;
  final int ipd;
  final bool disabled;
  final String role;


  EmployeePerformance({
    required this.employeeCode,
    required this.employeeName,
    required this.wfh,
    required this.productivity,
    required this.newLeadsCount,
    required this.totalLeads,
    required this.workedLeads,
    required this.ipa,
    required this.ipd,
    this.disabled = false,
    this.role = '',
  });


  int get totalIp => ipa + ipd;
  
  double get ipaPercentage => totalIp > 0 ? (ipa / totalIp) * 100 : 0;

  factory EmployeePerformance.fromLeadsJson(Map<String, dynamic> json) {
    return EmployeePerformance(
      employeeCode: json['employee_code'] ?? '',
      employeeName: json['employee_name'] ?? '',
      wfh: json['wfh'] ?? false,
      productivity: json['productivity'] ?? '0.0',
      newLeadsCount: json['new'] ?? 0,
      totalLeads: json['total'] ?? 0,
      workedLeads: json['worked'] ?? 0,
      ipa: json['ip_approved'] ?? 0,
      ipd: json['ip_decline'] ?? 0,
      disabled: json['disabled'] ?? false,
      role: json['role'] ?? '',
    );

  }

  EmployeePerformance copyWith({
    String? employeeCode,
    String? employeeName,
    bool? wfh,
    String? productivity,
    int? newLeadsCount,
    int? totalLeads,
    int? workedLeads,
    int? ipa,
    int? ipd,
    bool? disabled,
    String? role,
  }) {

    return EmployeePerformance(
      employeeCode: employeeCode ?? this.employeeCode,
      employeeName: employeeName ?? this.employeeName,
      wfh: wfh ?? this.wfh,
      productivity: productivity ?? this.productivity,
      newLeadsCount: newLeadsCount ?? this.newLeadsCount,
      totalLeads: totalLeads ?? this.totalLeads,
      workedLeads: workedLeads ?? this.workedLeads,
      ipa: ipa ?? this.ipa,
      ipd: ipd ?? this.ipd,
      disabled: disabled ?? this.disabled,
      role: role ?? this.role,
    );

  }
}
