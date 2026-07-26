class AttendanceRecord {
  final String employeeCode;
  final String employeeName;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String? checkInSelfie;
  final String? checkOutSelfie;
  final bool isPresent;
  final bool isLate;

  AttendanceRecord({
    required this.employeeCode,
    required this.employeeName,
    this.checkInTime,
    this.checkOutTime,
    this.checkInSelfie,
    this.checkOutSelfie,
    required this.isPresent,
    required this.isLate,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json, {bool hasAttendance = false}) {
    DateTime? checkIn;
    DateTime? checkOut;
    
    if (hasAttendance && json['check_in_time'] != null) {
      // Convert UTC to IST
      checkIn = DateTime.parse(json['check_in_time']).add(const Duration(hours: 5, minutes: 30));
    }
    
    if (hasAttendance && json['check_out_time'] != null) {
      checkOut = DateTime.parse(json['check_out_time']).add(const Duration(hours: 5, minutes: 30));
    }
    
    // Check if late (after 10:15 AM IST)
    bool isLate = false;
    if (checkIn != null) {
      final cutoffTime = DateTime(checkIn.year, checkIn.month, checkIn.day, 10, 15);
      isLate = checkIn.isAfter(cutoffTime);
    }

    return AttendanceRecord(
      employeeCode: json['employee_code'] ?? '',
      employeeName: json['employee_name'] ?? '',
      checkInTime: checkIn,
      checkOutTime: checkOut,
      checkInSelfie: json['check_in_selfie'],
      checkOutSelfie: json['check_out_selfie'],
      isPresent: hasAttendance,
      isLate: isLate,
    );
  }

  // Create unmarked attendance record
  factory AttendanceRecord.unmarked({
    required String employeeCode,
    required String employeeName,
  }) {
    return AttendanceRecord(
      employeeCode: employeeCode,
      employeeName: employeeName,
      isPresent: false,
      isLate: false,
    );
  }
}
