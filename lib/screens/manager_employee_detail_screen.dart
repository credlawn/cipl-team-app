import 'package:flutter/material.dart';
import '../services/manager_task_service.dart';
import '../core/pb_api.dart';

class ManagerEmployeeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> employeeData;

  const ManagerEmployeeDetailScreen({
    super.key,
    required this.employeeData,
  });

  @override
  State<ManagerEmployeeDetailScreen> createState() => _ManagerEmployeeDetailScreenState();
}

class _ManagerEmployeeDetailScreenState extends State<ManagerEmployeeDetailScreen> {
  String _filter = 'All'; // 'All', 'Pending', 'Done'
  late Map<String, dynamic> _employeeData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _employeeData = widget.employeeData;
  }

  Future<void> _refreshData() async {
    final data = await ManagerTaskService.getActivationDetailedBreakdown();
    if (mounted) {
      final employees = List<Map<String, dynamic>>.from(data['employees'] ?? []);
      final updatedEmp = employees.firstWhere(
        (e) => e['employee_name'] == widget.employeeData['employee_name'],
        orElse: () => _employeeData,
      );
      setState(() {
        _employeeData = updatedEmp;
      });
    }
  }

  void _showStatusUpdateSheet(Map<String, dynamic> customer) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        bool isToggling = false;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bool isRemoved = customer['remove_data'] == true;

            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Update Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    customer['customer_name'] ?? '',
                    style: const TextStyle(color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusButton(
                          'Transaction\nDone', 
                          const Color(0xFF059669), 
                          customer['id'],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusButton(
                          'Activation\nDone', 
                          const Color(0xFF2563EB), 
                          customer['id'],
                        ),
                      ),
                    ],
                  ),
                  if (PB.pb.authStore.model?.data['bh_access'] == true) ...[
                    const SizedBox(height: 16),
                    _buildRemoveDataToggle(
                      customer, 
                      isRemoved, 
                      isToggling ? null : (newVal) async {
                        setSheetState(() => isToggling = true);
                        final success = await ManagerTaskService.updateRemoveDataStatus(customer['id'], newVal);
                        if (success) {
                          setSheetState(() {
                            customer['remove_data'] = newVal;
                          });
                          _refreshData(); // Auto refresh UI behind the sheet
                        }
                        setSheetState(() => isToggling = false);
                      }
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRemoveDataToggle(Map<String, dynamic> customer, bool isRemoved, Function(bool)? onToggle) {
    final bool isDisabled = onToggle == null;
    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isRemoved ? Icons.delete_forever : Icons.delete_outline, 
                  color: isRemoved ? const Color(0xFFEF4444) : const Color(0xFF6B7280),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'REMOVE DATA',
                  style: TextStyle(
                    fontWeight: FontWeight.w800, 
                    fontSize: 12, 
                    color: isRemoved ? const Color(0xFFEF4444) : const Color(0xFF374151),
                    letterSpacing: 0.5,
                  ),
                ),
                if (isDisabled) ...[
                  const SizedBox(width: 12),
                  const SizedBox(
                    width: 12, height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF9CA3AF)),
                  ),
                ]
              ],
            ),
            _buildPremiumSquareToggle(
              isOn: isRemoved,
              onChanged: onToggle ?? (_) {}, // Dummy if disabled
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumSquareToggle({required bool isOn, required ValueChanged<bool> onChanged}) {
    return GestureDetector(
      onTap: () => onChanged(!isOn),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 40,
        height: 20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: isOn ? const Color(0xFFEF4444) : const Color(0xFFE5E7EB),
          boxShadow: [
            if (isOn) BoxShadow(color: const Color(0xFFEF4444).withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.elasticOut,
              alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String label, Color color, String id) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.08),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: color.withOpacity(0.2), width: 1.5),
        ),
        elevation: 0,
      ),
      onPressed: () async {
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                SizedBox(
                  height: 16, width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 12),
                Text('Updating status...', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: const Color(0xFF3B82F6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 1),
          ),
        );
        
        final success = await ManagerTaskService.updateCustomerStatus(id, label.replaceAll('\n', ' '));
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${label.replaceAll('\n', ' ')} Successful',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF059669),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );
          _refreshData(); // Auto refresh
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Update failed. Try again.'),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      child: Text(
        label, 
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, height: 1.2),
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '-';
    try {
      DateTime utcDate = DateTime.parse(dateStr);
      if (!dateStr.endsWith('Z') && !dateStr.contains('+')) {
        utcDate = DateTime.parse('${dateStr}Z');
      } else {
        utcDate = utcDate.toUtc();
      }
      final istDate = utcDate.add(const Duration(hours: 5, minutes: 30));
      
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final day = istDate.day.toString().padLeft(2, '0');
      final month = months[istDate.month - 1];
      
      return '$day-$month';
    } catch (e) {
      return dateStr.split(' ').first;
    }
  }

  String _getDaysElapsed(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      DateTime utcDate = DateTime.parse(dateStr);
      if (!dateStr.endsWith('Z') && !dateStr.contains('+')) {
        utcDate = DateTime.parse('${dateStr}Z');
      }
      final decisionDate = DateTime(utcDate.year, utcDate.month, utcDate.day);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final difference = today.difference(decisionDate).inDays;
      
      if (difference < 0) return '';
      return '$difference ${difference == 1 ? 'Day' : 'Days'}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeeName = _employeeData['employee_name'] ?? 'Unknown';
    final total = _employeeData['total'] ?? 0;
    final done = _employeeData['activated'] ?? 0;
    final today = _employeeData['today'] ?? 0;
    final bal = (total as int) - (done as int);

    List<Map<String, dynamic>> customers = List<Map<String, dynamic>>.from(_employeeData['customers'] ?? []);
    
    // Sort customers: Pending first, then by decision_date (Oldest first)
    customers.sort((a, b) {
      final isActivatedA = a['is_activated'] == true ? 1 : 0;
      final isActivatedB = b['is_activated'] == true ? 1 : 0;
      
      if (isActivatedA != isActivatedB) return isActivatedA.compareTo(isActivatedB);
      
      final dateA = a['decision_date']?.toString() ?? '';
      final dateB = b['decision_date']?.toString() ?? '';
      
      if (dateA.isEmpty) return 1;
      if (dateB.isEmpty) return -1;
      
      return dateA.compareTo(dateB);
    });

    if (_filter == 'Pending') {
      customers = customers.where((c) => c['is_activated'] != true).toList();
    } else if (_filter == 'Done') {
      customers = customers.where((c) => c['is_activated'] == true).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // Gray-100 background
      appBar: AppBar(
        title: const Text('Employee Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: const Color(0xFF3B82F6),
        child: Column(
          children: [
            // Employee Info Card
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            employeeName,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF2563EB)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: bal == 0 ? Colors.green.shade50 : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              bal == 0 ? 'All Clear' : '$bal Pending',
                              style: TextStyle(
                                fontSize: 12, 
                                fontWeight: FontWeight.bold, 
                                color: bal == 0 ? Colors.green.shade700 : Colors.red.shade700
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatCol('TOTAL', total.toString(), const Color(0xFF4B5563)),
                          _buildDivider(),
                          _buildStatCol('DONE', done.toString(), const Color(0xFF059669)),
                          _buildDivider(),
                          _buildStatCol('BAL', bal.toString(), const Color(0xFFDC2626)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: 12),
          
          // Compact Filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 16, color: Colors.grey),
                const SizedBox(width: 12),
                _buildCompactFilter('All', _filter == 'All'),
                const SizedBox(width: 8),
                _buildCompactFilter('Pending', _filter == 'Pending'),
                const SizedBox(width: 8),
                _buildCompactFilter('Done', _filter == 'Done'),
                const Spacer(),
                Text(
                  '${customers.length} records',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          
          // Customer Table Header
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Text(
              'Customer wise details',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
            ),
          ),

          // Customer List
          Expanded(
            child: Container(
              color: Colors.white,
              child: customers.isEmpty
                  ? const Center(child: Text('No customers found', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        final cust = customers[index];
                        final isActivated = cust['is_activated'] == true;
                        final isToday = cust['is_today'] == true;
                        
                        final decisionDate = _formatDate(cust['decision_date']?.toString() ?? '');
                        final daysElapsed = _getDaysElapsed(cust['decision_date']?.toString() ?? '');
                        final statusDate = _formatDate(cust['user_status_date']?.toString() ?? '');
                        final arn = cust['arn_no']?.toString() ?? '';
                        final mobile = cust['mobile_no']?.toString() ?? '';
                        final remarks = cust['user_remarks']?.toString() ?? '';
                        final statusText = cust['user_status']?.toString() ?? (isActivated ? 'Done' : 'Pending');
                        
                        return InkWell(
                          onTap: () => _showStatusUpdateSheet(cust),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                            ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Customer Name & Tag
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                cust['customer_name'] ?? 'Unknown',
                                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF111827)),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (cust['remove_data'] == true) ...[
                                              const SizedBox(width: 4),
                                              const Icon(Icons.cancel, color: Colors.red, size: 12),
                                            ],
                                          ],
                                        ),
                                        if (mobile.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            mobile,
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  
                                  // Product
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      cust['product'] ?? '-',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  
                                  // Status Badge
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (daysElapsed.isNotEmpty && !isActivated) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: Colors.green.shade100),
                                            ),
                                            child: Text(
                                              daysElapsed,
                                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                        ],
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isActivated ? Colors.green.shade50 : Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: isActivated ? Colors.green.shade200 : Colors.red.shade200),
                                          ),
                                          child: Text(
                                            isActivated ? 'Done' : 'Pending',
                                            style: TextStyle(
                                              fontSize: 10, 
                                              fontWeight: FontWeight.bold, 
                                              color: isActivated ? Colors.green.shade700 : Colors.red.shade700
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Extra Details Section (Compact)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: _buildDetailRow('ARN', arn.isEmpty ? '-' : arn)),
                                        Expanded(child: _buildDetailRow('Decision Dt', decisionDate)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Expanded(child: _buildDetailRow('Status Dt.', statusDate)),
                                        Expanded(child: _buildDetailRow('Status', statusText)),
                                      ],
                                    ),
                                    if (remarks.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      const Divider(height: 8, color: Color(0xFFE5E7EB)),
                                      Text(
                                        'Remarks: $remarks',
                                        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF6B7280)),
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ));
                      },
                    ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildStatCol(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF))),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: const Color(0xFFE5E7EB),
    );
  }

  Widget _buildCompactFilter(String label, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _filter = label),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFD1D5DB)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
