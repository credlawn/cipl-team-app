import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../core/pb_api.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/employee_dashboard.dart';
import '../screens/manager_tasks_screen.dart';
import '../screens/manager_hr_screen.dart';
import '../screens/employee_list_screen.dart';
import '../services/manager_dashboard_service.dart';
import '../services/attendance_service.dart';
import '../services/manager_call_log_service.dart';
import '../services/leads_analytics_service.dart';
import '../services/employee_service.dart';
import 'allocate_leads_setting_screen.dart';
import '../models/dashboard_summary.dart';
import '../models/employee_performance.dart';
import '../widgets/manager/overview_card.dart';
import '../widgets/manager/data_usage_card.dart';
import '../widgets/manager/attendance_card.dart';
import '../widgets/call_logs_card.dart';
import '../widgets/quick_stat_card.dart';
import '../services/manager_task_service.dart';
import 'manager_activation_summary_screen.dart';
import 'manager_bkyc_summary_screen.dart';
import 'manager_vkyc_summary_screen.dart';

import 'change_password_screen.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> with WidgetsBindingObserver {
  bool _isManagerView = true;
  bool _isLoading = true;
  bool _isFirstLoad = true; // Track first load for skeleton
  bool _isRefreshing = false; // Track background refresh
  int _zeroNewLeadsCount = 0; // Count of employees with 0 new leads
  int _overdueCount = 0; // Count of trainees needing review (BH only)
  DashboardSummary? _summary;
  List<EmployeePerformance> _employees = [];
  Map<String, int>? _attendanceSummary;
  Map<String, dynamic>? _callLogsSummary;
  int _vkycCount = 0;
  int _bkycCount = 0;
  int _activationCount = 0;
  
  final ScrollController _marqueeController = ScrollController();
  Timer? _marqueeTimer;

  @override
  void initState() {
    super.initState();
    _checkPasswordReset();
    WidgetsBinding.instance.addObserver(this);
    _loadDashboardData();
  }

  void _startMarquee() {
    _marqueeTimer?.cancel();
    if (_overdueCount == 0) return;
    
    _marqueeTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_marqueeController.hasClients) {
        double maxScroll = _marqueeController.position.maxScrollExtent;
        double currentScroll = _marqueeController.offset;
        
        if (currentScroll >= maxScroll) {
          _marqueeController.jumpTo(0);
        } else {
          _marqueeController.animateTo(
            currentScroll + 1.0,
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      }
    });
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
    if (state == AppLifecycleState.resumed && _isManagerView) {
      _loadDashboardData();
      _startMarquee();
    } else if (state == AppLifecycleState.paused) {
      _marqueeTimer?.cancel();
    }
  }

  Future<void> _loadDashboardData() async {
    // Show skeleton only on first load, otherwise show cached data
    if (_isFirstLoad) {
      setState(() => _isLoading = true);
    } else {
      setState(() => _isRefreshing = true);
    }
    
    try {
      final now = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(now);

      // Get complete analytics data (summary + employees) from API
      final analyticsData = await LeadsAnalyticsService.getAnalyticsData(
        filterType: 'today',
        date: todayStr,
      );
      
      // Extract pre-calculated summary from API
      final summaryData = analyticsData['summary'] as Map<String, dynamic>;
      
      final summary = DashboardSummary(
        total: (summaryData['new_leads'] as int? ?? 0) + (summaryData['total_activity'] as int? ?? 0),
        newLeads: summaryData['new_leads'] as int? ?? 0,
        used: summaryData['total_activity'] as int? ?? 0, // Used = total_activity
        worked: summaryData['worked'] as int? ?? 0, // Worked = productive
        todayCnr: (summaryData['breakdown']?['unproductive']?['cnr'] as int?) ?? 0,
        todayDenied: (summaryData['breakdown']?['unproductive']?['denied'] as int?) ?? 0,
        todayCalled: (summaryData['breakdown']?['unproductive']?['called'] as int?) ?? 0,
        todayVoicemail: 0,
        productivity: double.tryParse(summaryData['productivity']?.toString() ?? '0') ?? 0.0,
      );
      
      // Convert employees data to EmployeePerformance format
      final employeesData = analyticsData['employees'] as List<dynamic>;
      
      // Fetch IPA/IPD data from employee_stats API (case_login collection) with date filter
      final statsResponse = await PB.pb.send('/api/employee/stats', query: {
        'filter': "date(lead_status_date)='$todayStr'",
      });
      final statsData = List<Map<String, dynamic>>.from(statsResponse as List);
      
      // Create a map for quick lookup
      final statsMap = <String, Map<String, int>>{};
      for (var stat in statsData) {
        statsMap[stat['employee_code']] = {
          'ipa': stat['ipa'] ?? 0,
          'ipd': stat['ipd'] ?? 0,
        };
      }
      
      final employees = employeesData.map((e) {
        final employeeCode = e['employee_code'] as String? ?? '';
        final stats = statsMap[employeeCode] ?? {'ipa': 0, 'ipd': 0};
        
        return EmployeePerformance(
          employeeCode: employeeCode,
          employeeName: e['employee_name'] as String? ?? '',
          wfh: e['wfh'] as bool? ?? false,
          productivity: e['productivity'] as String? ?? '0.0',
          newLeadsCount: e['new'] as int? ?? 0,
          totalLeads: e['total'] as int? ?? 0,
          workedLeads: e['worked'] as int? ?? 0,
          ipa: stats['ipa']!,
          ipd: stats['ipd']!,
          role: e['role'] as String? ?? '',
        );
      }).toList();

      
      // Run all independent calls in parallel for maximum speed
      final isBH = PB.pb.authStore.record?.data['bh_access'] == true;
      final parallelResults = await Future.wait([
        AttendanceService.getManagerAttendanceSummary(),            // [0]
        ManagerCallLogService.getCallLogsSummary(),                 // [1]
        LeadsAnalyticsService.getEmployeesWithZeroNewLeads(),       // [2]
        if (isBH) EmployeeService.getOverdueTraineesCount()        // [3] BH only
            else Future.value(0),
        ManagerTaskService.getTaskCounts(),                         // [4]
      ]);

      final attendance    = parallelResults[0] as Map<String, int>?;
      final callLogs      = parallelResults[1] as Map<String, dynamic>?;
      final zeroLeadsCount = parallelResults[2] as int;
      final overdueCount  = parallelResults[3] as int;
      final taskCounts    = parallelResults[4] as Map<String, int>;
      
      if (mounted) {
        setState(() {
          _summary = summary;
          _employees = employees;
          _attendanceSummary = attendance;
          _callLogsSummary = callLogs;
          _zeroNewLeadsCount = zeroLeadsCount;
          _overdueCount = overdueCount;
          _vkycCount = taskCounts['vkyc'] ?? 0;
          _bkycCount = taskCounts['bkyc'] ?? 0;
          _activationCount = taskCounts['activation'] ?? 0;
          _isLoading = false;
          _isFirstLoad = false;
          _isRefreshing = false;
        });
        
        // Start or restart marquee if count > 0
        if (_overdueCount > 0) {
          Future.delayed(const Duration(seconds: 1), () => _startMarquee());
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
        
        // Determine error message based on error type
        String errorMessage;
        IconData errorIcon;
        Color errorColor;
        
        final errorString = e.toString().toLowerCase();
        
        if (errorString.contains('failed host lookup') || 
            errorString.contains('network') || 
            errorString.contains('socket')) {
          errorMessage = 'No internet connection. Please check your network.';
          errorIcon = Icons.wifi_off;
          errorColor = const Color(0xFFEF4444);
        } else if (errorString.contains('timeout')) {
          errorMessage = 'Request timed out. Please try again.';
          errorIcon = Icons.access_time;
          errorColor = const Color(0xFFFF9800);
        } else if (errorString.contains('unauthorized') || errorString.contains('401')) {
          errorMessage = 'Session expired. Please login again.';
          errorIcon = Icons.lock_outline;
          errorColor = const Color(0xFFEF4444);
        } else {
          errorMessage = 'Failed to load dashboard. Please try again.';
          errorIcon = Icons.error_outline;
          errorColor = const Color(0xFFEF4444);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(errorIcon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadDashboardData,
            ),
          ),
        );
      }
    }
  }

  void _switchDashboard() {
    setState(() {
      _isManagerView = !_isManagerView;
    });
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
          child: _isLoading
              ? ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: const [
                    QuickStatSkeleton(),
                    SizedBox(width: 12),
                    QuickStatSkeleton(),
                  ],
                )
              : ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ManagerHRScreen()),
                        );
                      },
                      child: const QuickStatCard(
                        icon: Icons.badge_outlined,
                        value: '',
                        label: 'HR',
                        color: Color(0xFF10B981),
                      ),
                    ),
                    if (PB.pb.authStore.record?.data['bh_access'] == true) ...[
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/manager/customer-details');
                        },
                        child: const QuickStatCard(
                          icon: Icons.groups_outlined,
                          value: '',
                          label: 'Leads',
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AllocateLeadsSettingScreen()),
                          );
                        },
                        child: const QuickStatCard(
                          icon: Icons.settings_outlined,
                          value: '',
                          label: 'Setting',
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildTaskModulesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            'TASK',
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
          child: _isLoading
              ? ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: const [
                    QuickStatSkeleton(),
                    SizedBox(width: 12),
                    QuickStatSkeleton(),
                    SizedBox(width: 12),
                    QuickStatSkeleton(),
                  ],
                )
              : ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ManagerVKYCSummaryScreen()),
                        );
                      },
                      child: QuickStatCard(
                        icon: Icons.videocam_outlined,
                        value: '$_vkycCount',
                        label: 'VKYC',
                        color: const Color(0xFF0EA5E9),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ManagerBKYCSummaryScreen()),
                        );
                      },
                      child: QuickStatCard(
                        icon: Icons.fingerprint,
                        value: '$_bkycCount',
                        label: 'BKYC',
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ManagerActivationSummaryScreen()),
                        );
                      },
                      child: QuickStatCard(
                        icon: Icons.credit_card_outlined,
                        value: '$_activationCount',
                        label: 'Activation',
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isManagerView) {
      return const EmployeeDashboard();
    }

    final userName = PB.pb.authStore.record?.data['employee_name'] ?? 'Manager';

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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3B82F6),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
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
          // BH Dashboard Icon (Conditional)
          if (PB.pb.authStore.record?.data['bh_access'] == true)
            Container(
              margin: const EdgeInsets.only(right: 22),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/bh-dashboard');
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    'B',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployeeDashboard()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  'E',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Color(0xFF6B7280)),
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: const Color(0xFF3B82F6),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 16),
            _buildOverdueAlert(),
            OverviewCard(
              isLoading: _isLoading,
              employees: _employees,
              onRefresh: _loadDashboardData,
            ),
            const SizedBox(height: 16),
            DataUsageCard(
              isLoading: _isLoading,
              summary: _summary,
              onRefresh: _loadDashboardData,
              zeroNewLeadsCount: _zeroNewLeadsCount,
            ),
            const SizedBox(height: 16),
            AttendanceCard(
              isLoading: _isLoading,
              summary: _attendanceSummary,
            ),
            const SizedBox(height: 16),
            CallLogsCard(
              isLoading: _isLoading,
              summary: _callLogsSummary,
              onRefresh: _loadDashboardData,
            ),
            const SizedBox(height: 16),
            _buildMainModulesSection(),
            const SizedBox(height: 16),
            _buildTaskModulesSection(),
            const SizedBox(height: 100), // Space for bottom toggle
          ],
        ),
      ),
    );
  }

  Widget _buildOverdueAlert() {
    if (_overdueCount == 0 || PB.pb.authStore.record?.data['bh_access'] != true) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EmployeeListScreen()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2), // Sophisticated Light Red (Excel Style)
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFECACA)), // Subtle Red Border
          ),
          child: Center(
            child: SingleChildScrollView(
              controller: _marqueeController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      '⚠️ You have $_overdueCount pending trainee(s) to review. Please check.    ' * 5,
                      style: const TextStyle(
                        color: Color(0xFF991B1B), // Authoritative Dark Red Text
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
