import 'package:flutter/material.dart';
import '../services/manager_dashboard_service.dart';
import '../services/employee_presence_service.dart';
import '../services/leads_analytics_service.dart';
import '../models/employee_performance.dart';
import '../utils/employee_filter_utils.dart';

class LeadsDetailScreen extends StatefulWidget {
  const LeadsDetailScreen({super.key});

  @override
  State<LeadsDetailScreen> createState() => _LeadsDetailScreenState();
}

class _LeadsDetailScreenState extends State<LeadsDetailScreen> {
  bool _isLoading = true;
  List<EmployeePerformance> _employees = [];
  List<EmployeePerformance> _filteredEmployees = [];
  String _selectedFilter = 'Today';
  Set<String> _presentEmployeeCodes = {}; // Present employee codes from attendance
  Map<String, dynamic>? _apiSummary; // Store API summary for footer
  List<Map<String, dynamic>> _rawEmployeeData = []; // Store raw employee data for breakdown

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Only show full-page spinner on initial load
    if (_employees.isEmpty) {
      setState(() => _isLoading = true);
    }
    
    try {
      // Use pivot API for consistent data
      final filterType = _selectedFilter == 'Today' ? 'today' : 'yesterday';
      
      // Get complete analytics data with summary
      final analyticsData = await LeadsAnalyticsService.getAnalyticsData(filterType: filterType);
      final pivotData = List<Map<String, dynamic>>.from(analyticsData['employees'] ?? []);
      final summaryData = analyticsData['summary'] as Map<String, dynamic>;
      
      
      // Store summary and raw data
      _apiSummary = summaryData;
      _rawEmployeeData = pivotData;
      
      // Convert to EmployeePerformance format
      final employees = pivotData.map((e) => EmployeePerformance(
        employeeCode: e['employee_code'] as String? ?? '',
        employeeName: e['employee_name'] as String? ?? '',
        wfh: e['wfh'] as bool? ?? false,
        productivity: e['productivity'] as String? ?? '0.0',
        newLeadsCount: e['new'] as int? ?? 0,
        totalLeads: e['total'] as int? ?? 0, // Total activity
        workedLeads: e['worked'] as int? ?? 0, // Productive only
        ipa: e['ip_approved'] as int? ?? 0,
        ipd: e['ip_decline'] as int? ?? 0,
        role: e['role'] as String? ?? '',
      )).toList();

      
      // Fetch present employees from attendance (cached)
      final presentData = await EmployeePresenceService.getPresentEmployees();
      final presentCodes = Set<String>.from(presentData['all'] ?? []);
      
      // Sort: Present employees first, then absent
      // Within each group, sort by new leads (low to high)
      employees.sort((a, b) {
        final aPresent = presentCodes.contains(a.employeeCode);
        final bPresent = presentCodes.contains(b.employeeCode);
        
        // First sort by presence
        if (aPresent != bPresent) {
          return aPresent ? -1 : 1; // Present first
        }
        
        // Then sort by new leads count (low to high)
        return a.newLeadsCount.compareTo(b.newLeadsCount);
      });
      
      if (mounted) {
        setState(() {
          _employees = employees;
          _filteredEmployees = employees; // Show all employees
          _presentEmployeeCodes = presentCodes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use API summary directly (no frontend calculation)
    final totalNew = _apiSummary?['new_leads'] as int? ?? 0;
    final totalUsed = _apiSummary?['total_activity'] as int? ?? 0;
    final totalAll = totalNew + totalUsed;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // Soft grey background
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Leads',
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
          GestureDetector(
            onTap: () {
              if (_apiSummary != null && _rawEmployeeData.isNotEmpty) {
                Navigator.pushNamed(
                  context,
                  '/manager/aggregate-status-breakdown',
                  arguments: {
                    'summary': _apiSummary,
                    'employees': _rawEmployeeData,
                    'filter_type': _selectedFilter,
                  },
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.pie_chart_outline, color: Color(0xFF8B5CF6), size: 20),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/manager/leads-pivot'),
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.table_chart_outlined, color: Color(0xFF14B8A6), size: 20),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/allocate-leads');
            },
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.assignment_outlined, color: Color(0xFF3B82F6), size: 20),
            ),
          ),
          PopupMenuButton<String>(
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (_selectedFilter != value) {
                setState(() {
                  _selectedFilter = value;
                  _isLoading = true;
                });
                _loadData();
              }
            },
            itemBuilder: (context) => [
              _buildPopupMenuItem('today', 'Today'),
              _buildPopupMenuItem('yesterday', 'Yesterday'),
            ],
            child: Container(
              margin: const EdgeInsets.only(left: 8, right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calendar_today_outlined, color: Color(0xFF6B7280), size: 20),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
                  : _buildEmployeeList(),
            ),
            if (!_isLoading) _buildTotalFooter(totalNew, totalUsed, totalAll),
          ],
        ),
      ),
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'today': return 'Today';
      case 'yesterday': return 'Yesterday';
      case 'this_week': return 'This Week';
      case 'this_month': return 'This Month';
      default: return filter;
    }
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, String label) {
    final isSelected = _selectedFilter == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_circle : Icons.circle_outlined,
            size: 18,
            color: isSelected ? const Color(0xFF2563EB) : Colors.grey[400],
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeList() {
    if (_filteredEmployees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No employees found',
              style: TextStyle(
                fontSize: 14, 
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // Group by Office/WFH
    final officeEmployees = _filteredEmployees.where((e) => !e.wfh).toList();
    final wfhEmployees = _filteredEmployees.where((e) => e.wfh).toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (officeEmployees.isNotEmpty) ...[
            _buildEmployeeCard(officeEmployees, showHeader: true),
            const SizedBox(height: 16),
          ],
          if (wfhEmployees.isNotEmpty) ...[
            _buildGroupHeader('Work From Home', showCount: true, count: wfhEmployees.length),
            const SizedBox(height: 8),
            _buildEmployeeCard(wfhEmployees, showHeader: false),
          ],
        ],
      ),
    );
  }

  Widget _buildGroupHeader(String title, {bool showCount = false, int count = 0}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
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
          if (showCount) ...[
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
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(List<EmployeePerformance> employees, {required bool showHeader}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header (conditional)
          if (showHeader) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 35,
                    child: Text(
                      'SN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[400],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      'EMPLOYEE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[400],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Text(
                      'NEW',
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
                      'PR%',
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
                    width: 50,
                    child: Text(
                      'WKD',
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
                    width: 50,
                    child: Text(
                      'TOTAL',
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
          ],
          // List Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: employees.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
            itemBuilder: (context, index) {
              return _buildCompactRow(employees[index], index + 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompactRow(EmployeePerformance emp, int serialNo) {
    final hasNoNewLeads = emp.newLeadsCount == 0;
    final isPresent = _presentEmployeeCodes.contains(emp.employeeCode);
    
    // Color logic for name
    Color nameColor;
    if (!isPresent) {
      nameColor = Colors.grey[400]!; // Absent = Grey
    } else if (hasNoNewLeads) {
      nameColor = Colors.red; // Present with 0 new leads = Red
    } else {
      nameColor = const Color(0xFF1F2937); // Normal
    }
    
    // Color for New count
    Color newCountColor;
    if (!isPresent) {
      newCountColor = Colors.grey[400]!; // Absent = Grey
    } else if (hasNoNewLeads) {
      newCountColor = Colors.red; // 0 new leads = Red
    } else {
      newCountColor = const Color(0xFF10B981); // Normal green
    }

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/manager/employee-lead-detail',
          arguments: {
            'employee_code': emp.employeeCode,
            'employee_name': emp.employeeName,
            'filter_type': _selectedFilter,
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 35,
              child: Text(
                serialNo.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      emp.employeeName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: nameColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!isPresent) ...[
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
            SizedBox(
              width: 50,
              child: Text(
                emp.newLeadsCount == 0 ? '-' : emp.newLeadsCount.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: newCountColor,
                ),
              ),
            ),
            SizedBox(
              width: 45,
              child: Text(
                double.parse(emp.productivity).round() == 0 
                    ? '-' 
                    : '${double.parse(emp.productivity).round()}%',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isPresent ? const Color(0xFF6B7280) : Colors.grey[400],
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                emp.workedLeads == 0 ? '-' : emp.workedLeads.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isPresent ? const Color(0xFF2563EB) : Colors.grey[400], // Blue
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                emp.totalLeads == 0 ? '-' : emp.totalLeads.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isPresent ? Colors.black87 : Colors.grey[400], // Black
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalFooter(int totalNew, int totalUsed, int totalLeads) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSimpleFooterItem('New Leads', totalNew.toString(), const Color(0xFF10B981)),
            _buildSimpleFooterItem('Used Leads', totalUsed.toString(), const Color(0xFFF59E0B)),
            _buildSimpleFooterItem('Total', totalLeads.toString(), const Color(0xFF2563EB)),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleFooterItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
