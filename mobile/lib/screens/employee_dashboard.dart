import 'package:flutter/material.dart';
import '../core/pb_api.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/lead_screen.dart';
import '../screens/lead_details_screen.dart';
import '../screens/call_analytics_screen.dart';
import '../screens/my_login_screen.dart';
import '../screens/hr_dashboard.dart';
import '../screens/manager_dashboard.dart';
import '../services/dashboard_analytics_service.dart';
import '../services/login_case_service.dart';
import '../services/lead_service.dart';
import '../widgets/quick_stat_card.dart';
import '../database/app_database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';

import 'change_password_screen.dart';
import 'task_dashboard_screen.dart';
import '../services/daily_security_service.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> with WidgetsBindingObserver {
  static AppDatabase get _db => LeadService.db;
  
  bool _isLoadingStats = true;
  int _connectedCalls = 0;
  int _ipaCount = 0;
  int _ipdCount = 0;
  double _approvalRate = 0.0;
  double _hourlyEfficiency = 0.0;

  @override
  void initState() {
    super.initState();
    _checkPasswordReset();
    DailySecurityService.checkDailyVerification(context);
    WidgetsBinding.instance.addObserver(this);
    _loadStats();
  }

  void _checkPasswordReset() {
    if (PB.pb.authStore.record?.data['must_change_password'] == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            (route) => false,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadStats();
    }
  }

  Future<void> _loadStats() async {
    try {
      final analytics = await DashboardAnalyticsService.getAnalytics(DateFilter.today);
      final ipaCount = await LoginCaseService.getTodayIpaCount();
      final ipdCount = await LoginCaseService.getTodayIpdCount();
      final approvalRate = await LoginCaseService.getTodayApprovalRate();
      
      setState(() {
        _connectedCalls = analytics.answeredCalls;
        _ipaCount = ipaCount;
        _ipdCount = ipdCount;
        _approvalRate = approvalRate;
        _hourlyEfficiency = analytics.hourlyEfficiency;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() => _isLoadingStats = false);
    }
  }

  Future<void> _handleLogout() async {
    await PB.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    ).then((_) => _loadStats());
  }

  void _openLeads() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LeadScreen()),
    ).then((_) => _loadStats());
  }

  void _openCallAnalytics() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CallAnalyticsScreen()),
    ).then((_) => _loadStats());
  }

  void _openMyLogin(StatusFilterType? statusFilter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MyLoginScreen(initialStatusFilter: statusFilter),
      ),
    ).then((_) => _loadStats());
  }

  @override
  Widget build(BuildContext context) {
    final userName = PB.pb.authStore.record?.data['employee_name'] ?? 'Employee';
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: _openProfile,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
                child: Text(
                  userName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF3B82F6),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: _openProfile,
                child: Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if ((PB.pb.authStore.record?.data['role']?.toString().toLowerCase() ?? '') == 'manager')
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ManagerDashboard()),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  'M',
                  style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickStatsSection(),
              const SizedBox(height: 16),
              _buildMainModulesSection(),
              const SizedBox(height: 16),
              _buildRecentCallsSection(),
              const SizedBox(height: 16),
              _buildUpcomingFollowUpsSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Text(
            'TODAY\'S OVERVIEW',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _isLoadingStats
                ? List.generate(
                    5,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: const QuickStatSkeleton(),
                    ),
                  )
                : [
                    GestureDetector(
                      onTap: _openCallAnalytics,
                      child: QuickStatCard(
                        icon: Icons.phone_in_talk,
                        value: '$_connectedCalls',
                        label: 'Calls',
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _openMyLogin(StatusFilterType.approved),
                      child: QuickStatCard(
                        icon: Icons.celebration_outlined,
                        value: '$_ipaCount',
                        label: 'IPA',
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _openMyLogin(StatusFilterType.declined),
                      child: QuickStatCard(
                        icon: Icons.sentiment_dissatisfied_outlined,
                        value: '$_ipdCount',
                        label: 'IPD',
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(width: 12),
                    QuickStatCard(
                      icon: Icons.check_circle_outline,
                      value: '${_approvalRate.toStringAsFixed(0)}%',
                      label: 'Approval',
                      color: const Color(0xFF3B82F6),
                    ),
                    const SizedBox(width: 12),
                    QuickStatCard(
                      icon: Icons.speed_outlined,
                      value: '${_hourlyEfficiency.toStringAsFixed(1)}',
                      label: 'Per Hour',
                      color: const Color(0xFF8B5CF6),
                    ),
                  ],
          ),
        ),

      ],
    );
  }

  Widget _buildMainModulesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            'MODULES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              GestureDetector(
                onTap: _openLeads,
                child: const QuickStatCard(
                  icon: Icons.people_outline,
                  value: '',
                  label: 'Leads',
                  color: Color(0xFF1976D2),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TaskDashboardScreen()),
                  );
                },
                child: const QuickStatCard(
                  icon: Icons.task_alt_outlined,
                  value: '',
                  label: 'Tasks',
                  color: Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HRDashboard()),
                  );
                },
                child: const QuickStatCard(
                  icon: Icons.badge_outlined,
                  value: '',
                  label: 'HR',
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentCallsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            'RECENT CALLS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
        ),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: (_db.select(_db.callLogs).join([
            leftOuterJoin(
              _db.leads,
              _db.leads.id.equalsExp(_db.callLogs.leadId),
            ),
          ])
            ..where(_db.callLogs.callDuration.isBiggerThanValue(0))
            ..orderBy([OrderingTerm.desc(_db.callLogs.callTimestamp)]))
          .watch().map((rows) {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final Map<String, Map<String, dynamic>> uniqueCalls = {};
            
            for (var row in rows) {
              final call = row.readTable(_db.callLogs);
              final lead = row.readTableOrNull(_db.leads);
              final phoneNumber = call.phoneNumber;
              
              final callDate = DateTime(
                call.callTimestamp.year,
                call.callTimestamp.month,
                call.callTimestamp.day,
              );
              
              if (callDate == today && !uniqueCalls.containsKey(phoneNumber)) {
                uniqueCalls[phoneNumber] = {
                  'call': call,
                  'customerName': lead?.customerName,
                  'leadStatus': lead?.leadStatus,
                };
              }
            }
            
            return uniqueCalls.values.take(3).toList();
          }),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.phone_disabled_outlined,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No calls today',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Start calling your leads!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final items = snapshot.data!;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Column(
                children: items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final call = item['call'] as CallLog;
                  final customerName = item['customerName'] as String?;
                  final leadStatus = item['leadStatus'] as String?;
                  return Column(
                    children: [
                      _buildCallItem(call, customerName, leadStatus),
                      if (index < items.length - 1)
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUpcomingFollowUpsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            'UPCOMING FOLLOW UPS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
        ),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: (_db.select(_db.leads)
                ..where((t) => t.leadStatus.equals('Follow Up') & t.followupTime.isNotNull())
                ..orderBy([(t) => OrderingTerm.asc(t.followupTime)]))
              .watch()
              .asyncMap((leads) async {
            final List<Map<String, dynamic>> result = [];
            
            for (var lead in leads.take(3)) {
              final lastCall = await (_db.select(_db.callLogs)
                    ..where((t) => t.leadId.equals(lead.id) & t.callDuration.isBiggerThanValue(0))
                    ..orderBy([(t) => OrderingTerm.desc(t.callTimestamp)])
                    ..limit(1))
                  .getSingleOrNull();
              
              result.add({
                'lead': lead,
                'lastCall': lastCall,
              });
            }
            
            return result;
          }),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_available_outlined,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No upcoming follow-ups',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'All caught up!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final followUps = snapshot.data!;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Column(
                children: followUps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final lead = item['lead'] as Lead;
                  final lastCall = item['lastCall'] as CallLog?;
                  return Column(
                    children: [
                      _buildFollowUpItem(lead, lastCall),
                      if (index < followUps.length - 1)
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFollowUpItem(Lead lead, CallLog? lastCall) {
    final followUpTime = lead.followupTime;
    if (followUpTime == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final isOverdue = followUpTime.isBefore(now);
    final isToday = followUpTime.year == now.year &&
        followUpTime.month == now.month &&
        followUpTime.day == now.day;

    Color iconColor;
    IconData icon;
    if (isOverdue) {
      iconColor = const Color(0xFFEF4444);
      icon = Icons.warning_outlined;
    } else if (isToday) {
      iconColor = const Color(0xFFFF9800);
      icon = Icons.schedule;
    } else {
      iconColor = const Color(0xFF00BCD4);
      icon = Icons.event_outlined;
    }

    String? callTimeText;
    String? callDurationText;
    if (lastCall != null) {
      callTimeText = _formatCallTime(lastCall.callTimestamp);
      final duration = Duration(seconds: lastCall.callDuration);
      callDurationText = duration.inMinutes > 0
          ? '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s'
          : '${lastCall.callDuration}s';
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LeadDetailsScreen(
              leadIds: [lead.id],
              initialIndex: 0,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lead.customerName,
                          style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isOverdue ? const Color(0xFFEF4444) : const Color(0xFF111827),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatFollowUpDate(followUpTime),
                      style: TextStyle(
                        fontSize: 11,
                        color: isOverdue ? const Color(0xFFEF4444) : const Color(0xFF9CA3AF),
                        fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        callTimeText != null && callDurationText != null
                            ? '$callTimeText  $callDurationText'
                            : 'No calls yet',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('h:mm a').format(followUpTime),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  String _formatFollowUpDate(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final checkDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (checkDate == today) {
      return 'Today';
    } else if (checkDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return DateFormat('dd MMM').format(timestamp);
    }
  }

  Widget _buildCallItem(CallLog call, String? customerName, String? leadStatus) {
    final duration = Duration(seconds: call.callDuration);
    final durationText = duration.inMinutes > 0
        ? '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s'
        : '${call.callDuration}s';

    Color iconColor;
    IconData icon;
    if (call.callType == 'missed') {
      iconColor = const Color(0xFFEF4444);
      icon = Icons.call_missed;
    } else if (call.callType == 'rejected') {
      iconColor = const Color(0xFFF59E0B);
      icon = Icons.call_end;
    } else if (call.callType == 'incoming') {
      iconColor = const Color(0xFF10B981);
      icon = Icons.call_received;
    } else {
      iconColor = const Color(0xFF3B82F6);
      icon = Icons.call_made;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        customerName ?? call.phoneNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      durationText,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _formatCallTime(call.callTimestamp),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    if (leadStatus != null)
                      Text(
                        leadStatus,
                        style: TextStyle(
                          fontSize: 11,
                          color: _getStatusColor(leadStatus),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return const Color(0xFF1976D2);
      case 'called':
        return const Color(0xFFFF9800);
      case 'hold':
        return const Color(0xFF9C27B0);
      case 'ip approved':
        return const Color(0xFF4CAF50);
      case 'ip decline':
        return const Color(0xFFF44336);
      case 'no docs':
      case 'not eligible':
        return const Color(0xFF795548);
      case 'denied':
        return const Color(0xFFFF9800);
      case 'already carded':
      case 'recently applied':
        return const Color(0xFF607D8B);
      case 'follow up':
        return const Color(0xFF00BCD4);
      case 'cnr':
      case 'voicemail':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _formatCallTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final callDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final timeStr = DateFormat('h:mm a').format(timestamp);

    if (callDate == today) {
      return timeStr;
    } else if (callDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday $timeStr';
    } else {
      return '${DateFormat('dd MMM').format(timestamp)} $timeStr';
    }
  }
}
