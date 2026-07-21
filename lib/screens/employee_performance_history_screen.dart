import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/pb_api.dart';
import '../models/employee_performance.dart';
import '../services/attendance_service.dart';

class EmployeePerformanceHistoryScreen extends StatefulWidget {
  final EmployeePerformance employee;

  const EmployeePerformanceHistoryScreen({
    super.key,
    required this.employee,
  });

  @override
  State<EmployeePerformanceHistoryScreen> createState() => _EmployeePerformanceHistoryScreenState();
}

class _EmployeePerformanceHistoryScreenState extends State<EmployeePerformanceHistoryScreen> {
  bool _isLoading = true;
  String _selectedRange = 'this_month'; // 'this_month' or 'last_month'
  List<Map<String, dynamic>> _historyData = [];
  Map<int, Map<String, int>> _comparisonStatsMap = {}; // Key: day, Value: {'ipa': x, 'ipd': y}
  Set<String> _presentDates = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      DateTime startDate;
      DateTime endDate;

      if (_selectedRange == 'this_month') {
        startDate = DateTime(now.year, now.month, 1);
        endDate = now;
      } else {
        // Last Month
        startDate = DateTime(now.year, now.month - 1, 1);
        endDate = DateTime(now.year, now.month, 0); // Last day of previous month
      }

      // Calculate Comparison Range (1 month prior)
      final compStartDate = DateTime(startDate.year, startDate.month - 1, 1);
      DateTime compEndDate;
      
      if (_selectedRange == 'this_month') {
        // Neck-to-Neck: Compare 1st-to-Today of this month with 1st-to-Today of last month
        int lastMonthDay = endDate.day;
        DateTime lastDayOfPrevMonth = DateTime(startDate.year, startDate.month, 0);
        if (lastMonthDay > lastDayOfPrevMonth.day) lastMonthDay = lastDayOfPrevMonth.day;
        compEndDate = DateTime(startDate.year, startDate.month - 1, lastMonthDay, 23, 59, 59);
      } else {
        // Full Month vs Full Month
        compEndDate = DateTime(startDate.year, startDate.month, 0); 
      }
      
      final monthStartStr = DateFormat('yyyy-MM-dd HH:mm:ss.SSS\'Z\'').format(startDate.toUtc());
      final monthEndStr = DateFormat('yyyy-MM-dd HH:mm:ss.SSS\'Z\'').format(endDate.toUtc());
      
      final compStartStr = DateFormat('yyyy-MM-dd HH:mm:ss.SSS\'Z\'').format(compStartDate.toUtc());
      final compEndStr = DateFormat('yyyy-MM-dd HH:mm:ss.SSS\'Z\'').format(compEndDate.toUtc());

      // Concurrent Data Fetching
      final results = await Future.wait([
        // 1. Current Performance Records
        PB.pb.collection('case_login').getFullList(
          filter: 'employee_code = "${widget.employee.employeeCode}" && lead_status_date >= "$monthStartStr" && lead_status_date <= "$monthEndStr"',
          fields: 'lead_status,lead_status_date',
        ),
        // 2. Attendance History
        AttendanceService.getEmployeeAttendanceHistory(
          employeeCode: widget.employee.employeeCode,
          startDate: startDate,
          endDate: endDate,
        ),
        // 3. Comparison Performance Records (Prev Month)
        PB.pb.collection('case_login').getFullList(
          filter: 'employee_code = "${widget.employee.employeeCode}" && lead_status_date >= "$compStartStr" && lead_status_date <= "$compEndStr"',
          fields: 'lead_status,lead_status_date',
        ),
      ]);

      final List<dynamic> records = results[0] as List;
      final List<dynamic> attendanceList = results[1] as List;
      final List<dynamic> compRecords = results[2] as List;
      
      _presentDates = Set<String>.from(
        attendanceList
          .where((a) => a['is_present'] == true)
          .map((a) => DateFormat('yyyy-MM-dd').format(a['date'] as DateTime))
      );

      // 3. Aggregate IPA/IPD by date (Converting UTC to IST)
      final statsMap = <String, Map<String, int>>{};
      for (var record in records) {
        try {
          final statusDateStr = record.data['lead_status_date'] as String?;
          if (statusDateStr == null) continue;
          
          final istDate = DateTime.parse(statusDateStr.replaceAll(' ', 'T')).toLocal();
          final dateKey = DateFormat('yyyy-MM-dd').format(istDate);
          final status = (record.data['lead_status']?.toString() ?? '').trim();
          
          statsMap.putIfAbsent(dateKey, () => {'ipa': 0, 'ipd': 0});
          if (status == 'IP Approved') statsMap[dateKey]!['ipa'] = statsMap[dateKey]!['ipa']! + 1;
          else if (status == 'IP Decline') statsMap[dateKey]!['ipd'] = statsMap[dateKey]!['ipd']! + 1;
        } catch (_) {}
      }

      // 4. Aggregate Comparison Stats by Day of Month
      final compMap = <int, Map<String, int>>{};
      for (var record in compRecords) {
        try {
          final statusDateStr = record.data['lead_status_date'] as String?;
          if (statusDateStr == null) continue;
          
          final istDate = DateTime.parse(statusDateStr.replaceAll(' ', 'T')).toLocal();
          final status = (record.data['lead_status']?.toString() ?? '').trim();
          
          compMap.putIfAbsent(istDate.day, () => {'ipa': 0, 'ipd': 0});
          if (status == 'IP Approved') {
            compMap[istDate.day]!['ipa'] = compMap[istDate.day]!['ipa']! + 1;
          } else if (status == 'IP Decline') {
            compMap[istDate.day]!['ipd'] = compMap[istDate.day]!['ipd']! + 1;
          }
        } catch (_) {}
      }

      // 4. Process data for range
      List<Map<String, dynamic>> processedData = [];
      final totalDays = endDate.difference(startDate).inDays + 1;
      
      for (int i = 0; i < totalDays; i++) {
        final date = startDate.add(Duration(days: i));
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        final dayStats = statsMap[dateKey];

        processedData.add({
          'date': date,
          'ipa': dayStats?['ipa'] ?? 0,
          'ipd': dayStats?['ipd'] ?? 0,
          'present': _presentDates.contains(dateKey),
        });
      }

      if (mounted) {
        setState(() {
          _historyData = processedData.reversed.toList();
          _comparisonStatsMap = compMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load history: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.employee.employeeName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF111827)),
            ),
            Text(
              _selectedRange == 'this_month' ? 'This Month Analytics' : 'Last Month Analytics',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        actions: [
          PopupMenuButton<String>(
            offset: const Offset(0, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (_selectedRange != value) {
                setState(() => _selectedRange = value);
                _loadHistory();
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF374151)),
                  SizedBox(width: 6),
                  Text(
                    'Filter',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF374151)),
                ],
              ),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'this_month', child: Text('This Month')),
              const PopupMenuItem(value: 'last_month', child: Text('Last Month')),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: const Row(
                    children: [
                      SizedBox(width: 30, child: Text('SN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF)))),
                      Expanded(flex: 4, child: Text('DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF)))),
                      SizedBox(width: 45), // Growth Icon+Count Header
                      SizedBox(width: 45, child: Text('IPA', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF)))),
                      SizedBox(width: 45, child: Text('IPD', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF)))),
                      SizedBox(width: 50, child: Text('IPA%', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF)))),
                    ],
                  ),
                ),
                const Divider(height: 1),
                
                // History List
                Expanded(
                  child: ListView.separated(
                    itemCount: _historyData.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    itemBuilder: (context, index) {
                      final item = _historyData[index];
                      final date = item['date'] as DateTime;
                      final isPresent = item['present'] as bool;
                      final ipa = item['ipa'] as int;
                      final ipd = item['ipd'] as int;
                      final totalIp = ipa + ipd;
                      final ipaPercentage = totalIp > 0 ? ((ipa / totalIp) * 100).toStringAsFixed(0) : '0';

                      return Container(
                        color: isPresent ? Colors.white : Colors.grey[50],
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            SizedBox(width: 30, child: Text('${index + 1}', style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)))),
                            Expanded(
                              flex: 4, 
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    DateFormat('dd-MMM, E').format(date),
                                    style: TextStyle(
                                      fontSize: 12.5, 
                                      fontWeight: FontWeight.w600, 
                                      color: isPresent ? const Color(0xFF1F2937) : Colors.grey[400]
                                    ),
                                  ),
                                  if (!isPresent) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 14,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            
                            // Growth Indicator
                            SizedBox(
                              width: 45,
                              child: _buildDayGrowthIndicator(date.day, ipa),
                            ),

                            SizedBox(
                              width: 45,
                              child: Text(
                                (isPresent && ipa > 0) ? ipa.toString() : '-',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: (isPresent && ipa > 0) ? const Color(0xFF10B981) : Colors.grey[400],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 45,
                              child: Text(
                                (isPresent && ipd > 0) ? ipd.toString() : '-',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: (isPresent && ipd > 0) ? const Color(0xFFEF4444) : Colors.grey[400],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 50,
                              child: Text(
                                (isPresent && totalIp > 0) ? '$ipaPercentage%' : '-',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: (isPresent && totalIp > 0) ? const Color(0xFF3B82F6) : Colors.grey[400],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // Performance Footer
                _buildSummaryFooter(),
              ],
            ),
    );
  }

  Widget _buildSummaryFooter() {
    int totalIpa = 0;
    int totalIpd = 0;
    for (var item in _historyData) {
      totalIpa += item['ipa'] as int;
      totalIpd += item['ipd'] as int;
    }
    
    // Calculate Prev Month Totals
    int totalIpaPrev = 0;
    int totalIpdPrev = 0;
    _comparisonStatsMap.forEach((day, stats) {
      totalIpaPrev += stats['ipa'] ?? 0;
      totalIpdPrev += stats['ipd'] ?? 0;
    });

    final totalIp = totalIpa + totalIpd;
    final totalIpPrev = totalIpaPrev + totalIpdPrev;
    
    String _calcGrowth(int cur, int prev) {
      if (prev <= 0) return cur > 0 ? '+100%' : '';
      final g = ((cur - prev) / prev * 100).round();
      return (g >= 0 ? '+$g%' : '$g%');
    }

    final overallPercentage = totalIp > 0 ? ((totalIpa / totalIp) * 100).toStringAsFixed(1) : '0.0';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildFooterStat(totalIpa.toString(), 'IPA', const Color(0xFF10B981), 
                prevValue: totalIpaPrev.toString(), growth: _calcGrowth(totalIpa, totalIpaPrev)),
            Container(width: 1, height: 24, color: const Color(0xFFE5E7EB)),
            _buildFooterStat(totalIpd.toString(), 'IPD', const Color(0xFFEF4444), 
                prevValue: totalIpdPrev.toString(), growth: _calcGrowth(totalIpd, totalIpdPrev)),
            Container(width: 1, height: 24, color: const Color(0xFFE5E7EB)),
            _buildFooterStat(totalIp.toString(), 'Total', const Color(0xFF3B82F6), 
                prevValue: totalIpPrev.toString(), growth: _calcGrowth(totalIp, totalIpPrev)),
            Container(width: 1, height: 24, color: const Color(0xFFE5E7EB)),
            _buildFooterStat('$overallPercentage%', 'IPA%', const Color(0xFF8B5CF6)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterStat(String value, String label, Color color, {String? prevValue, String? growth}) {
    final isPositive = growth != null && !growth.startsWith('-');
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (prevValue != null) ...[
                TextSpan(
                  text: ' / $prevValue',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: color.withOpacity(0.5),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              if (growth != null && growth.isNotEmpty) ...[
                const TextSpan(text: ' '),
                TextSpan(
                  text: '($growth)',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayGrowthIndicator(int day, int currentIpa) {
    // Treat null (no data) as 0
    final prevIpa = _comparisonStatsMap[day]?['ipa'] ?? 0;
    
    // If both are 0, no need to show trend
    if (currentIpa == 0 && prevIpa == 0) return const SizedBox();

    final isPositive = currentIpa >= prevIpa;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isPositive ? Icons.trending_up : Icons.trending_down,
          size: 15,
          color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        ),
        if (prevIpa > 0) ...[
          const SizedBox(width: 2),
          Text(
            prevIpa.toString(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            ),
          ),
        ],
      ],
    );
  }
}
