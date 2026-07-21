import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/leave_service.dart';
import '../core/pb_api.dart';

class LeaveManagementScreen extends StatefulWidget {
  const LeaveManagementScreen({super.key});

  @override
  State<LeaveManagementScreen> createState() => _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends State<LeaveManagementScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allRequests = [];
  String _selectedStatus = 'All';
  bool _showOlder = false;
  final bool _hasBHAccess = PB.pb.authStore.record?.data['bh_access'] == true;
  final String _currentUserName = PB.pb.authStore.record?.data['employee_name'] ?? 'Manager';

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    try {
      final requests = await LeaveService.getAllLeaveRequests();
      
      // Smart Sort: Pending first, then by date descending
      requests.sort((a, b) {
        final aStatus = (a['status'] ?? 'pending').toString().toLowerCase();
        final bStatus = (b['status'] ?? 'pending').toString().toLowerCase();
        
        if (aStatus == 'pending' && bStatus != 'pending') return -1;
        if (aStatus != 'pending' && bStatus == 'pending') return 1;
        
        DateTime aDate = DateTime.tryParse(a['applied_date'] ?? '') ?? DateTime(0);
        DateTime bDate = DateTime.tryParse(b['applied_date'] ?? '') ?? DateTime(0);
        return bDate.compareTo(aDate);
      });

      setState(() {
        _allRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(e.toString());
      }
    }
  }

  List<Map<String, dynamic>> get _filteredRequests {
    if (_selectedStatus == 'All') return _allRequests;
    return _allRequests.where((req) => (req['status'] ?? 'pending').toString().toLowerCase() == _selectedStatus.toLowerCase()).toList();
  }

  Future<void> _handleApprove(Map<String, dynamic> request) async {
    final employeeName = request['employee_name'] ?? 'Employee';
    final leaveType = request['leave_type'] ?? 'Paid';
    final daysCount = request['days_count'] ?? 0;
    final employeeId = request['user'];

    String? warning;
    
    // Check balance if it's Paid leave
    if (leaveType == 'Paid') {
      try {
        final userRecord = await PB.pb.collection('users').getOne(employeeId);
        final currentBalance = (userRecord.data['paid_leave_balance'] ?? 0) as num;
        
        if (currentBalance < daysCount) {
          warning = 'Employee $employeeName has only ${currentBalance.toInt()} Paid leaves left, but is applying for $daysCount days. Approve anyway?';
        }
      } catch (_) {
        // Silently skip balance check if it fails
      }
    }

    final bool? proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(warning != null ? 'Warning: Low Balance' : 'Approve Leave'),
        content: Text(warning ?? 'Are you sure you want to approve leave for $employeeName?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: warning != null ? Colors.orange : Colors.green, 
              foregroundColor: Colors.white
            ),
            child: Text(warning != null ? 'Yes, Approve' : 'Approve'),
          ),
        ],
      ),
    );

    if (proceed != true) return;

    setState(() => _isLoading = true);
    try {
      await LeaveService.approveLeaveRequest(
        requestId: request['id'],
        employeeId: request['user'],
        daysCount: request['days_count'],
        leaveType: request['leave_type'],
        approverName: _currentUserName,
      );
      await _fetchRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text('Leave Approved Successfully', style: TextStyle(color: Colors.white))),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(e.toString());
      }
    }
  }

  Future<void> _handleReject(Map<String, dynamic> request) async {
    final reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Leave'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Why are you rejecting leave for ${request['employee_name']}?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a reason')),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await LeaveService.rejectLeaveRequest(
        requestId: request['id'],
        reason: reasonController.text.trim(),
        approverName: _currentUserName,
      );
      await _fetchRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text('Leave Rejected Successfully', style: TextStyle(color: Colors.white))),
              ],
            ),
            backgroundColor: const Color(0xFFF59E0B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(e.toString());
      }
    }
  }

  void _showError(String message) {
    final cleanMsg = message.replaceFirst('Exception: ', '').replaceFirst('Exception', '');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(cleanMsg, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRequests;
    
    // Partitioning: Current Month / Pending vs Older
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);
    
    final currentRequests = filtered.where((r) {
      final status = (r['status'] ?? 'pending').toString().toLowerCase();
      if (status == 'pending') return true;
      final fromDate = DateTime.tryParse(r['from_date'] ?? '') ?? DateTime(0);
      final toDate = DateTime.tryParse(r['to_date'] ?? '') ?? DateTime(0);
      // Fall in current month or future months
      return fromDate.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) || 
             toDate.isAfter(startOfMonth.subtract(const Duration(seconds: 1)));
    }).toList();

    final olderRequests = filtered.where((r) => !currentRequests.contains(r)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Leave Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedStatus,
                  items: ['All', 'Pending', 'Approved', 'Rejected'].map((String val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(
                        val, 
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6))
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newVal) {
                    if (newVal != null) {
                      setState(() {
                        _selectedStatus = newVal;
                        _showOlder = false; // Reset older toggle when filter changes
                      });
                    }
                  },
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF3B82F6)),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6)),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : filtered.isEmpty
              ? Center(child: Text('No $_selectedStatus requests found'))
              : RefreshIndicator(
                  onRefresh: _fetchRequests,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      // Current Section
                      ...currentRequests.map((req) => _buildLeaveCard(req)),
                      
                      // Older Section Toggle
                      if (olderRequests.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Divider(height: 32, color: Color(0xFFE2E8F0)),
                        Center(
                          child: TextButton.icon(
                            onPressed: () => setState(() => _showOlder = !_showOlder),
                            icon: Icon(_showOlder ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                            label: Text(
                              _showOlder ? 'Hide Older Leaves' : 'View Older Leaves',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_showOlder)
                          ...olderRequests.map((req) => _buildLeaveCard(req)),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildLeaveCard(Map<String, dynamic> req) {
    final status = (req['status'] ?? 'pending').toString().toLowerCase();
    DateTime fromDate;
    DateTime toDate;
    try {
      fromDate = DateTime.parse(req['from_date'] ?? DateTime.now().toIso8601String());
      toDate = DateTime.parse(req['to_date'] ?? DateTime.now().toIso8601String());
    } catch (_) {
      fromDate = DateTime.now();
      toDate = DateTime.now();
    }
    final isPending = status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${req['employee_name'] ?? 'Unknown'} - ${req['employee_code'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Applied on: ${_safeDateFormat(req['applied_date'])}',
                        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem('Duration', 
                      '${DateFormat('dd MMM').format(fromDate)} - ${DateFormat('dd MMM').format(toDate)}'),
                    Text(
                      '${req['days_count']} Days',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Type: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    Text(
                      req['leave_type'] ?? 'Paid',
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.w600, 
                        color: (req['leave_type'] == 'Paid' ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Reason: ',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                      ),
                      TextSpan(
                        text: req['reason'] ?? 'No reason provided',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                      ),
                    ],
                  ),
                ),
                
                if (status == 'rejected' && req['rejection_reason'] != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9), 
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            req['rejection_reason'].toString(),
                            style: const TextStyle(
                              fontSize: 12, 
                              color: Color(0xFF475569), 
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                if (!isPending && req['approved_by'] != null) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ),
                  Text(
                    '${status == 'approved' ? 'Approved' : (status == 'rejected' ? 'Rejected' : 'Actioned')} by: ${req['approved_by']}${req['decision_date'] != null ? ' on ${_safeDateFormat(req['decision_date'].toString())}' : ''}',
                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF64748B)),
                  ),
                ],
              ],
            ),
          ),

          // Actions
          if (isPending && _hasBHAccess) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => _handleReject(req),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleApprove(req),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _safeDateFormat(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      return DateFormat('dd-MMM').format(DateTime.parse(dateStr));
    } catch (_) {
      return '';
    }
  }

  Widget _buildInfoItem(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case 'approved':
        bgColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF10B981);
        icon = Icons.check_circle_outline;
        break;
      case 'rejected':
        bgColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFEF4444);
        icon = Icons.cancel_outlined;
        break;
      default:
        bgColor = const Color(0xFFFFF7ED);
        textColor = const Color(0xFFF59E0B);
        icon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.isEmpty ? '' : (status[0].toUpperCase() + status.substring(1)),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }
}
