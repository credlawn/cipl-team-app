import 'package:flutter/material.dart';
import '../../services/employee_service.dart';
import 'package:intl/intl.dart';

class ConfirmTraineeDialog extends StatefulWidget {
  final Map<String, dynamic> employee;

  const ConfirmTraineeDialog({super.key, required this.employee});

  @override
  State<ConfirmTraineeDialog> createState() => _ConfirmTraineeDialogState();
}

class _ConfirmTraineeDialogState extends State<ConfirmTraineeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _salaryController = TextEditingController();
  DateTime? _payrollStartDate;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchNextCode();
  }

  Future<void> _fetchNextCode() async {
    try {
      final code = await EmployeeService.getNextEmployeeCode();
      setState(() {
        _codeController.text = code;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch next code: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _payrollStartDate = picked);
    }
  }

  Future<void> _confirm() async {
    if (!_formKey.currentState!.validate() || _payrollStartDate == null) {
      if (_payrollStartDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select Payroll Start Date')),
        );
      }
      return;
    }

    setState(() => _isSaving = true);
    try {
      await EmployeeService.confirmTrainee(
        userId: widget.employee['id'],
        employeeCode: _codeController.text.trim(),
        payrollStartDate: DateTime.utc(_payrollStartDate!.year, _payrollStartDate!.month, _payrollStartDate!.day, 12, 0, 0).toIso8601String(),
        salary: _salaryController.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.verified_user_outlined, color: Color(0xFF10B981), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Confirm Trainee',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Confirm ${widget.employee['employee_name']} as a full-time employee.',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const Divider(height: 32),
              
              // Designation (Read Only)
              const Text('Designation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Relationship Executive', style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
              ),
              
              const SizedBox(height: 20),
              
              // Employee Code (Read Only)
              const Text('Employee Code', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
              const SizedBox(height: 6),
              TextFormField(
                controller: _codeController,
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  suffixIcon: _isLoading ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))) : const Icon(Icons.lock_outline, size: 16, color: Color(0xFF9CA3AF)),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Payroll Date
              const Text('Payroll Start Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
              const SizedBox(height: 6),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF6B7280)),
                      const SizedBox(width: 10),
                      Text(
                        _payrollStartDate == null ? 'Select Date' : DateFormat('dd-MM-yyyy').format(_payrollStartDate!),
                        style: TextStyle(
                          color: _payrollStartDate == null ? const Color(0xFF9CA3AF) : const Color(0xFF111827),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Salary
              const Text('In hand salary', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
              const SizedBox(height: 6),
              TextFormField(
                controller: _salaryController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter in hand salary',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 12),
                      const Text(
                        '₹',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter In hand salary';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving || _isLoading ? null : _confirm,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                      child: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Confirm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
