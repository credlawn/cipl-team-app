import '../core/pb_api.dart';

class ManagerDashboardData {
  final int ipa;
  final int ipd;
  final int totalIp;
  final double ipaPercentage;

  final int newLeads;
  final int workedLeads;
  final int usedLeads;
  final double productivity;
  final int zeroNewLeadsCount;

  final Map<String, int> attendance;
  final Map<String, dynamic> calls;

  final int vkycCount;
  final int bkycCount;
  final int activationCount;
  final int cardsCount;
  final int overdueTraineesCount;

  ManagerDashboardData({
    required this.ipa,
    required this.ipd,
    required this.totalIp,
    required this.ipaPercentage,
    required this.newLeads,
    required this.workedLeads,
    required this.usedLeads,
    required this.productivity,
    required this.zeroNewLeadsCount,
    required this.attendance,
    required this.calls,
    required this.vkycCount,
    required this.bkycCount,
    required this.activationCount,
    required this.cardsCount,
    required this.overdueTraineesCount,
  });

  factory ManagerDashboardData.fromJson(Map<String, dynamic> json) {
    final overview = json['overview'] as Map<String, dynamic>? ?? {};
    final dataUsage = json['data_usage'] as Map<String, dynamic>? ?? {};
    final att = json['attendance'] as Map<String, dynamic>? ?? {};
    final callData = json['calls'] as Map<String, dynamic>? ?? {};
    final tasks = json['tasks'] as Map<String, dynamic>? ?? {};

    return ManagerDashboardData(
      ipa: overview['ipa'] as int? ?? 0,
      ipd: overview['ipd'] as int? ?? 0,
      totalIp: overview['total'] as int? ?? 0,
      ipaPercentage: (overview['ipa_percentage'] as num?)?.toDouble() ?? 0.0,
      newLeads: dataUsage['new_leads'] as int? ?? 0,
      workedLeads: dataUsage['worked'] as int? ?? 0,
      usedLeads: dataUsage['used'] as int? ?? 0,
      productivity: (dataUsage['productivity'] as num?)?.toDouble() ?? 0.0,
      zeroNewLeadsCount: dataUsage['zero_new_leads_count'] as int? ?? 0,
      attendance: {
        'active': att['active'] as int? ?? 0,
        'present': att['present'] as int? ?? 0,
        'absent': att['absent'] as int? ?? 0,
        'late': att['late'] as int? ?? 0,
      },
      calls: {
        'present_count': callData['present_count'] as int? ?? 0,
        'total_calls': callData['total_calls'] as int? ?? 0,
        'total_duration': callData['total_duration'] as int? ?? 0,
        'avg_duration': callData['avg_duration'] as int? ?? 0,
      },
      vkycCount: tasks['vkyc'] as int? ?? 0,
      bkycCount: tasks['bkyc'] as int? ?? 0,
      activationCount: tasks['activation'] as int? ?? 0,
      cardsCount: tasks['cards'] as int? ?? 0,
      overdueTraineesCount: tasks['overdue_trainees'] as int? ?? 0,
    );
  }
}

class ManagerDashboardService {
  ManagerDashboardService._();

  static Future<ManagerDashboardData> getDashboardSummary({String? date}) async {
    final query = <String, dynamic>{};
    if (date != null && date.isNotEmpty) {
      query['date'] = date;
    }

    final res = await PB.pb.send(
      '/api/manager/dashboard-summary',
      query: query,
      method: 'GET',
    );

    if (res is Map<String, dynamic>) {
      return ManagerDashboardData.fromJson(res);
    }
    throw Exception('Invalid manager dashboard summary response');
  }
}
