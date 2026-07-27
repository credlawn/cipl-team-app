import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/pb_api.dart';
import 'package:intl/intl.dart';

class EmployeeCard extends StatelessWidget {
  final Map<String, dynamic> employee;
  final VoidCallback? onTap;
  final bool isDisabled;
  final bool isPending;
  final bool isTrainee;
  final VoidCallback? onApprove;
  final VoidCallback? onConfirm;
  final VoidCallback? onReject;

  const EmployeeCard({
    super.key,
    required this.employee,
    this.onTap,
    this.isDisabled = false,
    this.isPending = false,
    this.isTrainee = false,
    this.onApprove,
    this.onConfirm,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final hasBHAccess = PB.pb.authStore.record?.data['bh_access'] == true;
    final name = (employee['employee_name'] ?? 'Unknown').toString();
    final code = (employee['employee_code'] ?? '').toString();
    final mobile = (employee['mobile_no'] ?? '').toString();
    final department = (employee['department'] ?? '').toString();
    final wfh = employee['wfh'] == true;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDisabled || isPending
                      ? Colors.grey.withValues(alpha: 0.1)
                      : const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDisabled || isPending
                          ? Colors.grey[400]
                          : const Color(0xFF3B82F6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Badges
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDisabled || isPending
                                  ? Colors.grey[400]
                                  : const Color(0xFF111827),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (wfh) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'WFH',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                        if (isDisabled) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],

                      ],
                    ),
                    const SizedBox(height: 3),
                    // Code • Date
                    Text(
                      [
                        if (code.isNotEmpty) code,
                        () {
                          final dateStr = (employee['payroll_start_date'] != null && employee['payroll_start_date'].toString().isNotEmpty)
                              ? employee['payroll_start_date'].toString()
                              : (employee['date_of_joining'] != null && employee['date_of_joining'].toString().isNotEmpty)
                                  ? employee['date_of_joining'].toString()
                                  : '';
                          
                          if (dateStr.isEmpty) return null;
                          try {
                            final dt = DateTime.parse(dateStr);
                            return DateFormat('dd-MMM-yy').format(dt);
                          } catch (e) {
                            return dateStr.split(' ').first.split('T').first;
                          }
                        }(),
                      ].where((e) => e != null).join(' • '),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDisabled || isPending
                            ? Colors.grey[400]
                            : const Color(0xFF6B7280),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Copy Credentials Button (Smart Check)
              if (employee['must_change_password'] == true)
                IconButton(
                  icon: const Icon(Icons.content_copy_rounded, color: Color(0xFF3B82F6), size: 18),
                  onPressed: () {
                    final name = (employee['employee_name'] ?? 'Unknown').toString();
                    final mobile = (employee['mobile_no'] ?? '').toString();
                    final code = (employee['employee_code'] ?? '').toString();
                    final credentials = '$name\nLogin Id- $mobile\nPassword- Cred@2026\n(Trainee Id- $code)';
                    Clipboard.setData(ClipboardData(text: credentials));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                            SizedBox(width: 12),
                            Text(
                              'Credentials copied to clipboard',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFF3B82F6),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        margin: const EdgeInsets.all(16),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  tooltip: 'Copy Credentials',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
              const SizedBox(width: 4),
              // Action Button or Arrow
              if (isTrainee && hasBHAccess)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280), size: 22),
                  padding: EdgeInsets.zero,
                  onSelected: (value) {
                    if (value == 'select') onConfirm?.call();
                    if (value == 'reject') onReject?.call();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'select',
                      child: Row(
                        children: const [
                          Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 18),
                          SizedBox(width: 10),
                          Text('Selected', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'reject',
                      child: Row(
                        children: const [
                          Icon(Icons.block, color: Color(0xFFEF4444), size: 18),
                          SizedBox(width: 10),
                          Text('Rejected', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                )
              else if (isPending && onApprove != null)
                TextButton(
                  onPressed: onApprove,
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text(
                    'Approve',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                )
              else
                Icon(
                  Icons.chevron_right,
                  color: isDisabled || isPending ? Colors.grey[300] : Colors.grey[400],
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
