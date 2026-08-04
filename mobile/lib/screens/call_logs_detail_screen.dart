import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/manager_call_log_service.dart';
import '../utils/employee_filter_utils.dart';

class CallLogsDetailScreen extends StatefulWidget {
  const CallLogsDetailScreen({super.key});

  @override
  State<CallLogsDetailScreen> createState() => _CallLogsDetailScreenState();
}

class _CallLogsDetailScreenState extends State<CallLogsDetailScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _callLogs = [];
  List<Map<String, dynamic>> _officeEmployees = [];
  List<Map<String, dynamic>> _wfhEmployees = [];
  List<Map<String, dynamic>> _traineeEmployees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCallLogs();
  }

  Future<void> _loadCallLogs() async {
    setState(() => _isLoading = true);
    
    try {
      final logs = await ManagerCallLogService.getCallLogsDetail(date: _selectedDate);
      
      final office = logs.where((e) => e['wfh'] == false && (e['designation'] ?? '').toString().trim().toLowerCase() != 'trainee').toList();
      final wfh = logs.where((e) => e['wfh'] == true && (e['designation'] ?? '').toString().trim().toLowerCase() != 'trainee').toList();
      final trainees = logs.where((e) => (e['designation'] ?? '').toString().trim().toLowerCase() == 'trainee').toList();
      
      // Sort by total duration (high to low)
      EmployeeFilterUtils.sortByField(office, 'total_duration');
      EmployeeFilterUtils.sortByField(wfh, 'total_duration');
      EmployeeFilterUtils.sortByField(trainees, 'total_duration');
      
      if (mounted) {
        setState(() {
          _callLogs = logs;
          _officeEmployees = office;
          _wfhEmployees = wfh;
          _traineeEmployees = trainees;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load call logs: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.today, color: Color(0xFF3B82F6)),
              title: const Text('Today'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedDate = DateTime.now());
                _loadCallLogs();
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Color(0xFF10B981)),
              title: const Text('Yesterday'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedDate = DateTime.now().subtract(const Duration(days: 1)));
                _loadCallLogs();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: Color(0xFF8B5CF6)),
              title: const Text('Custom Date'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                  _loadCallLogs();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(_selectedDate);
    
    // Calculate summary
    final totalCalls = _callLogs.fold<int>(0, (sum, log) => sum + (log['call_count'] as int));
    final totalDuration = _callLogs.fold<int>(0, (sum, log) => sum + (log['total_duration'] as int));
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          dateStr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, size: 20),
            onPressed: _showDatePicker,
            tooltip: 'Select Date',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF3B82F6),
              ),
            )
          : _callLogs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone_disabled,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No call logs found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadCallLogs,
                        color: const Color(0xFF3B82F6),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Office Section
                              if (_officeEmployees.isNotEmpty) ...[
                                _buildSectionHeader('🏢 OFFICE', _officeEmployees.length),
                                ..._officeEmployees.asMap().entries.map((entry) => 
                                  _buildEmployeeRow(entry.value, entry.key + 1)
                                ),
                              ],
                              
                              // WFH Section
                              if (_wfhEmployees.isNotEmpty) ...[
                                _buildSectionHeader('🏠 WORK FROM HOME', _wfhEmployees.length),
                                ..._wfhEmployees.asMap().entries.map((entry) => 
                                  _buildEmployeeRow(entry.value, entry.key + 1)
                                ),
                              ],
                              
                              // Trainees Section
                              if (_traineeEmployees.isNotEmpty) ...[
                                _buildSectionHeader('🎓 TRAINEES', _traineeEmployees.length),
                                ..._traineeEmployees.asMap().entries.map((entry) => 
                                  _buildEmployeeRow(entry.value, entry.key + 1)
                                ),
                              ],
                              
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildBottomSummary(totalCalls, totalDuration),
                  ],
                ),
    );
  }

  Widget _buildBottomSummary(int totalCalls, int totalDuration) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildFooterItem('Present', _callLogs.length.toString(), const Color(0xFF8B5CF6)),
            Container(width: 1, height: 20, color: const Color(0xFFE5E7EB)),
            _buildFooterItem('Calls', totalCalls > 0 ? totalCalls.toString() : '-', const Color(0xFF3B82F6)),
            Container(width: 1, height: 20, color: const Color(0xFFE5E7EB)),
            _buildFooterItem('Duration', totalDuration > 0 ? ManagerCallLogService.formatDuration(totalDuration) : '-', const Color(0xFF10B981)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterItem(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Text(
        '$title ($count)',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEmployeeRow(Map<String, dynamic> log, int sNo) {
    return GestureDetector(
      onTap: () {
        // Navigate to employee history
        Navigator.pushNamed(
          context,
          '/manager/employee-call-history',
          arguments: {
            'employee_code': log['employee_code'],
            'employee_name': log['employee_name'],
            'selected_date': DateFormat('yyyy-MM-dd').format(_selectedDate),
          },
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              // S.No
              SizedBox(
                width: 20,
                child: Text(
                  '$sNo.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              // Name
              Expanded(
                flex: 3,
                child: Text(
                  log['employee_name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              
              // Calls
              Expanded(
                child: Text(
                  (log['call_count'] as int? ?? 0) > 0 ? log['call_count'].toString() : '-',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: (log['call_count'] as int? ?? 0) > 0 ? const Color(0xFF10B981) : Colors.grey[400],
                  ),
                ),
              ),
              
              // Duration
              Expanded(
                flex: 2,
                child: Text(
                  (log['total_duration'] as int? ?? 0) > 0 
                      ? ManagerCallLogService.formatDuration(log['total_duration']) 
                      : '-',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: (log['total_duration'] as int? ?? 0) > 0 ? const Color(0xFF8B5CF6) : Colors.grey[400],
                  ),
                ),
              ),
              
              // Last Call
              Expanded(
                flex: 2,
                child: Text(
                  ManagerCallLogService.getRelativeTime(log['last_call_time']),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
