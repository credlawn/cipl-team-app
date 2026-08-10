import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/manager_call_log_service.dart';
import '../utils/call_history_share_util.dart';

class EmployeeCallHistoryScreen extends StatefulWidget {
  const EmployeeCallHistoryScreen({super.key});

  @override
  State<EmployeeCallHistoryScreen> createState() => _EmployeeCallHistoryScreenState();
}

class _EmployeeCallHistoryScreenState extends State<EmployeeCallHistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _hourlyData = [];
  bool _isLoading = true;
  bool _isSharing = false;
  String _employeeCode = '';
  String _employeeName = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _employeeCode = args['employee_code'] ?? '';
        _employeeName = args['employee_name'] ?? '';
        final dateString = args['selected_date'] as String?;
        if (dateString != null) {
          try {
            _selectedDate = DateTime.parse(dateString);
          } catch (_) {}
        }

        if (_employeeCode.isNotEmpty) {
          _loadHourlyData();
        }
      }
    });
  }

  Future<void> _loadHourlyData() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await ManagerCallLogService.getEmployeeCallHistoryHourly(
        employeeCode: _employeeCode,
        date: _selectedDate,
      );
      
      if (mounted) {
        setState(() {
          _hourlyData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load call history: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  void _showCustomDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadHourlyData();
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM, yyyy').format(_selectedDate);
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final isToday = _isSameDay(_selectedDate, now);
    final isYesterday = _isSameDay(_selectedDate, yesterday);

    final currentEndHour = now.hour + (now.minute > 0 ? 1 : 0);
    final visibleHourlyData = isToday
        ? _hourlyData.where((h) => (h['hour'] as int? ?? 0) <= currentEndHour).toList()
        : _hourlyData;

    // Calculate Summary Metrics
    final totalCalls = visibleHourlyData.fold<int>(0, (sum, h) => sum + (h['call_count'] as int? ?? 0));
    final totalDuration = visibleHourlyData.fold<int>(0, (sum, h) => sum + (h['total_duration'] as int? ?? 0));
    final totalIdle = visibleHourlyData.fold<int>(0, (sum, h) => sum + (h['idle_time'] as int? ?? 0));
    final totalIPA = visibleHourlyData.fold<int>(0, (sum, h) => sum + (h['ipa_count'] as int? ?? 0));
    final totalCases = visibleHourlyData.fold<int>(0, (sum, h) => sum + (h['total_cases'] as int? ?? 0));
    final totalWorkSecs = totalDuration + totalIdle;
    final efficiencyPct = totalWorkSecs > 0 ? ((totalDuration / totalWorkSecs) * 100).round() : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _employeeName.isNotEmpty ? _employeeName : 'Employee Call Activity',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                if (_employeeCode.isNotEmpty) ...[
                  Text(
                    'Code: $_employeeCode',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('•', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                  ),
                ],
                Text(
                  dateStr,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (_isSharing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.0),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.share_rounded, size: 20, color: Color(0xFF2563EB)),
              onPressed: visibleHourlyData.isEmpty
                  ? null
                  : () {
                      CallHistoryShareUtil.shareHourlyReportImage(
                        context: context,
                        employeeName: _employeeName,
                        employeeCode: _employeeCode,
                        selectedDate: _selectedDate,
                        hourlyData: visibleHourlyData,
                        setLoading: (loading) {
                          if (mounted) setState(() => _isSharing = loading);
                        },
                      );
                    },
              tooltip: 'Share Report Image',
            ),
          const SizedBox(width: 4),
        ],
      ),
      bottomNavigationBar: _isLoading
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      '$totalCalls',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    Container(width: 1, height: 18, color: const Color(0xFFE5E7EB)),
                    Text(
                      ManagerCallLogService.formatDuration(totalDuration),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                    if (totalIPA > 0 || (totalCases - totalIPA) > 0) ...[
                      Container(width: 1, height: 18, color: const Color(0xFFE5E7EB)),
                      _buildIpaIpdWidget(
                        ipa: totalIPA,
                        ipd: totalCases - totalIPA,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                    Container(width: 1, height: 18, color: const Color(0xFFE5E7EB)),
                    Text(
                      '$efficiencyPct% Score',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: Column(
        children: [
          // ── Date Chips Bar ───────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _buildDateChip('Today', isToday, () {
                  setState(() => _selectedDate = DateTime.now());
                  _loadHourlyData();
                }),
                const SizedBox(width: 8),
                _buildDateChip('Yesterday', isYesterday, () {
                  setState(() => _selectedDate = DateTime.now().subtract(const Duration(days: 1)));
                  _loadHourlyData();
                }),
                const SizedBox(width: 8),
                _buildDateChip(
                  isToday || isYesterday ? 'Custom Date' : DateFormat('dd MMM').format(_selectedDate),
                  !isToday && !isYesterday,
                  _showCustomDatePicker,
                  icon: Icons.calendar_month_rounded,
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // ── Main Content Area ─────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
                : RefreshIndicator(
                    onRefresh: _loadHourlyData,
                    color: const Color(0xFF2563EB),
                    child: ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        // ── Section Title ───────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'HOURLY TIMELINE ACTIVITY',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4B5563),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              '${visibleHourlyData.length} Hours Tracked',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // ── Empty State vs List ─────────────────────────────
                        if (visibleHourlyData.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.phone_disabled_outlined, size: 48, color: Colors.grey.shade300),
                                const SizedBox(height: 12),
                                const Text(
                                  'No hourly call logs for this date',
                                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Column(
                              children: List.generate(visibleHourlyData.length, (index) {
                                return _buildHourlyItem(visibleHourlyData[index]);
                              }),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip(String label, bool isSelected, VoidCallback onTap, {IconData? icon}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF4B5563)),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildHourlyItem(Map<String, dynamic> hour) {
    final displayHour = hour['hour'] as int? ?? 11;
    final callCount = hour['call_count'] as int? ?? 0;
    final duration = hour['total_duration'] as int? ?? 0;
    final idle = hour['idle_time'] as int? ?? 0;
    final ipaCount = hour['ipa_count'] as int? ?? 0;
    final totalCases = hour['total_cases'] as int? ?? 0;

    String formatHourBlock(int endHour) {
      String fmt(int hour) {
        final norm = (hour + 24) % 24;
        if (norm == 0) return '12:00 AM';
        if (norm < 12) return '$norm:00 AM';
        if (norm == 12) return '12:00 PM';
        return '${norm - 12}:00 PM';
      }
      return '${fmt(endHour - 1)} - ${fmt(endHour)}';
    }

    final totalHourSecs = duration + idle;
    final activePct = totalHourSecs > 0 ? ((duration / totalHourSecs) * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Line 1 (Subtle Context): Time Range & Active %
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatHourBlock(displayHour),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              if (callCount > 0)
                Text(
                  '$activePct% active',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // Line 2 (Hero Content): Bold, High-Contrast Metrics
          Row(
            children: [
              // Calls Metric
              Row(
                children: [
                  const Icon(Icons.phone_in_talk_rounded, size: 15, color: Color(0xFF2563EB)),
                  const SizedBox(width: 4),
                  Text(
                    '$callCount',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('•', style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13)),
              ),
              // Talk Duration Metric (Green)
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 15, color: Color(0xFF16A34A)),
                  const SizedBox(width: 4),
                  Text(
                    ManagerCallLogService.formatDuration(duration),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF14532D),
                    ),
                  ),
                ],
              ),
              if (ipaCount > 0 || (totalCases - ipaCount) > 0) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('•', style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13)),
                ),
                _buildIpaIpdWidget(
                  ipa: ipaCount,
                  ipd: totalCases - ipaCount,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIpaIpdWidget({
    required int ipa,
    required int ipd,
    required double fontSize,
    required FontWeight fontWeight,
  }) {
    if (ipa == 0 && ipd == 0) {
      return const SizedBox.shrink();
    }

    const fw = FontWeight.w600;

    if (ipa > 0 && ipd == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF86EFAC), width: 0.8),
        ),
        child: Text(
          '${ipa}A',
          style: TextStyle(
            fontSize: fontSize - 1,
            fontWeight: fw,
            color: const Color(0xFF15803D),
          ),
        ),
      );
    } else if (ipa == 0 && ipd > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E8),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFFCA5A5), width: 0.8),
        ),
        child: Text(
          '${ipd}D',
          style: TextStyle(
            fontSize: fontSize - 1,
            fontWeight: fw,
            color: const Color(0xFFB91C1C),
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${ipa}A',
              style: TextStyle(
                fontSize: fontSize - 1,
                fontWeight: fw,
                color: const Color(0xFF15803D),
              ),
            ),
            Text(
              ' • ',
              style: TextStyle(
                fontSize: fontSize - 1,
                fontWeight: fw,
                color: const Color(0xFF94A3B8),
              ),
            ),
            Text(
              '${ipd}D',
              style: TextStyle(
                fontSize: fontSize - 1,
                fontWeight: fw,
                color: const Color(0xFFB91C1C),
              ),
            ),
          ],
        ),
      );
    }
  }
}
