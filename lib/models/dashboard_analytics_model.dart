class DashboardAnalytics {
  final int ipaCount;
  final int ipdCount;
  final int loginCount;
  final double approvalRate;
  final String approvalTrend;
  
  final int totalCalls;
  final int answeredCalls;
  final int cnrCalls;
  final double answerRate;
  final Duration totalTalkTime;
  final Duration avgCallDuration;
  final double hourlyEfficiency;
  final DateTime? lastCallTime;
  
  final Map<String, int> callsByDay;
  final Map<String, int> durationByDay;

  DashboardAnalytics({
    required this.ipaCount,
    required this.ipdCount,
    required this.loginCount,
    required this.approvalRate,
    required this.approvalTrend,
    required this.totalCalls,
    required this.answeredCalls,
    required this.cnrCalls,
    required this.answerRate,
    required this.totalTalkTime,
    required this.avgCallDuration,
    required this.hourlyEfficiency,
    required this.lastCallTime,
    required this.callsByDay,
    required this.durationByDay,
  });

  static DashboardAnalytics empty() {
    return DashboardAnalytics(
      ipaCount: 0,
      ipdCount: 0,
      loginCount: 0,
      approvalRate: 0.0,
      approvalTrend: 'neutral',
      totalCalls: 0,
      answeredCalls: 0,
      cnrCalls: 0,
      answerRate: 0.0,
      totalTalkTime: Duration.zero,
      avgCallDuration: Duration.zero,
      hourlyEfficiency: 0.0,
      lastCallTime: null,
      callsByDay: {},
      durationByDay: {},
    );
  }
}
