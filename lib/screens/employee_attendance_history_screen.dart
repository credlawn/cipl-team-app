import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/attendance_service.dart';
import '../core/pb_api.dart';

class EmployeeAttendanceHistoryScreen extends StatefulWidget {
  final String employeeCode;
  final String employeeName;
  final DateTime? employeeJoiningDate;

  const EmployeeAttendanceHistoryScreen({
    super.key,
    required this.employeeCode,
    required this.employeeName,
    this.employeeJoiningDate,
  });

  @override
  State<EmployeeAttendanceHistoryScreen> createState() => _EmployeeAttendanceHistoryScreenState();
}

class _EmployeeAttendanceHistoryScreenState extends State<EmployeeAttendanceHistoryScreen> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  List<Map<String, dynamic>> _attendanceRecords = [];
  bool _isLoading = true;
  String _filterLabel = 'This Month';

  @override
  void initState() {
    super.initState();
    _setCurrentMonth();
    _loadAttendanceHistory();
  }

  void _setCurrentMonth() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = today;
    _filterLabel = 'This Month';
  }

  void _setLastMonth() {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    _startDate = lastMonth;
    _endDate = DateTime(now.year, now.month, 0); // Last day of previous month
    _filterLabel = 'Last Month';
  }

  void _setCurrentPayroll() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime start;
    if (now.day >= 21) {
      start = DateTime(now.year, now.month, 21);
    } else {
      start = DateTime(now.year, now.month - 1, 21);
    }
    _startDate = start;
    _endDate = today;
    _filterLabel = 'Current Payroll';
  }

  void _setLastPayroll() {
    final now = DateTime.now();
    DateTime start;
    DateTime end;
    if (now.day >= 21) {
      start = DateTime(now.year, now.month - 1, 21);
      end = DateTime(now.year, now.month, 20);
    } else {
      start = DateTime(now.year, now.month - 2, 21);
      end = DateTime(now.year, now.month - 1, 20);
    }
    _startDate = start;
    _endDate = end;
    _filterLabel = 'Last Payroll';
  }

  Future<void> _loadAttendanceHistory() async {
    setState(() => _isLoading = true);
    
    try {
      final records = await AttendanceService.getEmployeeAttendanceHistory(
        employeeCode: widget.employeeCode,
        startDate: _startDate,
        endDate: _endDate,
      );
      
      // Filter out dates before joining date
      List<Map<String, dynamic>> filteredRecords = records;
      if (widget.employeeJoiningDate != null) {
        final joiningDate = DateTime(
          widget.employeeJoiningDate!.year,
          widget.employeeJoiningDate!.month,
          widget.employeeJoiningDate!.day,
        );
        
        filteredRecords = records.where((record) {
          final date = record['date'] as DateTime;
          final recordDate = DateTime(date.year, date.month, date.day);
          return !recordDate.isBefore(joiningDate); // >= comparison
        }).toList();
      }
      
      if (mounted) {
        setState(() {
          // Conditional Sorting: Ascending for Payroll, Descending for others
          if (_filterLabel.contains('Payroll')) {
            filteredRecords.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
          } else {
            filteredRecords.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
          }
          
          _attendanceRecords = filteredRecords;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load attendance: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  void _showFilterModal() {
    final now = DateTime.now();
    
    // Calculate Dynamic Payroll Subtitles
    DateTime currentStart;
    DateTime lastStart;
    DateTime lastEnd;
    
    if (now.day >= 21) {
      currentStart = DateTime(now.year, now.month, 21);
      lastStart = DateTime(now.year, now.month - 1, 21);
      lastEnd = DateTime(now.year, now.month, 20);
    } else {
      currentStart = DateTime(now.year, now.month - 1, 21);
      lastStart = DateTime(now.year, now.month - 2, 21);
      lastEnd = DateTime(now.year, now.month - 1, 20);
    }

    final currentPayrollSub = '${DateFormat('dd MMM').format(currentStart)} - Today';
    final lastPayrollSub = '${DateFormat('dd MMM').format(lastStart)} - ${DateFormat('dd MMM').format(lastEnd)}';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handlebar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Period',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF111827), letterSpacing: -0.5),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 20, color: Color(0xFF6B7280)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Payroll Section - Horizontal Cards
              const Text('PAYROLL CYCLES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF), letterSpacing: 1.2)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildPayrollCard(
                      'Current Payroll',
                      currentPayrollSub,
                      _filterLabel == 'Current Payroll',
                      () {
                        _setCurrentPayroll();
                        _loadAttendanceHistory();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPayrollCard(
                      'Last Payroll',
                      lastPayrollSub,
                      _filterLabel == 'Last Payroll',
                      () {
                        _setLastPayroll();
                        _loadAttendanceHistory();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Calendar Months Section
              const Text('CALENDAR MONTHS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF), letterSpacing: 1.2)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMonthChip('This Month', _filterLabel == 'This Month', () {
                      _setCurrentMonth();
                      _loadAttendanceHistory();
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMonthChip('Last Month', _filterLabel == 'Last Month', () {
                      _setLastMonth();
                      _loadAttendanceHistory();
                    }),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Custom Range Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _selectDateRange();
                  },
                  icon: const Icon(Icons.date_range_outlined, color: Colors.white, size: 20),
                  label: const Text(
                    'Select Custom Range',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF9CA3AF),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildPayrollCard(String title, String dateRange, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
          ] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.payment_outlined,
              color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF6B7280),
              size: 20,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF374151)),
            ),
            const SizedBox(height: 4),
            Text(
              dateRange,
              style: TextStyle(fontSize: 11, color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.7) : const Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthChip(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3F4F6) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB)),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF4B5563)),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _filterLabel = '${DateFormat('MMM dd').format(picked.start)} - ${DateFormat('MMM dd').format(picked.end)}';
      });
      _loadAttendanceHistory();
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '-';
    return DateFormat('hh:mm a').format(time);
  }

  Color _getDateColor(Map<String, dynamic> record) {
    // Check if this is joining date
    if (widget.employeeJoiningDate != null) {
      final recordDate = record['date'] as DateTime;
      final joiningDate = DateTime(
        widget.employeeJoiningDate!.year,
        widget.employeeJoiningDate!.month,
        widget.employeeJoiningDate!.day,
      );
      final normalizedRecordDate = DateTime(recordDate.year, recordDate.month, recordDate.day);
      
      if (normalizedRecordDate.isAtSameMomentAs(joiningDate)) {
        return const Color(0xFF10B981); // Green - Joining Date
      }
    }
    
    if (record['is_holiday'] == true) {
      return const Color(0xFF10B981); // Green - Holiday
    } else if (!record['is_present']) {
      return const Color(0xFFEF4444); // Red - Absent
    } else if (record['is_late']) {
      return const Color(0xFFF59E0B); // Orange - Late
    } else {
      return const Color(0xFF10B981); // Green - On Time
    }
  }

  Color _getCheckoutColor(DateTime? checkoutTime) {
    if (checkoutTime == null) return const Color(0xFF374151);
    
    final hour = checkoutTime.hour;
    final minute = checkoutTime.minute;
    
    // Early if before 6:30 PM
    if (hour < 18 || (hour == 18 && minute < 30)) {
      return const Color(0xFFF59E0B); // Orange
    }
    return const Color(0xFF374151); // Grey
  }

  void _viewSelfie(String? selfieUrl, String? collectionId, String? recordId) {
    if (selfieUrl == null || selfieUrl.isEmpty) return;
    
    final fullUrl = '${PB.pb.baseUrl}/api/files/$collectionId/$recordId/$selfieUrl';
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Attendance Selfie',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                    child: Image.network(
                      fullUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Padding(
                          padding: EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
                              SizedBox(height: 16),
                              Text('Failed to load image'),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactMetric(String label, String count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 32,
      width: 1,
      color: const Color(0xFFE5E7EB),
    );
  }

  Future<void> _showRemarkDialog(Map<String, dynamic> record, String status) async {
    final remarkController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Mark as $status', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add mandatory remarks for ${widget.employeeName}', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                const SizedBox(height: 16),
                TextFormField(
                  controller: remarkController,
                  maxLines: 3,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Enter reason/remarks...',
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Remarks are mandatory' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
            ),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (formKey.currentState!.validate()) {
                  setDialogState(() => isSaving = true);
                  try {
                    final bhName = PB.pb.authStore.record?.data['employee_name'] ?? 'Unknown BH';
                    await AttendanceService.updateAttendanceStatus(
                      recordId: record['record_id'],
                      status: status,
                      remarks: remarkController.text.trim(),
                      approvedBy: bhName,
                      approvalDate: DateTime.now().toUtc().toIso8601String(),
                    );
                    if (mounted) {
                      Navigator.pop(context);
                      _loadAttendanceHistory(); // Refresh list
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Attendance marked as $status'), backgroundColor: const Color(0xFF10B981)),
                      );
                    }
                  } catch (e) {
                    setDialogState(() => isSaving = false);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionDialog(Map<String, dynamic> record) {
    // Determine current status & remarks
    final String status = (record['status']?.toString() ?? '').trim().isEmpty ? '' : record['status'].toString();
    final String remarks = (record['remarks']?.toString() ?? '').trim();
    final bool hasRemarks = remarks.isNotEmpty;

    // Determine badge style
    Color badgeBg = Colors.amber.withOpacity(0.1);
    Color badgeText = const Color(0xFFB45309);
    String displayStatus = 'Approval Pending';

    if (status == 'Full-day' || status == 'Present') {
      badgeBg = const Color(0xFF10B981).withOpacity(0.1);
      badgeText = const Color(0xFF10B981);
      displayStatus = status;
    } else if (status == 'Half-day') {
      badgeBg = const Color(0xFFFCE7F3); // Pink BG 
      badgeText = const Color(0xFFEF4444); // Red Text
      displayStatus = status;
    } else if (status == 'Absent') {
      badgeBg = const Color(0xFFEF4444).withOpacity(0.1);
      badgeText = const Color(0xFFEF4444);
      displayStatus = status;
    } else if (status == 'Leave') {
      badgeBg = const Color(0xFF10B981).withOpacity(0.1);
      badgeText = const Color(0xFF10B981);
      displayStatus = status;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(_formatDate(record['date']), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                displayStatus,
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold, 
                  color: badgeText,
                ),
              ),
            ),
            if (hasRemarks) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                ),
                child: Text(remarks, style: const TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.4)),
              ),
            ],
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionItem(
              icon: Icons.check_circle_outline,
              color: const Color(0xFF10B981),
              label: 'Mark as Full-day',
              onTap: () {
                Navigator.pop(context);
                if (record['record_id'] == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No attendance record to certify')));
                  return;
                }
                _showRemarkDialog(record, 'Full-day');
              },
            ),
            _buildActionItem(
              icon: Icons.timelapse,
              color: const Color(0xFFF59E0B),
              label: 'Mark as Half-day',
              onTap: () {
                Navigator.pop(context);
                if (record['record_id'] == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No attendance record to certify')));
                  return;
                }
                _showRemarkDialog(record, 'Half-day');
              },
            ),
            _buildActionItem(
              icon: Icons.block,
              color: const Color(0xFFEF4444),
              label: 'Mark as Absent',
              onTap: () {
                Navigator.pop(context);
                if (record['record_id'] == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No attendance record to certify')));
                  return;
                }
                _showRemarkDialog(record, 'Absent');
              },
            ),
            _buildActionItem(
              icon: Icons.beach_access_outlined,
              color: const Color(0xFF3B82F6),
              label: 'Mark as Leave',
              onTap: () {
                Navigator.pop(context);
                if (record['record_id'] == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No attendance record to certify')));
                  return;
                }
                _showRemarkDialog(record, 'Leave');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRow(Map<String, dynamic> record) {
    final dateColor = _getDateColor(record);
    
    return InkWell(
      onTap: () => _showActionDialog(record),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Date
              SizedBox(
                width: 60,
                child: Text(
                  _formatDate(record['date']),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: dateColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Check-in
              Expanded(
                flex: 2,
                child: Builder(
                  builder: (context) {
                    // Check if this is joining date
                    bool isJoiningDate = false;
                    if (widget.employeeJoiningDate != null) {
                      final recordDate = record['date'] as DateTime;
                      final joiningDate = DateTime(
                        widget.employeeJoiningDate!.year,
                        widget.employeeJoiningDate!.month,
                        widget.employeeJoiningDate!.day,
                      );
                      final normalizedRecordDate = DateTime(recordDate.year, recordDate.month, recordDate.day);
                      isJoiningDate = normalizedRecordDate.isAtSameMomentAs(joiningDate);
                    }
                    
                    if (isJoiningDate) {
                      return Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Joined',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const SizedBox(width: 26), // Invisible spacer
                        ],
                      );
                    } else if (record['is_holiday'] == true) {
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              record['holiday_name'] ?? 'Holiday',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const SizedBox(width: 26), // Invisible spacer for icon width
                        ],
                      );
                    } else if (record['check_in_selfie'] != null && record['check_in_time'] != null) {
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              _formatTime(record['check_in_time']),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: record['is_late'] ? const Color(0xFFF59E0B) : const Color(0xFF374151),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _viewSelfie(
                              record['check_in_selfie'],
                              record['collection_id'],
                              record['record_id'],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9CA3AF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              _formatTime(record['check_in_time']),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: record['is_late'] ? const Color(0xFFF59E0B) : const Color(0xFF374151),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const SizedBox(width: 26),
                        ],
                      );
                    }
                  },
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Check-out
              Expanded(
                flex: 2,
                child: record['is_holiday'] == true
                    ? Row(
                        children: [
                          const Expanded(
                            child: Text(
                              '-',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9CA3AF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const SizedBox(width: 26), // Invisible spacer for icon width
                        ],
                      )
                    : (record['check_out_selfie'] != null && record['check_out_time'] != null)
                    ? Row(
                        children: [
                          Expanded(
                            child: Text(
                              _formatTime(record['check_out_time']),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: _getCheckoutColor(record['check_out_time']),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _viewSelfie(
                              record['check_out_selfie'],
                              record['collection_id'],
                              record['record_id'],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9CA3AF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: Text(
                              _formatTime(record['check_out_time']),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: _getCheckoutColor(record['check_out_time']),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const SizedBox(width: 26),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.employeeName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${DateFormat('dd-MMM-yy').format(_startDate)} to ${DateFormat('dd-MMM-yy').format(_endDate)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF9CA3AF),
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
            icon: const Icon(Icons.calendar_month, size: 22, color: Color(0xFF3B82F6)),
            onPressed: _showFilterModal,
            tooltip: 'Filter',
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
          : _attendanceRecords.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.employeeJoiningDate != null && 
                        _endDate.isBefore(widget.employeeJoiningDate!)
                            ? 'Employee joined on ${DateFormat('dd-MMM-yy').format(widget.employeeJoiningDate!)}'
                            : 'No attendance records found',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (widget.employeeJoiningDate != null && 
                          _endDate.isBefore(widget.employeeJoiningDate!))
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Selected date range is before joining date',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Summary Card
                    Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCompactMetric(
                            'Total',
                            _attendanceRecords.length.toString(),
                            const Color(0xFF3B82F6),
                          ),
                          _buildDivider(),
                          _buildCompactMetric(
                            'Holiday',
                            _attendanceRecords.where((r) => r['is_holiday'] == true).length.toString(),
                            const Color(0xFF8B5CF6),
                          ),
                          _buildDivider(),
                          _buildCompactMetric(
                            'Present',
                            _attendanceRecords.where((r) => r['is_present'] == true && r['is_late'] == false).length.toString(),
                            const Color(0xFF10B981),
                          ),
                          _buildDivider(),
                          _buildCompactMetric(
                            'Absent',
                            _attendanceRecords.where((r) => r['is_present'] == false && r['is_holiday'] != true).length.toString(),
                            const Color(0xFFEF4444),
                          ),
                          _buildDivider(),
                          _buildCompactMetric(
                            'Late',
                            _attendanceRecords.where((r) => r['is_late'] == true).length.toString(),
                            const Color(0xFFF59E0B),
                          ),
                        ],
                      ),
                    ),
                    
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: const BoxDecoration(
                        color: Color(0xFF3B82F6),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 60,
                            child: Text(
                              'Date',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Check-in',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.95),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Check-out',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.95),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Attendance List
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadAttendanceHistory,
                        color: const Color(0xFF3B82F6),
                        child: ListView.builder(
                          itemCount: _attendanceRecords.length,
                          itemBuilder: (context, index) {
                            return _buildAttendanceRow(_attendanceRecords[index]);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
