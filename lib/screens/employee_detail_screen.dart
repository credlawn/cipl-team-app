import 'package:flutter/material.dart';
import '../core/pb_api.dart';
import 'edit_employee_screen.dart';
import 'bh_edit_employee_screen.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> employee;

  const EmployeeDetailScreen({
    super.key,
    required this.employee,
  });

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  late Map<String, dynamic> _employee;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _employee = Map<String, dynamic>.from(widget.employee);
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    try {
      final record = await PB.pb.collection('users').getOne(_employee['id']);
      if (mounted) {
        setState(() {
          _employee = record.toJson();
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRefreshing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to refresh data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasBHAccess = PB.pb.authStore.record?.data['bh_access'] == true;
    final designation = (_employee['designation'] ?? '').toString();
    
    final name = (_employee['employee_name'] ?? 'Unknown').toString();
    final code = (_employee['employee_code'] ?? '').toString();
    final mobile = (_employee['mobile_no'] ?? '').toString();
    final email = (_employee['email'] ?? '').toString();
    final department = (_employee['department'] ?? '').toString();
    final vertical = (_employee['vertical'] ?? '').toString();
    final wfh = _employee['wfh'] == true;
    final disabled = _employee['disabled'] == true;
    final noAtn = _employee['no_atn'] == true;
    final leaveBalance = _employee['paid_leave_balance']?.toString() ?? '0';

    final isTrainee = !disabled && designation == 'Trainee';
    final isPending = disabled && (_employee['last_working_date'] == null || _employee['last_working_date'].toString().isEmpty);
    
    final title = (designation == 'Trainee' || isPending) ? 'Trainee Details' : 'Employee Details';
    final canEdit = hasBHAccess || isTrainee || isPending;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        actions: [
          if (_isRefreshing)
            const Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3B82F6))))),
          if (canEdit)
            IconButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => hasBHAccess 
                        ? BHEditEmployeeScreen(employee: _employee)
                        : EditEmployeeScreen(employee: _employee),
                  ),
                );
                if (result == true) {
                  _refreshData();
                }
              },
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF3B82F6)),
              ),
              tooltip: 'Edit Employee',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: disabled ? Colors.grey.withOpacity(0.2) : const Color(0xFF3B82F6).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: disabled ? Colors.grey[600] : const Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: [
                        if (code.isNotEmpty) _buildBadge(code, const Color(0xFF6B7280), Colors.white),
                        if (wfh) _buildBadge('WFH', const Color(0xFF10B981), Colors.white),
                        if (disabled) _buildBadge('Disabled', const Color(0xFFEF4444), Colors.white),
                        if (noAtn) _buildBadge('No ATN', const Color(0xFFFF9800), Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
  
              // Info Sections
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoCard('Contact', [
                      if (mobile.isNotEmpty) _buildInfoRow(Icons.phone_outlined, 'Mobile', mobile),
                      if (email.isNotEmpty) _buildInfoRow(Icons.email_outlined, 'Email', email),
                    ]),
                    
                    const SizedBox(height: 12),
                    _buildInfoCard('Work', [
                      if (designation.isNotEmpty) _buildInfoRow(Icons.work_outline, 'Designation', designation),
                      if (department.isNotEmpty) _buildInfoRow(Icons.business_outlined, 'Department', department),
                      if (vertical.isNotEmpty) _buildInfoRow(Icons.category_outlined, 'Vertical', vertical),
                    ]),
                    
                    const SizedBox(height: 12),
                    _buildInfoCard('Personal', [
                      if (_employee['date_of_birth'] != null) _buildInfoRow(Icons.cake_outlined, 'Date of Birth', _formatDate(_employee['date_of_birth'])),
                      if (_employee['date_of_joining'] != null) _buildInfoRow(Icons.event_outlined, 'Training Start', _formatDate(_employee['date_of_joining'])),
                    ]),
                    
                    if (hasBHAccess) ...[
                      const SizedBox(height: 12),
                      _buildInfoCard('BH Only', [
                        _buildInfoRow(Icons.event_available, 'Leave Balance', leaveBalance),
                        _buildInfoRow(Icons.currency_rupee, 'In Hand Salary', _employee['salary']?.toString() ?? '0'),
                        if (_employee['payroll_start_date'] != null) _buildInfoRow(Icons.payments_outlined, 'Payroll Start', _formatDate(_employee['payroll_start_date'])),
                        if (_employee['last_working_date'] != null) _buildInfoRow(Icons.event_busy, 'Last Working', _formatDate(_employee['last_working_date'])),
                      ]),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: text)),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6B7280), letterSpacing: 0.8)),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF3F4F6)))),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF111827))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null || dateStr.toString().isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr.toString());
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr.toString();
    }
  }
}
