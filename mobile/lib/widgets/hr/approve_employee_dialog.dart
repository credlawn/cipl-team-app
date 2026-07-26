import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/pb_api.dart';
import '../../services/employee_service.dart';

class ApproveEmployeeDialog extends StatefulWidget {
  final Map<String, dynamic> employee;

  const ApproveEmployeeDialog({
    super.key,
    required this.employee,
  });

  @override
  State<ApproveEmployeeDialog> createState() => _ApproveEmployeeDialogState();
}

class _ApproveEmployeeDialogState extends State<ApproveEmployeeDialog> {
  final _codeController = TextEditingController();
  DateTime? _trainingStartDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchNextCode();
    // Default to current date_of_joining if available
    final joining = widget.employee['date_of_joining'];
    if (joining != null && joining.toString().isNotEmpty) {
      _trainingStartDate = DateTime.tryParse(joining.toString());
    }
  }

  Future<void> _fetchNextCode() async {
    setState(() => _isLoading = true);
    final code = await EmployeeService.getNextTraineeCode();
    _codeController.text = code;
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _trainingStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _trainingStartDate = picked);
    }
  }

  Future<void> _approve() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Employee code is required')));
      return;
    }
    if (_trainingStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Training Start Date is required')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await PB.pb.collection('users').update(
        widget.employee['id'],
        body: {
          'employee_code': code,
          'trainee_code': code,
          'username': widget.employee['mobile_no'].toString().trim(),
          'emailVisibility': true, // Make email visible to others
          'date_of_joining': DateTime.utc(_trainingStartDate!.year, _trainingStartDate!.month, _trainingStartDate!.day, 12, 0, 0).toIso8601String(),
          'disabled': false, // Activate employee
        },
      );

      if (!mounted) return;
      
      Navigator.pop(context, true); // Return true to refresh list
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Trainee approved successfully', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.employee['employee_name']?.toString() ?? 'Unknown';
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Approve Trainee', 
        style: TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        )
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Approve $name as a Trainee', 
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))
            ),
            const SizedBox(height: 24),
            
            // Training Start Date Picker
            _buildFieldLabel('Training Start Date *'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF64748B)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  isDense: true,
                ),
                child: Text(
                  _trainingStartDate == null 
                    ? 'Select Date' 
                    : '${_trainingStartDate!.day}/${_trainingStartDate!.month}/${_trainingStartDate!.year}',
                  style: TextStyle(
                    fontSize: 14, 
                    color: _trainingStartDate == null ? const Color(0xFF94A3B8) : const Color(0xFF1E293B)
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Trainee Code Field (Read Only)
            _buildFieldLabel('Trainee Code *'),
            const SizedBox(height: 8),
            TextField(
              controller: _codeController,
              readOnly: true,
              decoration: InputDecoration(
                fillColor: const Color(0xFFF1F5F9),
                filled: true,
                prefixIcon: const Icon(Icons.badge_outlined, size: 18, color: Color(0xFF64748B)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),

            const SizedBox(height: 16),

            // Default Password Display (Helpful for Manager)
            _buildFieldLabel('Default Password'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.vpn_key_outlined, size: 18, color: Color(0xFF64748B)),
                  const SizedBox(width: 12),
                  const Text(
                    'Cred@2026',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF3B82F6)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      final code = _codeController.text.trim();
                      final mobile = widget.employee['mobile_no'].toString().trim();
                      final credentials = '$name\nLogin Id- $mobile\nPassword- Cred@2026\n(Trainee Id- $code)';
                      Clipboard.setData(ClipboardData(text: credentials));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Credentials copied to clipboard!'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            const Text(
              'User can login using Code & this Password',
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _approve,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: _isLoading
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
              : const Text('Approve & Activate', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.2),
    );
  }
}
