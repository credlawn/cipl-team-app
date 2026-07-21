import 'package:flutter/material.dart';
import '../services/employee_service.dart';
import '../widgets/hr/employee_card.dart';
import '../widgets/hr/approve_employee_dialog.dart';
import '../widgets/hr/confirm_trainee_dialog.dart';
import '../widgets/hr/reject_trainee_dialog.dart';
import 'add_employee_screen.dart';
import 'employee_detail_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _officeEmployees = [];
  List<Map<String, dynamic>> _wfhEmployees = [];
  List<Map<String, dynamic>> _traineeEmployees = [];
  List<Map<String, dynamic>> _pendingEmployees = [];
  List<Map<String, dynamic>> _disabledEmployees = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.index = 1; // Default to 'Training' tab (now at index 1)
    _loadEmployees();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    
    try {
      final office = await EmployeeService.getOfficeEmployees();
      final wfh = await EmployeeService.getWFHEmployees();
      final trainee = await EmployeeService.getTraineeEmployees();
      final pending = await EmployeeService.getPendingEmployees();
      final disabled = await EmployeeService.getDisabledEmployees();
      
      if (mounted) {
        setState(() {
          _officeEmployees = office;
          _wfhEmployees = wfh;
          _traineeEmployees = trainee;
          _pendingEmployees = pending;
          _disabledEmployees = disabled;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    e.toString().replaceAll('Exception: ', ''),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> _navigateToAddEmployee() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEmployeeScreen()),
    );
    
    if (result == true) {
      _loadEmployees(); // Refresh list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'HR Management',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Manage your team records',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF64748B)),
        actions: [
          IconButton(
            onPressed: _navigateToAddEmployee,
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Color(0xFF3B82F6), size: 20),
            ),
            tooltip: 'Add Employee',
          ),
          const SizedBox(width: 12),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF3B82F6),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF3B82F6),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          tabs: [
            _buildTab('Pending', _pendingEmployees.length),
            _buildTab('Training', _traineeEmployees.length),
            _buildTab('Office', _officeEmployees.length),
            _buildTab('WFH', _wfhEmployees.length),
            _buildTab('Disabled', _disabledEmployees.length),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildEmployeeList(_pendingEmployees, 'pending'),
                _buildEmployeeList(_traineeEmployees, 'trainee'),
                _buildEmployeeList(_officeEmployees, 'office'),
                _buildEmployeeList(_wfhEmployees, 'wfh'),
                _buildEmployeeList(_disabledEmployees, 'disabled'),
              ],
            ),
    );
  }

  Widget _buildTab(String label, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (!_isLoading) ...[
            const SizedBox(width: 6),
            Text(
              '($count)',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmployeeList(List<Map<String, dynamic>> employees, String type) {
    if (employees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyIcon(type),
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyTitle(type),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptySubtitle(type),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEmployees,
      color: const Color(0xFF3B82F6),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: employees.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return EmployeeCard(
            employee: employees[index],
            isDisabled: type == 'disabled',
            isPending: type == 'pending',
            isTrainee: type == 'trainee',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EmployeeDetailScreen(employee: employees[index]),
                ),
              );
            },
            onApprove: type == 'pending' ? () async {
              final result = await showDialog(
                context: context,
                builder: (_) => ApproveEmployeeDialog(employee: employees[index]),
              );
              if (result == true) {
                _loadEmployees(); // Refresh list after approval
              }
            } : null,
            onConfirm: type == 'trainee' ? () async {
              final result = await showDialog(
                context: context,
                builder: (_) => ConfirmTraineeDialog(employee: employees[index]),
              );
              if (result == true) {
                _loadEmployees(); // Refresh list after confirmation
              }
            } : null,
            onReject: type == 'trainee' ? () async {
              final result = await showDialog(
                context: context,
                builder: (_) => RejectTraineeDialog(employee: employees[index]),
              );
              if (result == true) {
                _loadEmployees(); // Refresh list after rejection
              }
            } : null,
          );
        },
      ),
    );
  }

  IconData _getEmptyIcon(String type) {
    switch (type) {
      case 'office':
        return Icons.business_outlined;
      case 'wfh':
        return Icons.home_outlined;
      case 'trainee':
        return Icons.school_outlined;
      case 'pending':
        return Icons.pending_outlined;
      case 'disabled':
        return Icons.person_off_outlined;
      default:
        return Icons.people_outline;
    }
  }

  String _getEmptyTitle(String type) {
    switch (type) {
      case 'office':
        return 'No office employees';
      case 'wfh':
        return 'No WFH employees';
      case 'trainee':
        return 'No trainee employees';
      case 'pending':
        return 'No pending employees';
      case 'disabled':
        return 'No disabled employees';
      default:
        return 'No employees';
    }
  }

  String _getEmptySubtitle(String type) {
    switch (type) {
      case 'office':
        return 'Employees working from office will appear here';
      case 'wfh':
        return 'Employees working from home will appear here';
      case 'trainee':
        return 'Employees in training will appear here';
      case 'pending':
        return 'Pending approval employees will appear here';
      case 'disabled':
        return 'Disabled employees will appear here';
      default:
        return 'Add employees to get started';
    }
  }
}
