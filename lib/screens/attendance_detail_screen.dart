import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/attendance_service.dart';
import '../core/pb_api.dart';
import 'employee_attendance_history_screen.dart';

class AttendanceDetailScreen extends StatefulWidget {
  const AttendanceDetailScreen({super.key});

  @override
  State<AttendanceDetailScreen> createState() => _AttendanceDetailScreenState();
}

class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _attendanceRecords = [];
  List<Map<String, dynamic>> _officeEmployees = [];
  List<Map<String, dynamic>> _wfhEmployees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() => _isLoading = true);
    
    try {
      final records = await AttendanceService.getManagerDetailedAttendance(_selectedDate);
      
      // Separate WFH and Office employees
      final office = <Map<String, dynamic>>[];
      final wfh = <Map<String, dynamic>>[];
      
      for (var record in records) {
        if (record['wfh'] == true) {
          wfh.add(record);
        } else {
          office.add(record);
        }
      }
      
      if (mounted) {
        setState(() {
          _attendanceRecords = records;
          _officeEmployees = office;
          _wfhEmployees = wfh;
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

  void _showDatePicker() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Divider(),
              ...List.generate(3, (index) {
                final date = today.subtract(Duration(days: index));
                final label = index == 0 ? 'Today' : index == 1 ? 'Yesterday' : DateFormat('EEEE, MMM dd').format(date);
                final isSelected = _isSameDay(date, _selectedDate);
                return ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(label, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? const Color(0xFF3B82F6) : null)),
                  trailing: isSelected ? const Icon(Icons.check, size: 18, color: Color(0xFF3B82F6)) : null,
                  onTap: () {
                    setState(() => _selectedDate = date);
                    Navigator.pop(context);
                    _loadAttendance();
                  },
                );
              }),
              const Divider(),
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: const Icon(Icons.calendar_month, size: 20, color: Color(0xFF3B82F6)),
                title: const Text('Custom Date', style: TextStyle(fontSize: 14, color: Color(0xFF3B82F6), fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() => _selectedDate = pickedDate);
                    _loadAttendance();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '-';
    return DateFormat('hh:mm a').format(time);
  }

  Color _getNameColor(Map<String, dynamic> record) {
    if (!record['is_present']) {
      return const Color(0xFFEF4444); // Red - Absent
    } else if (record['is_late']) {
      return const Color(0xFFF59E0B); // Orange - Late
    } else {
      return const Color(0xFF10B981); // Green - On Time
    }
  }

  IconData _getStatusIcon(Map<String, dynamic> record) {
    if (!record['is_present']) {
      return Icons.cancel_outlined;
    } else if (record['is_late']) {
      return Icons.access_time;
    } else {
      return Icons.check_circle_outline;
    }
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

  Widget _buildEmployeeGroup(String title, List<Map<String, dynamic>> employees, IconData icon) {
    if (employees.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFFF9FAFB),
            border: Border(
              bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${employees.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ),
            ],
          ),
        ),
        ...employees.asMap().entries.map((entry) {
          final index = entry.key;
          final record = entry.value;
          return _buildEmployeeRow(index + 1, record);
        }),
      ],
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
                Text('Add mandatory remarks for ${record['employee_name']}', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
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
                      _loadAttendance(); // Refresh list
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
      badgeBg = const Color(0xFFFCE7F3); // Excel-like Pink BG
      badgeText = const Color(0xFFEF4444); // Red Text
      displayStatus = status;
    } else if (status == 'Absent') {
      badgeBg = const Color(0xFFEF4444).withOpacity(0.1);
      badgeText = const Color(0xFFEF4444);
      displayStatus = status;
    } else if (status == 'Leave') {
      badgeBg = const Color(0xFF10B981).withOpacity(0.1); // Green Badge as requested
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
            Text(record['employee_name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              icon: Icons.history,
              color: const Color(0xFF6B7280),
              label: 'View Month Attendance',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmployeeAttendanceHistoryScreen(
                      employeeCode: record['employee_code'],
                      employeeName: record['employee_name'],
                      employeeJoiningDate: record['date_of_joining'] != null 
                          ? DateTime.parse(record['date_of_joining'].toString())
                          : null,
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            _buildActionItem(
              icon: Icons.check_circle_outline,
              color: const Color(0xFF10B981),
              label: 'Mark as Full-day',
              onTap: () {
                Navigator.pop(context);
                if (record['record_id'] == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No record found')));
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No record found')));
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No record found')));
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No record found')));
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

  Widget _buildEmployeeRow(int sNo, Map<String, dynamic> record) {
    final nameColor = _getNameColor(record);
    // Be very careful with status parsing from map
    final dynamic rawStatus = record['status'];
    final String status = (rawStatus == null || rawStatus.toString().trim().isEmpty) ? 'Pending' : rawStatus.toString();
    
    final isApproved = status == 'Full-day' || status == 'Present';
    final isRejected = status == 'Absent';
    final isSpecial = status == 'Half-day' || status == 'Leave';
    
    Color stripColor = const Color(0xFFD1D5DB);
    if (isApproved) stripColor = const Color(0xFF10B981);
    if (isRejected) stripColor = const Color(0xFFEF4444);
    if (isSpecial) stripColor = const Color(0xFF3B82F6);

    return InkWell(
      onTap: () => _showActionDialog(record),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
        ),
        child: Row(
          children: [
            Container(width: 4, height: 60, color: stripColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Row(
                  children: [
                    SizedBox(width: 28, child: Text('$sNo.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500))),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: Text(
                        record['employee_name'],
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: nameColor, height: 1.2),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Check-in
                    Expanded(
                      flex: 2,
                      child: record['check_in_selfie'] != null
                          ? Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Expanded(child: Text(_formatTime(record['check_in_time']), textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: record['is_late'] ? const Color(0xFFF59E0B) : const Color(0xFF374151), fontWeight: FontWeight.w500))),
                                 const SizedBox(width: 4),
                                 GestureDetector(
                                   onTap: () => _viewSelfie(record['check_in_selfie'], record['collection_id'], record['record_id']),
                                   child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFF9CA3AF).withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.camera_alt, size: 18, color: Color(0xFF9CA3AF))),
                                 ),
                               ],
                             )
                          : Text(_formatTime(record['check_in_time']), textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: record['is_late'] ? const Color(0xFFF59E0B) : const Color(0xFF374151), fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(width: 12),
                    // Check-out
                    Expanded(
                      flex: 2,
                      child: (record['check_out_selfie'] != null && record['check_out_time'] != null)
                          ? Row(
                               children: [
                                 Expanded(
                                   child: Builder(builder: (context) {
                                     bool isEarlyCheckout = false;
                                     if (record['check_out_time'] != null) {
                                       final checkOutTime = record['check_out_time'] as DateTime;
                                       isEarlyCheckout = checkOutTime.hour < 18 || (checkOutTime.hour == 18 && checkOutTime.minute < 30);
                                     }
                                     return Text(_formatTime(record['check_out_time']), textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: isEarlyCheckout ? const Color(0xFFF59E0B) : const Color(0xFF374151), fontWeight: FontWeight.w500));
                                   }),
                                 ),
                                 const SizedBox(width: 6),
                                 GestureDetector(
                                   onTap: () => _viewSelfie(record['check_out_selfie'], record['collection_id'], record['record_id']),
                                   child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFF9CA3AF).withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.camera_alt, size: 18, color: Color(0xFF9CA3AF))),
                                 ),
                               ],
                             )
                          : Text(_formatTime(record['check_out_time']), textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: const Color(0xFF374151), fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _isSameDay(_selectedDate, DateTime.now())
        ? 'Today'
        : DateFormat('MMM dd, yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Attendance - $dateStr',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, size: 22, color: Color(0xFF3B82F6)),
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
          : _attendanceRecords.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No employees found',
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
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: const BoxDecoration(
                        color: Color(0xFF3B82F6),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 28), // S.No space
                          const SizedBox(width: 8),
                          const Expanded(
                            flex: 3,
                            child: Text(
                              'Employee',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Check-in',
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
                    
                    // Employee List
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadAttendance,
                        color: const Color(0xFF3B82F6),
                        child: ListView(
                          children: [
                            // Office employees (no header)
                            ..._officeEmployees.asMap().entries.map((entry) {
                              final index = entry.key;
                              final record = entry.value;
                              return _buildEmployeeRow(index + 1, record);
                            }),
                            
                            // WFH employees (with header)
                            if (_wfhEmployees.isNotEmpty)
                              _buildEmployeeGroup(
                                'WORK FROM HOME',
                                _wfhEmployees,
                                Icons.home,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
