class AttendanceSummary {
  final int active;
  final int present;
  final int absent;
  final int late;

  AttendanceSummary({
    required this.active,
    required this.present,
    required this.absent,
    required this.late,
  });

  factory AttendanceSummary.empty() {
    return AttendanceSummary(
      active: 0,
      present: 0,
      absent: 0,
      late: 0,
    );
  }
}
