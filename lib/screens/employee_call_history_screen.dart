import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/manager_call_log_service.dart';

class EmployeeCallHistoryScreen extends StatefulWidget {
  const EmployeeCallHistoryScreen({super.key});

  @override
  State<EmployeeCallHistoryScreen> createState() => _EmployeeCallHistoryScreenState();
}

class _EmployeeCallHistoryScreenState extends State<EmployeeCallHistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _hourlyData = [];
  bool _isLoading = true;
  String _employeeCode = '';
  String _employeeName = '';

  @override
  void initState() {
    super.initState();
    // Using a post-frame callback to access ModalRoute.of(context)
    // as it's not available directly in initState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _employeeCode = args['employee_code'] ?? '';
        _employeeName = args['employee_name'] ?? '';
        final dateString = args['selected_date'] as String?;
        if (dateString != null) {
          _selectedDate = DateTime.parse(dateString);
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
                _loadHourlyData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Color(0xFF10B981)),
              title: const Text('Yesterday'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedDate = DateTime.now().subtract(const Duration(days: 1)));
                _loadHourlyData();
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
                  _loadHourlyData();
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
    final dateStr = DateFormat('dd-MMM-yy').format(_selectedDate);
    
    // Calculate summary
    final totalCalls = _hourlyData.fold<int>(0, (sum, h) => sum + (h['call_count'] as int));
    final totalDuration = _hourlyData.fold<int>(0, (sum, h) => sum + (h['total_duration'] as int));
    final avgPerHour = _hourlyData.isNotEmpty ? (totalCalls / _hourlyData.length).round() : 0;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _employeeName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              dateStr,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
                height: 1.2,
              ),
            ),
          ],
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
          : _hourlyData.isEmpty
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
                        'No call history found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadHourlyData,
                  color: const Color(0xFF3B82F6),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: const Color(0xFFF9FAFB),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSummaryItem('Total', totalCalls.toString(), const Color(0xFF3B82F6)),
                              _buildSummaryItem('Duration', ManagerCallLogService.formatDuration(totalDuration), const Color(0xFF10B981)),
                              _buildSummaryItem('Avg/h', avgPerHour.toString(), const Color(0xFFF59E0B)),
                            ],
                          ),
                        ),
                        
                        // Header
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            'HOURLY BREAKDOWN',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        
                        // Table Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0xFFE5E7EB), width: 2),
                            ),
                          ),
                          child: Row(
                            children: const [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Time',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Calls',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Duration',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Idle',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Hourly Rows
                        ..._hourlyData.map((hour) => _buildHourlyRow(hour)),
                        
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyRow(Map<String, dynamic> hour) {
    final displayHour = hour['hour'] as int;
    final callCount = hour['call_count'] as int;
    final duration = hour['total_duration'] as int;
    final idle = hour['idle_time'] as int;
    
    // Format hour (11 AM, 12 PM, etc.)
    String formatHour(int h) {
      if (h == 12) return '12:00 PM';
      if (h > 12) return '${h - 12}:00 PM';
      return '$h:00 AM';
    }
    
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Time
            Expanded(
              flex: 2,
              child: Text(
                formatHour(displayHour),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            
            // Calls
            Expanded(
              child: Text(
                callCount.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10B981),
                ),
              ),
            ),
            
            // Duration
            Expanded(
              flex: 2,
              child: Text(
                ManagerCallLogService.formatDuration(duration),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B5CF6),
                ),
              ),
            ),
            
            // Idle
            Expanded(
              flex: 2,
              child: Text(
                ManagerCallLogService.formatDuration(idle),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
