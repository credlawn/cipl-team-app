import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../core/pb_api.dart';
import '../models/dashboard_analytics_model.dart';
import '../services/dashboard_analytics_service.dart';
import '../services/login_case_service.dart';
import '../widgets/metric_card.dart';
import '../widgets/approval_rate_bar.dart';
import '../widgets/activity_list_item.dart';
import '../widgets/weekly_trend_chart.dart';
import '../widgets/analytics_skeleton_loader.dart';
import 'my_login_screen.dart';

class CallAnalyticsScreen extends StatefulWidget {
  const CallAnalyticsScreen({super.key});

  @override
  State<CallAnalyticsScreen> createState() => _CallAnalyticsScreenState();
}

class _CallAnalyticsScreenState extends State<CallAnalyticsScreen> {
  DateFilter _selectedFilter = DateFilter.today;
  DashboardAnalytics? _analytics;
  bool _isLoading = true;
  int _ipaCount = 0;
  int _ipdCount = 0;
  int _loginCount = 0;
  double _approvalRate = 0.0;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      final analytics = await DashboardAnalyticsService.getAnalytics(_selectedFilter);
      
      final dateRange = _getDateRange(_selectedFilter);
      final ipaCount = await LoginCaseService.getIpaCount(dateRange['start']!, dateRange['end']!);
      final ipdCount = await LoginCaseService.getIpdCount(dateRange['start']!, dateRange['end']!);
      final loginCount = await LoginCaseService.getTotalLoginCount(dateRange['start']!, dateRange['end']!);
      final approvalRate = await LoginCaseService.getApprovalRate(dateRange['start']!, dateRange['end']!);
      
      setState(() {
        _analytics = analytics;
        _ipaCount = ipaCount;
        _ipdCount = ipdCount;
        _loginCount = loginCount;
        _approvalRate = approvalRate;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _openMyLogin(StatusFilterType? statusFilter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MyLoginScreen(initialStatusFilter: statusFilter),
      ),
    );
  }

  Map<String, DateTime> _getDateRange(DateFilter filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (filter) {
      case DateFilter.today:
        return {
          'start': today,
          'end': today.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)),
        };
      case DateFilter.week:
        final weekStart = today.subtract(Duration(days: now.weekday - 1));
        return {
          'start': weekStart,
          'end': today.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)),
        };
      case DateFilter.month:
        return {
          'start': DateTime(now.year, now.month, 1),
          'end': today.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)),
        };
    }
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    
    if (totalSeconds < 60) {
      return '${totalSeconds}s';
    }
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}h';
    }
    
    return '$minutes:${seconds.toString().padLeft(2, '0')}m';
  }

  String _formatLastCall(DateTime? lastCall) {
    if (lastCall == null) return 'No calls yet';
    final diff = DateTime.now().difference(lastCall);
    
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    
    if (diff.inHours < 24) {
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      if (minutes == 0) {
        return '${hours}h ago';
      }
      return '${hours}h ${minutes}min ago';
    }
    
    final days = diff.inDays;
    return '$days day${days > 1 ? 's' : ''} ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Call Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          _buildCompactFilterChip('T', DateFilter.today),
          const SizedBox(width: 4),
          _buildCompactFilterChip('W', DateFilter.week),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            onPressed: () async {
              try {
                final image = await _screenshotController.capture();
                if (image != null) {
                  final employeeName = PB.pb.authStore.model?.data['employee_name'] ?? 'Dashboard';
                  final timestamp = DateFormat('d MMM h:mm a').format(DateTime.now());
                  
                  await Share.shareXFiles([
                    XFile.fromData(
                      image,
                      mimeType: 'image/png',
                      name: 'call_analytics_${DateFormat('yyyyMMdd').format(DateTime.now())}.png',
                    ),
                  ], text: '$employeeName $timestamp');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to share screenshot')),
                  );
                }
              }
            },
            tooltip: 'Share',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const AnalyticsSkeletonLoader()
          : _analytics == null
              ? const Center(child: Text('Failed to load analytics'))
              : RefreshIndicator(
                  onRefresh: _loadAnalytics,
                  child: Screenshot(
                    controller: _screenshotController,
                    child: Container(
                      color: Colors.white,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildKeyMetricsSection(),
                            const SizedBox(height: 16),
                            _buildCallActivitySection(),
                            const SizedBox(height: 16),
                            _buildWeeklyTrendSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildCompactFilterChip(String label, DateFilter filter) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = filter);
        _loadAnalytics();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyMetricsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _openMyLogin(StatusFilterType.approved),
                  child: MetricCard(
                    icon: '🎉',
                    value: _ipaCount.toString(),
                    label: 'IPA',
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => _openMyLogin(StatusFilterType.declined),
                  child: MetricCard(
                    icon: '😞',
                    value: _ipdCount.toString(),
                    label: 'IPD',
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => _openMyLogin(StatusFilterType.all),
                  child: MetricCard(
                    icon: '📋',
                    value: _loginCount.toString(),
                    label: 'Login',
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ApprovalRateBar(
            rate: _approvalRate,
            trend: _analytics!.approvalTrend,
          ),
        ],
      ),
    );
  }

  Widget _buildCallActivitySection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'CALL ACTIVITY',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ),
          ActivityListItem(
            iconData: Icons.phone_in_talk,
            iconColor: const Color(0xFF10B981),
            label: 'Connected',
            value: _analytics!.answeredCalls.toString(),
          ),
          ActivityListItem(
            emoji: '🕒',
            label: 'Total Duration',
            value: _formatDuration(_analytics!.totalTalkTime),
          ),
          ActivityListItem(
            emoji: '⏱️',
            label: 'Avg Duration',
            value: _formatDuration(_analytics!.avgCallDuration),
          ),
          ActivityListItem(
            emoji: '⚡',
            label: 'Hourly Efficiency',
            value: '${_analytics!.hourlyEfficiency.toStringAsFixed(1)}/hr',
          ),
          ActivityListItem(
            emoji: '🕐',
            label: 'Last Call',
            value: _formatLastCall(_analytics!.lastCallTime),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrendSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: WeeklyTrendChart(
        callsByDay: _analytics!.callsByDay,
        durationByDay: _analytics!.durationByDay,
      ),
    );
  }
}
