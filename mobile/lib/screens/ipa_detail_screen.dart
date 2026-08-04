import 'package:flutter/material.dart';
import '../core/pb_api.dart';
import '../models/employee_performance.dart';
import '../services/employee_presence_service.dart';
import '../services/attendance_service.dart';
import 'employee_performance_history_screen.dart';

class IpaDetailScreen extends StatefulWidget {
  const IpaDetailScreen({super.key});

  @override
  State<IpaDetailScreen> createState() => _IpaDetailScreenState();
}

class _IpaDetailScreenState extends State<IpaDetailScreen> {
  bool _isLoading = true;
  List<EmployeePerformance> _employees = [];
  Set<String> _presentEmployeeCodes = {};
  DateTime? _customDate;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  Map<String, double?> _growthPercentages = {};
  Map<String, int?> _comparisonCounts = {};
  List<Map<String, dynamic>> _lmtdData = []; // To store lmtd rows
  String _selectedFilter = 'today';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Date helper methods
  DateTime _getThisWeekStart() {
    final now = DateTime.now();
    final weekday = now.weekday; // Monday = 1, Sunday = 7
    return DateTime(now.year, now.month, now.day).subtract(Duration(days: weekday - 1));
  }

  DateTime _getThisWeekEnd() {
    return _getThisWeekStart().add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  }

  DateTime _getLastWeekStart() {
    return _getThisWeekStart().subtract(const Duration(days: 7));
  }

  DateTime _getLastWeekEnd() {
    return _getLastWeekStart().add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  }

  DateTime _getLastMonthStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month - 1, 1);
  }

  DateTime _getLastMonthEnd() {
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    return thisMonthStart.subtract(const Duration(days: 1)).add(const Duration(hours: 23, minutes: 59, seconds: 59));
  }

  String _formatDate(DateTime date) {
    // For date-only comparisons (YYYY-MM-DD), we use local day
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTimeForPB(DateTime date) {
    // PocketBase expects UTC strings for precise filtering
    final utc = date.toUtc();
    return '${utc.year.toString().padLeft(4, '0')}-${utc.month.toString().padLeft(2, '0')}-${utc.day.toString().padLeft(2, '0')} ${utc.hour.toString().padLeft(2, '0')}:${utc.minute.toString().padLeft(2, '0')}:${utc.second.toString().padLeft(2, '0')}';
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(hours: 23, minutes: 59, seconds: 59));

      // Build main date filter
      String dateFilter;
      switch (_selectedFilter) {
        case 'today':
          dateFilter = "lead_status_date >= '${_formatDateTimeForPB(todayStart)}' AND lead_status_date <= '${_formatDateTimeForPB(todayEnd)}'";
          break;
        case 'yesterday':
          final start = todayStart.subtract(const Duration(days: 1));
          final end = start.add(const Duration(hours: 23, minutes: 59, seconds: 59));
          dateFilter = "lead_status_date >= '${_formatDateTimeForPB(start)}' AND lead_status_date <= '${_formatDateTimeForPB(end)}'";
          break;
        case 'this_week':
          final start = _getThisWeekStart();
          final end = _getThisWeekEnd();
          dateFilter = "lead_status_date >= '${_formatDateTimeForPB(start)}' AND lead_status_date <= '${_formatDateTimeForPB(end)}'";
          break;
        case 'last_week':
          final start = _getLastWeekStart();
          final end = _getLastWeekEnd();
          dateFilter = "lead_status_date >= '${_formatDateTimeForPB(start)}' AND lead_status_date <= '${_formatDateTimeForPB(end)}'";
          break;
        case 'this_month':
          final start = DateTime(now.year, now.month, 1);
          dateFilter = "lead_status_date >= '${_formatDateTimeForPB(start)}' AND lead_status_date <= '${_formatDateTimeForPB(todayEnd)}'";
          break;
        case 'last_month':
          final start = _getLastMonthStart();
          final end = _getLastMonthEnd();
          dateFilter = "lead_status_date >= '${_formatDateTimeForPB(start)}' AND lead_status_date <= '${_formatDateTimeForPB(end)}'";
          break;
        case 'custom':
          if (_customDate != null) {
            final start = DateTime(_customDate!.year, _customDate!.month, _customDate!.day);
            final end = start.add(const Duration(hours: 23, minutes: 59, seconds: 59));
            dateFilter = "lead_status_date >= '${_formatDateTimeForPB(start)}' AND lead_status_date <= '${_formatDateTimeForPB(end)}'";
          } else {
            dateFilter = "lead_status_date >= '${_formatDateTimeForPB(todayStart)}' AND lead_status_date <= '${_formatDateTimeForPB(todayEnd)}'";
          }
          break;
        case 'custom_range':
          if (_rangeStart != null && _rangeEnd != null) {
            final start = DateTime(_rangeStart!.year, _rangeStart!.month, _rangeStart!.day);
            final end = DateTime(_rangeEnd!.year, _rangeEnd!.month, _rangeEnd!.day, 23, 59, 59);
            dateFilter = "lead_status_date >= '${_formatDateTimeForPB(start)}' AND lead_status_date <= '${_formatDateTimeForPB(end)}'";
          } else {
             dateFilter = "lead_status_date >= '${_formatDateTimeForPB(todayStart)}' AND lead_status_date <= '${_formatDateTimeForPB(todayEnd)}'";
          }
          break;
        default:
          dateFilter = "lead_status_date >= '${_formatDateTimeForPB(todayStart)}' AND lead_status_date <= '${_formatDateTimeForPB(todayEnd)}'";
      }

      // GROWTH LOGIC: Calculate Comparison Filters (MTD vs LMTD)
      String mtdFilter;
      String lmtdFilter;

      if (_selectedFilter == 'last_month') {
          // Last Month vs Last-to-Last Month Full
          final startLM = _getLastMonthStart();
          final endLM = _getLastMonthEnd();
          final startLLM = DateTime(startLM.year, startLM.month - 1, 1);
          final endLLM = startLM.subtract(const Duration(seconds: 1));
          mtdFilter = "lead_status_date >= '${_formatDateTimeForPB(startLM)}' AND lead_status_date <= '${_formatDateTimeForPB(endLM)}'";
          lmtdFilter = "lead_status_date >= '${_formatDateTimeForPB(startLLM)}' AND lead_status_date <= '${_formatDateTimeForPB(endLLM)}'";
      } else if (_selectedFilter == 'this_week') {
          // This Week vs Same Week Last Month (relative to today)
          final startCW = _getThisWeekStart();
          final endCW = now.isBefore(_getThisWeekEnd()) ? now : _getThisWeekEnd();
          
          final startLW = DateTime(startCW.year, startCW.month - 1, startCW.day);
          // Handling same relative progress in last month's week
          int dayOffset = endCW.difference(startCW).inDays;
          final endLW = DateTime(startLW.year, startLW.month, startLW.day, 23, 59, 59).add(Duration(days: dayOffset));

          mtdFilter = "lead_status_date >= '${_formatDateTimeForPB(startCW)}' AND lead_status_date <= '${_formatDateTimeForPB(endCW)}'";
          lmtdFilter = "lead_status_date >= '${_formatDateTimeForPB(startLW)}' AND lead_status_date <= '${_formatDateTimeForPB(endLW)}'";
      } else if (_selectedFilter == 'last_week') {
          // Last Week Full vs Same Dates Last Month Full
          final startCW = _getLastWeekStart();
          final endCW = _getLastWeekEnd();
          
          final startLW = DateTime(startCW.year, startCW.month - 1, startCW.day);
          final endLW = DateTime(endCW.year, endCW.month - 1, endCW.day, 23, 59, 59);

          mtdFilter = "lead_status_date >= '${_formatDateTimeForPB(startCW)}' AND lead_status_date <= '${_formatDateTimeForPB(endCW)}'";
          lmtdFilter = "lead_status_date >= '${_formatDateTimeForPB(startLW)}' AND lead_status_date <= '${_formatDateTimeForPB(endLW)}'";
      } else if (_selectedFilter == 'custom_range' && _rangeStart != null && _rangeEnd != null) {
          // Custom Range vs Same Range 30 Days Ago
          mtdFilter = "lead_status_date >= '${_formatDateTimeForPB(_rangeStart!)}' AND lead_status_date <= '${_formatDateTimeForPB(_rangeEnd!.add(const Duration(hours: 23, minutes: 59, seconds: 59)))}'";
          final start30 = _rangeStart!.subtract(const Duration(days: 30));
          final end30 = _rangeEnd!.subtract(const Duration(days: 30)).add(const Duration(hours: 23, minutes: 59, seconds: 59));
          lmtdFilter = "lead_status_date >= '${_formatDateTimeForPB(start30)}' AND lead_status_date <= '${_formatDateTimeForPB(end30)}'";
      } else {
          // Default: MTD vs LMTD (Today/Yesterday/Week/CustomDate)
          DateTime targetDay = now;
          if (_selectedFilter == 'yesterday') targetDay = now.subtract(const Duration(days: 1));
          if (_selectedFilter == 'custom' && _customDate != null) targetDay = _customDate!;
          
          final startMTD = DateTime(targetDay.year, targetDay.month, 1);
          final endMTD = DateTime(targetDay.year, targetDay.month, targetDay.day, 23, 59, 59);
          
          final startLMTD = DateTime(targetDay.year, targetDay.month - 1, 1);
          // Get same day of last month, handling shorter months if needed
          int lastMonthDay = targetDay.day;
          DateTime lastMonthEndDay = DateTime(targetDay.year, targetDay.month, 0); // Last day of last month
          if (lastMonthDay > lastMonthEndDay.day) lastMonthDay = lastMonthEndDay.day;
          final endLMTD = DateTime(targetDay.year, targetDay.month - 1, lastMonthDay, 23, 59, 59);

          mtdFilter = "lead_status_date >= '${_formatDateTimeForPB(startMTD)}' AND lead_status_date <= '${_formatDateTimeForPB(endMTD)}'";
          lmtdFilter = "lead_status_date >= '${_formatDateTimeForPB(startLMTD)}' AND lead_status_date <= '${_formatDateTimeForPB(endLMTD)}'";
      }
      
      // Parallel Data Fetching
      final List<dynamic> allStats = await Future.wait([
        PB.pb.send('/api/employee/stats', query: {'filter': dateFilter}),
        PB.pb.send('/api/employee/stats', query: {'filter': mtdFilter}),
        PB.pb.send('/api/employee/stats', query: {'filter': lmtdFilter}),
      ]);

      final statsData = List<Map<String, dynamic>>.from(allStats[0] as List);
      final mtdData = List<Map<String, dynamic>>.from(allStats[1] as List);
      final lmtdData = List<Map<String, dynamic>>.from(allStats[2] as List);
      
      // Map MTD vs LMTD to growth Map
      final Map<String, double?> growthMap = {};
      final Map<String, int?> countMap = {};
      for (var mtd in mtdData) {
        final code = mtd['employee_code'];
        final currentIpa = (mtd['ipa'] as int? ?? 0).toDouble();
        
        final lmtdMatch = lmtdData.firstWhere((l) => l['employee_code'] == code, orElse: () => {});
        final prevIpa = (lmtdMatch['ipa'] as int? ?? 0);
        
        countMap[code] = prevIpa;
        
        if (prevIpa > 0) {
          growthMap[code] = ((currentIpa - prevIpa.toDouble()) / prevIpa.toDouble()) * 100;
        } else if (currentIpa > 0) {
          growthMap[code] = 100.0; // New performance
        } else {
          growthMap[code] = null; // No data to compare
        }
      }

      final employees = statsData.map((e) => EmployeePerformance(
        employeeCode: e['employee_code']?.toString() ?? '',
        employeeName: e['employee_name']?.toString() ?? '',
        wfh: e['wfh'] == true,
        productivity: '0.0',
        newLeadsCount: 0,
        totalLeads: 0,
        workedLeads: 0,
        ipa: (e['ipa'] as num?)?.toInt() ?? 0,
        ipd: (e['ipd'] as num?)?.toInt() ?? 0,
        disabled: e['disabled'] == true,
        role: e['role']?.toString() ?? '',
        designation: e['designation']?.toString() ?? '',
      )).toList();
      
      // Load attendance for single-day filters
      if (_selectedFilter == 'today' || _selectedFilter == 'yesterday' || _selectedFilter == 'custom') {
        DateTime? targetDate;
        if (_selectedFilter == 'yesterday') {
          targetDate = DateTime.now().subtract(const Duration(days: 1));
        } else if (_selectedFilter == 'custom') {
          targetDate = _customDate;
        }
        
        final presentData = await EmployeePresenceService.getPresentEmployees(date: targetDate);
        _presentEmployeeCodes = Set<String>.from(presentData['all'] ?? []);
      } else {
        _presentEmployeeCodes = {};
      }
      
      if (mounted) {
        setState(() {
          _employees = employees;
          _growthPercentages = growthMap;
          _comparisonCounts = countMap;
          _lmtdData = lmtdData; // Save lmtdData for footer
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'today': return 'Today';
      case 'yesterday': return 'Yesterday';
      case 'this_week':
        final start = _getThisWeekStart();
        final end = _getThisWeekEnd();
        return 'This Week (${start.day}-${end.day} ${_getMonthName(start.month)})';
      case 'last_week': return 'Last Week';
      case 'this_month': return 'This Month';
      case 'last_month': return 'Last Month';
      case 'custom':
        if (_customDate != null) {
          return '${_customDate!.day} ${_getMonthName(_customDate!.month)} ${_customDate!.year}';
        }
        return 'Custom Date';
      case 'custom_range':
        if (_rangeStart != null && _rangeEnd != null) {
          return '${_rangeStart!.day} ${_getMonthName(_rangeStart!.month)} - ${_rangeEnd!.day} ${_getMonthName(_rangeEnd!.month)}';
        }
        return 'Custom Range';
      default: return 'Today';
    }
  }

  String _getMonthName(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
  }

  void _showFilterMenu() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.calendar_today, color: Color(0xFF3B82F6), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Select Date Range',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildFilterOption('Today', 'today', Icons.today),
              _buildFilterOption('Yesterday', 'yesterday', Icons.history),
              const Divider(height: 24),
              _buildFilterOption('This Week', 'this_week', Icons.date_range),
              _buildFilterOption('Last Week', 'last_week', Icons.calendar_view_week),
              const Divider(height: 24),
              _buildFilterOption('This Month', 'this_month', Icons.calendar_month),
              _buildFilterOption('Last Month', 'last_month', Icons.calendar_today_outlined),
              const Divider(height: 24),
              _buildFilterOption('Custom Date', 'custom', Icons.event, isCustom: true),
              _buildFilterOption('Custom Range', 'custom_range', Icons.date_range_outlined, isRange: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, String value, IconData icon, {bool isCustom = false, bool isRange = false}) {
    final isSelected = _selectedFilter == value;
    return InkWell(
      onTap: () async {
        if (isCustom) {
          Navigator.pop(context);
          final picked = await showDatePicker(
            context: context,
            initialDate: _customDate ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF3B82F6),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Color(0xFF111827),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            setState(() {
              _customDate = picked;
              _selectedFilter = 'custom';
            });
            _loadData();
          }
        } else if (isRange) {
          Navigator.pop(context);
          final picked = await showDateRangePicker(
            context: context,
            initialDateRange: (_rangeStart != null && _rangeEnd != null) 
                ? DateTimeRange(start: _rangeStart!, end: _rangeEnd!)
                : null,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF3B82F6),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Color(0xFF111827),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            setState(() {
              _rangeStart = picked.start;
              _rangeEnd = picked.end;
              _selectedFilter = 'custom_range';
            });
            _loadData();
          }
        } else {
          setState(() => _selectedFilter = value);
          Navigator.pop(context);
          _loadData();
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF374151),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                size: 20,
                color: Color(0xFF3B82F6),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalIpa = _employees.fold<int>(0, (sum, emp) => sum + emp.ipa);
    final totalIpd = _employees.fold<int>(0, (sum, emp) => sum + emp.ipd);
    final totalIp = totalIpa + totalIpd;
    final ipaPercentage = totalIp > 0 ? ((totalIpa / totalIp) * 100).toStringAsFixed(1) : '0';

    // Determine if we should sort by attendance (Single Date) or by status (Date Range)
    final showAttendance = _selectedFilter == 'today' || _selectedFilter == 'yesterday' || _selectedFilter == 'custom';

    void sortEmployees(List<EmployeePerformance> list) {
      list.sort((a, b) {
        if (showAttendance) {
          // Single Date: Present employees first
          final aPresent = _presentEmployeeCodes.contains(a.employeeCode);
          final bPresent = _presentEmployeeCodes.contains(b.employeeCode);
          if (aPresent != bPresent) return aPresent ? -1 : 1;
        } else {
          // Date Range: Active employees (not disabled) first
          if (a.disabled != b.disabled) return a.disabled ? 1 : -1;
        }

        // Secondary sort: IPA High to Low
        if (a.ipa != b.ipa) return b.ipa.compareTo(a.ipa);
        
        // Tertiary sort: IPD High to Low
        return b.ipd.compareTo(a.ipd);
      });
    }

    // Always group by Office/WFH/Trainees
    final officeEmployees = _employees.where((e) => !e.wfh && (e.designation ?? '').trim().toLowerCase() != 'trainee').toList();
    final wfhEmployees = _employees.where((e) => e.wfh && (e.designation ?? '').trim().toLowerCase() != 'trainee').toList();
    final traineeEmployees = _employees.where((e) => (e.designation ?? '').trim().toLowerCase() == 'trainee').toList();
    
    // Sort all groups using smart logic
    sortEmployees(officeEmployees);
    sortEmployees(wfhEmployees);
    sortEmployees(traineeEmployees);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'IPA Analytics',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
                fontSize: 20,
              ),
            ),
            Text(
              _getFilterLabel(_selectedFilter),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        actions: [
          InkWell(
            onTap: _showFilterMenu,
            borderRadius: BorderRadius.circular(20),
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
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: Column(
                children: [
                  // Sticky Header
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          child: Text(
                            'SN',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9CA3AF),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 3,
                          child: Text(
                            'EMPLOYEE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9CA3AF),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 45), // Growth column spacer
                        SizedBox(
                          width: 45,
                          child: Text(
                            'IPA',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[400],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 45,
                          child: Text(
                            'IPD',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[400],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 55,
                          child: Text(
                            'IPA%',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[400],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  Expanded(
                    child: _buildGroupedList(officeEmployees, wfhEmployees, traineeEmployees),
                  ),
                  _buildFooterSummary(totalIpa, totalIpd),
                ],
              ),
            ),
    );
  }


  Widget _buildFooterSummary(int totalIpa, int totalIpd) {
    final totalIp = totalIpa + totalIpd;
    
    // Calculate LMTD totals from saved map
    int totalIpaLmtd = 0;
    int totalIpdLmtd = 0;
    for (var m in _lmtdData) {
      totalIpaLmtd += (m['ipa'] as int? ?? 0);
      totalIpdLmtd += (m['ipd'] as int? ?? 0);
    }
    final totalIpLmtd = totalIpaLmtd + totalIpdLmtd;

    String _calcGrowth(int cur, int prev) {
      if (prev <= 0) return cur > 0 ? '+100%' : '';
      final g = ((cur - prev) / prev * 100).round();
      return (g >= 0 ? '+$g%' : '$g%');
    }

    final isDailyFilter = _selectedFilter == 'today' || _selectedFilter == 'yesterday' || _selectedFilter == 'custom';
    final ipaPercentage = totalIp > 0 ? ((totalIpa / totalIp) * 100).toStringAsFixed(1) : '0';
    
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildFooterItem(
              totalIpa.toString(), 
              'IPA', 
              const Color(0xFF10B981), 
              compValue: isDailyFilter ? null : totalIpaLmtd.toString(),
              growth: isDailyFilter ? null : _calcGrowth(totalIpa, totalIpaLmtd),
            ),
            Container(width: 1, height: 24, color: const Color(0xFFE5E7EB)),
            _buildFooterItem(
              totalIpd.toString(), 
              'IPD', 
              const Color(0xFFEF4444), 
              compValue: isDailyFilter ? null : totalIpdLmtd.toString(),
              growth: isDailyFilter ? null : _calcGrowth(totalIpd, totalIpdLmtd),
            ),
            Container(width: 1, height: 24, color: const Color(0xFFE5E7EB)),
            _buildFooterItem(
              totalIp.toString(), 
              'Total', 
              const Color(0xFF3B82F6), 
              compValue: isDailyFilter ? null : totalIpLmtd.toString(),
              growth: isDailyFilter ? null : _calcGrowth(totalIp, totalIpLmtd),
            ),
            Container(width: 1, height: 24, color: const Color(0xFFE5E7EB)),
            _buildFooterItem('$ipaPercentage%', 'IPA%', const Color(0xFF8B5CF6)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterItem(String value, String label, Color color, {String? compValue, String? growth}) {
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
              if (compValue != null) ...[
                TextSpan(
                  text: ' / $compValue',
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

  Widget _buildGroupedList(
    List<EmployeePerformance> officeEmployees,
    List<EmployeePerformance> wfhEmployees,
    List<EmployeePerformance> traineeEmployees,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (officeEmployees.isNotEmpty) ...[
            _buildEmployeeCard(officeEmployees),
          ],
          if (wfhEmployees.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildGroupHeader('Work From Home', count: wfhEmployees.length),
            const SizedBox(height: 8),
            _buildEmployeeCard(wfhEmployees),
          ],
          if (traineeEmployees.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildGroupHeader('Trainees', count: traineeEmployees.length),
            const SizedBox(height: 8),
            _buildEmployeeCard(traineeEmployees),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(String title, {int count = 0}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(List<EmployeePerformance> employees) {
    return Container(
      margin: EdgeInsets.zero, // Full width
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: employees.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
        itemBuilder: (context, index) {
          final emp = employees[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EmployeePerformanceHistoryScreen(employee: emp),
                ),
              );
            },
            child: _buildEmployeeRow(emp, index + 1),
          );
        },
      ),
    );
  }

  Widget _buildEmployeeRow(EmployeePerformance emp, int serialNo) {
    final showAttendance = _selectedFilter == 'today' || _selectedFilter == 'yesterday' || _selectedFilter == 'custom';
    final isPresent = showAttendance ? _presentEmployeeCodes.contains(emp.employeeCode) : true;
    final ipaPercentage = emp.totalIp > 0 ? ((emp.ipa / emp.totalIp) * 100).toStringAsFixed(0) : '0';
    
    // Determine name color: Red if disabled, Grey if absent, Black if present
    Color nameColor;
    if (emp.disabled) {
      nameColor = Colors.red;  // Left employee
    } else if (showAttendance && !isPresent) {
      nameColor = Colors.grey[400]!;  // Absent
    } else {
      nameColor = const Color(0xFF1F2937);  // Active
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              serialNo.toString(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    emp.employeeName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: nameColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (showAttendance && !isPresent) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
          // Growth Column
          SizedBox(
            width: 45,
            child: _buildGrowthIndicator(emp.employeeCode),
          ),
          SizedBox(
            width: 45,
            child: Text(
              emp.ipa > 0 ? emp.ipa.toString() : '-',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isPresent && emp.ipa > 0 ? const Color(0xFF10B981) : Colors.grey[400],
              ),
            ),
          ),
          SizedBox(
            width: 45,
            child: Text(
              emp.ipd > 0 ? emp.ipd.toString() : '-',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isPresent && emp.ipd > 0 ? const Color(0xFFEF4444) : Colors.grey[400],
              ),
            ),
          ),
          SizedBox(
            width: 55,
            child: Text(
              emp.totalIp > 0 ? '$ipaPercentage%' : '-',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isPresent && emp.totalIp > 0 ? const Color(0xFF8B5CF6) : Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthIndicator(String code) {
    final growth = _growthPercentages[code];
    final compCount = _comparisonCounts[code];
    if (growth == null) return const SizedBox();

    final isPositive = growth >= 0;
    final isDailyFilter = _selectedFilter == 'today' || _selectedFilter == 'yesterday' || _selectedFilter == 'custom';

    if (isDailyFilter) {
      // Daily: Icon Only (Prominent)
      return Center(
        child: Icon(
          isPositive ? Icons.trending_up : Icons.trending_down,
          size: 18,
          color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        ),
      );
    } else {
      // Periodic: Icon + Count (Horizontal)
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: 18,
            color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
          const SizedBox(width: 2),
          Text(
            compCount?.toString() ?? '0',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            ),
          ),
        ],
      );
    }
  }
}
