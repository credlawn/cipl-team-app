class DashboardSummary {
  final int total;
  final int newLeads;
  final int used;
  final int worked;
  final int todayCnr;
  final int todayDenied;
  final int todayCalled;
  final int todayVoicemail;
  final double productivity;

  DashboardSummary({
    required this.total,
    required this.newLeads,
    required this.used,
    required this.worked,
    required this.todayCnr,
    required this.todayDenied,
    required this.todayCalled,
    required this.todayVoicemail,
    required this.productivity,
  });

  int get todayTotal => todayCnr + todayDenied;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      total: json['total'] ?? 0,
      newLeads: json['new'] ?? 0,
      used: json['used'] ?? 0,
      worked: json['worked'] ?? 0,
      todayCnr: json['today_cnr'] ?? 0,
      todayDenied: json['today_denied'] ?? 0,
      todayCalled: json['today_called'] ?? 0,
      todayVoicemail: json['today_voicemail'] ?? 0,
      productivity: (json['productivity'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
