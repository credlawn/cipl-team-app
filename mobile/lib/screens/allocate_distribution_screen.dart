import 'package:flutter/material.dart';
import '../services/leads_analytics_service.dart';
import '../services/employee_presence_service.dart';
import '../services/database_service.dart';
import '../models/employee_performance.dart';

class AllocateDistributionScreen extends StatefulWidget {
  final String mode; // "allocate" or "reallocate"
  final List<Map<String, dynamic>> selections;
  final int totalCount;

  const AllocateDistributionScreen({
    super.key,
    required this.mode,
    required this.selections,
    required this.totalCount,
  });

  @override
  State<AllocateDistributionScreen> createState() => _AllocateDistributionScreenState();
}

class _AllocateDistributionScreenState extends State<AllocateDistributionScreen> {
  bool _isLoading = true;
  bool _isAllocating = false;
  List<EmployeePerformance> _employees = [];
  Set<String> _presentEmployeeCodes = {};
  Map<String, TextEditingController> _allocationControllers = {};
  Map<String, int> _maxAvailablePerEmployee = {}; // NEW: Max available for each employee

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    for (var controller in _allocationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);

    try {
      final analyticsData = await LeadsAnalyticsService.getAnalyticsData(filterType: 'today');
      final pivotData = List<Map<String, dynamic>>.from(analyticsData['employees'] ?? []);
      final presenceData = await EmployeePresenceService.getPresentEmployees();

      if (mounted) {
        setState(() {
          _employees = pivotData.map<EmployeePerformance>((data) => EmployeePerformance(
            employeeCode: data['employee_code'] ?? '',
            employeeName: data['employee_name'] ?? '',
            newLeadsCount: data['new'] ?? 0,
            workedLeads: data['worked'] ?? 0,
            totalLeads: data['total'] ?? 0,
            productivity: (data['productivity'] ?? 0).toString(),
            ipa: data['ip_approved'] ?? 0,
            ipd: data['ip_decline'] ?? 0,
            wfh: data['wfh'] ?? false,
            disabled: data['disabled'] ?? false,
            role: data['role'] ?? '',
          )).toList();




          _presentEmployeeCodes = presenceData['all']?.toSet() ?? {};

          // Sort: Present employees first, then absent
          // Within each group, sort by new leads count (low to high)
          _employees.sort((a, b) {
            final aPresent = _presentEmployeeCodes.contains(a.employeeCode);
            final bPresent = _presentEmployeeCodes.contains(b.employeeCode);
            
            if (aPresent != bPresent) {
              return aPresent ? -1 : 1; // Present first
            }
            
            // Then sort by new leads count (low to high)
            return a.newLeadsCount.compareTo(b.newLeadsCount);
          });

          // Initialize controllers
          for (var emp in _employees) {
            _allocationControllers[emp.employeeCode] = TextEditingController();
          }

          _isLoading = false;
        });

        // Load availability for reallocate mode
        if (widget.mode == 'reallocate') {
          _loadAvailability();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading employees: $e')),
        );
      }
    }
  }

  Future<void> _loadAvailability() async {
    try {
      print('🔍 Loading availability for reallocate mode...');
      final result = await DatabaseService.getReallocationAvailability(
        selections: widget.selections,
      );

      print('📊 Availability result: $result');

      if (result['success'] == true && mounted) {
        final breakdown = List<Map<String, dynamic>>.from(result['employee_breakdown'] ?? []);
        
        print('👥 Employee breakdown: $breakdown');
        
        setState(() {
          _maxAvailablePerEmployee = {
            for (var emp in breakdown)
              emp['employee_code'] as String: 
                // Cap at totalCount selected by user
                (emp['max_can_receive'] as int).clamp(0, widget.totalCount)
          };
        });
        
        print('✅ Max available per employee (capped at ${widget.totalCount}): $_maxAvailablePerEmployee');
      }
    } catch (e) {
      print('❌ Error loading availability: $e');
    }
  }

  int get _totalAllocated {
    int total = 0;
    for (var controller in _allocationControllers.values) {
      total += int.tryParse(controller.text) ?? 0;
    }
    return total;
  }

  int get _remaining => widget.totalCount - _totalAllocated;

  void _distributeEqually() {
    final activeEmployees = _employees.where((e) => 
      !e.disabled && 
      _presentEmployeeCodes.contains(e.employeeCode) && 
      e.role.toLowerCase() == 'employee'
    ).toList();



    if (activeEmployees.isEmpty) return;

    final perEmployee = widget.totalCount ~/ activeEmployees.length;
    var remainder = widget.totalCount % activeEmployees.length;

    for (var emp in activeEmployees) {
      final controller = _allocationControllers[emp.employeeCode]!;
      controller.text = (perEmployee + (remainder > 0 ? 1 : 0)).toString();
      if (remainder > 0) remainder--;
    }

    setState(() {});
  }

  void _distributeByWorkload() {
    final activeEmployees = _employees.where((e) => 
      !e.disabled && 
      _presentEmployeeCodes.contains(e.employeeCode) && 
      e.role.toLowerCase() == 'employee'
    ).toList();



    if (activeEmployees.isEmpty) return;

    // Calculate inverse weights (employees with fewer leads get more)
    final maxLeads = activeEmployees.map((e) => e.newLeadsCount).reduce((a, b) => a > b ? a : b);
    final weights = activeEmployees.map((e) => maxLeads - e.newLeadsCount + 1).toList();
    final totalWeight = weights.reduce((a, b) => a + b);

    var allocated = 0;
    for (var i = 0; i < activeEmployees.length; i++) {
      final emp = activeEmployees[i];
      final weight = weights[i];
      final count = (widget.totalCount * weight / totalWeight).round();
      
      _allocationControllers[emp.employeeCode]!.text = count.toString();
      allocated += count;
    }

    // Adjust for rounding errors
    if (allocated != widget.totalCount) {
      final diff = widget.totalCount - allocated;
      final firstEmp = activeEmployees.first;
      final currentCount = int.tryParse(_allocationControllers[firstEmp.employeeCode]!.text) ?? 0;
      _allocationControllers[firstEmp.employeeCode]!.text = (currentCount + diff).toString();
    }

    setState(() {});
  }

  void _clearAll() {
    for (var controller in _allocationControllers.values) {
      controller.clear();
    }
    setState(() {});
  }

  Future<void> _allocateLeads() async {
    if (_remaining != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please allocate all ${widget.totalCount} records. Remaining: $_remaining')),
      );
      return;
    }

    // Build allocations list
    List<Map<String, dynamic>> allocations = [];
    for (var emp in _employees) {
      final count = int.tryParse(_allocationControllers[emp.employeeCode]!.text) ?? 0;
      if (count > 0) {
        allocations.add({
          'employee_code': emp.employeeCode,
          'employee_name': emp.employeeName,
          'count': count,
        });
      }
    }

    if (allocations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please allocate to at least one employee')),
      );
      return;
    }

    setState(() => _isAllocating = true);

    try {
      if (widget.mode == 'allocate') {
        await DatabaseService.allocateLeads(
          selections: widget.selections,
          allocations: allocations,
        );
      } else {
        await DatabaseService.reallocateLeads(
          selections: widget.selections,
          allocations: allocations,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully ${widget.mode == 'allocate' ? 'allocated' : 'reallocated'} ${widget.totalCount} leads!'),
            backgroundColor: Colors.green,
          ),
        );

        // Go back to leads screen
        Navigator.of(context).popUntil((route) => route.settings.name == '/manager/leads-detail' || route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAllocating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final officeEmployees = _employees.where((e) => !e.wfh).toList();
    final wfhEmployees = _employees.where((e) => e.wfh).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Distribute ${widget.totalCount} Leads',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header (Start directly after AppBar)

                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 35, child: Text('SN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF)))),
                      const Expanded(flex: 2, child: Text('EMPLOYEE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF)))),
                      if (widget.mode == 'reallocate')
                        SizedBox(
                          width: 50,
                          child: Text(
                            'MAX',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red[400]),
                          ),
                        ),
                      SizedBox(width: 50, child: Text('NEW', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[400]))),
                      const Expanded(child: Text('ALLOCATE', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF)))),
                    ],
                  ),
                ),

                // Employee List
                Expanded(
                  child: ListView(
                    children: [
                      ...officeEmployees.asMap().entries.map((entry) {
                        return _buildEmployeeRow(entry.value, entry.key + 1);
                      }),
                      if (wfhEmployees.isNotEmpty) const SizedBox(height: 24),
                      ...wfhEmployees.asMap().entries.map((entry) {
                        return _buildEmployeeRow(entry.value, officeEmployees.length + entry.key + 1);
                      }),
                    ],
                  ),
                ),

                // Quick Actions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'QUICK ACTIONS',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF), letterSpacing: 1),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildQuickActionButton(
                            onPressed: _distributeEqually,
                            icon: Icons.balance_outlined,
                            label: 'Equal',
                            color: const Color(0xFF3B82F6),
                          ),
                          const SizedBox(width: 8),
                          _buildQuickActionButton(
                            onPressed: _distributeByWorkload,
                            icon: Icons.auto_awesome_outlined,
                            label: 'Load',
                            color: const Color(0xFF8B5CF6),
                          ),
                          const SizedBox(width: 8),
                          _buildQuickActionButton(
                            onPressed: _clearAll,
                            icon: Icons.backspace_outlined,
                            label: 'Clear',
                            color: const Color(0xFF64748B),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Footer (Refined Pro Style)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Compact Stats Row
                        Row(
                          children: [
                            _buildFooterStat('TOTAL', widget.totalCount.toString(), const Color(0xFF3B82F6)),
                            const SizedBox(width: 16),
                            _buildFooterStat('ALLOC', _totalAllocated.toString(), const Color(0xFF10B981)),
                            const SizedBox(width: 16),
                            _buildFooterStat('REM', '$_remaining', _remaining == 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                          ],
                        ),
                        // Balanced Action Button
                        ElevatedButton(
                          onPressed: _isAllocating ? null : _allocateLeads,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _remaining == 0 ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: _isAllocating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Allocate',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFooterStat(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.8,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeRow(EmployeePerformance emp, int serialNo) {
    final isPresent = _presentEmployeeCodes.contains(emp.employeeCode);
    final controller = _allocationControllers[emp.employeeCode]!;

    Color nameColor;
    if (emp.disabled) {
      nameColor = Colors.red;
    } else if (!isPresent) {
      nameColor = Colors.grey[400]!;
    } else {
      nameColor = const Color(0xFF1F2937);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 35,
            child: Text(serialNo.toString(), style: TextStyle(fontSize: 12, color: Colors.grey[400])),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    emp.employeeName,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: nameColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!emp.disabled && !isPresent) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.close, color: Colors.red, size: 16),
                ],
              ],
            ),
          ),
          if (widget.mode == 'reallocate')
            SizedBox(
              width: 50,
              child: Text(
                _maxAvailablePerEmployee[emp.employeeCode]?.toString() ?? '-',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13, 
                  fontWeight: FontWeight.bold, 
                  color: (_maxAvailablePerEmployee[emp.employeeCode] ?? 0) > 0 ? const Color(0xFFEF4444) : Colors.grey[400]
                ),
              ),
            ),
          SizedBox(
            width: 50,
            child: Text(
              emp.newLeadsCount == 0 ? '-' : emp.newLeadsCount.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: emp.newLeadsCount > 0 ? const Color(0xFF10B981) : Colors.grey[400]),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // Validate max for reallocate mode
                      if (widget.mode == 'reallocate' && _maxAvailablePerEmployee.containsKey(emp.employeeCode)) {
                        final entered = int.tryParse(value) ?? 0;
                        final max = _maxAvailablePerEmployee[emp.employeeCode]!;
                        
                        if (entered > max) {
                          controller.text = max.toString();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Maximum $max available for ${emp.employeeName}'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () {
                    final current = int.tryParse(controller.text) ?? 0;
                    controller.text = (current + 5).toString();
                    setState(() {});
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
