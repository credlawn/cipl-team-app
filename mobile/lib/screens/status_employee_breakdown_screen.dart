import 'package:flutter/material.dart';
import '../services/employee_presence_service.dart';

class StatusEmployeeBreakdownScreen extends StatefulWidget {
  const StatusEmployeeBreakdownScreen({super.key});

  @override
  State<StatusEmployeeBreakdownScreen> createState() => _StatusEmployeeBreakdownScreenState();
}

class _StatusEmployeeBreakdownScreenState extends State<StatusEmployeeBreakdownScreen> {
  bool _isLoading = true;
  Set<String> _presentEmployeeCodes = {};
  List<Map<String, dynamic>> _employees = [];
  String _statusLabel = '';
  String _statusField = '';
  Color _statusColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _employees = List<Map<String, dynamic>>.from(args['employees'] ?? []);
          _statusLabel = args['status_label'] as String? ?? '';
          _statusField = args['status_field'] as String? ?? '';
          _statusColor = args['status_color'] as Color? ?? Colors.blue;
        });
        _loadPresenceData();
      }
    });
  }

  Future<void> _loadPresenceData() async {
    try {
      final presentData = await EmployeePresenceService.getPresentEmployees();
      if (mounted) {
        setState(() {
          _presentEmployeeCodes = Set<String>.from(presentData['all'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show all employees (including count = 0)
    final filteredEmployees = _employees.toList();

    // Separate by WFH
    final officeEmployees = filteredEmployees.where((e) => !(e['wfh'] as bool? ?? false)).toList();
    final wfhEmployees = filteredEmployees.where((e) => e['wfh'] as bool? ?? false).toList();

    // Sort by count (high to low)
    officeEmployees.sort((a, b) => (b[_statusField] as int).compareTo(a[_statusField] as int));
    wfhEmployees.sort((a, b) => (b[_statusField] as int).compareTo(a[_statusField] as int));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _statusLabel,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Employee Breakdown',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredEmployees.isEmpty
              ? const Center(child: Text('No employees found'))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (officeEmployees.isNotEmpty) ...[
                              _buildGroupHeader('Office', showCount: true, count: officeEmployees.length),
                              _buildEmployeeCard(officeEmployees),
                            ],
                            if (wfhEmployees.isNotEmpty) ...[
                              _buildGroupHeader('Work From Home', showCount: true, count: wfhEmployees.length),
                              _buildEmployeeCard(wfhEmployees),
                            ],
                          ],
                        ),
                      ),
                    ),
                    _buildTotalFooter(filteredEmployees.length),
                  ],
                ),
    );
  }

  Widget _buildGroupHeader(String title, {bool showCount = false, int count = 0}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
          if (showCount) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
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

  Widget _buildEmployeeCard(List<Map<String, dynamic>> employees) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const SizedBox(
                  width: 35,
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
                  flex: 4,
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
                SizedBox(
                  width: 60,
                  child: Text(
                    'COUNT',
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
          // List Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: employees.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
            itemBuilder: (context, index) {
              return _buildEmployeeRow(employees[index], index + 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeRow(Map<String, dynamic> employee, int serialNo) {
    final employeeCode = employee['employee_code'] as String? ?? '';
    final employeeName = employee['employee_name'] as String? ?? '';
    final count = employee[_statusField] as int? ?? 0;
    final isPresent = _presentEmployeeCodes.contains(employeeCode);

    return Padding(
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
                    employeeName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isPresent ? const Color(0xFF1F2937) : Colors.grey[400],
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
            width: 60,
            child: Text(
              count.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isPresent ? _statusColor : Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalFooter(int totalEmployees) {
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  totalEmployees.toString(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _statusColor,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Total Employees',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
