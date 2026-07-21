import 'package:flutter/material.dart';
import '../../services/employee_service.dart';
import 'package:intl/intl.dart';

class RejectTraineeDialog extends StatefulWidget {
  final Map<String, dynamic> employee;

  const RejectTraineeDialog({super.key, required this.employee});

  @override
  State<RejectTraineeDialog> createState() => _RejectTraineeDialogState();
}

class _RejectTraineeDialogState extends State<RejectTraineeDialog> {
  DateTime? _lastWorkingDate;
  bool _isSaving = false;

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
              primary: Color(0xFFEF4444),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _lastWorkingDate = picked);
    }
  }

  Future<void> _confirm() async {
    if (_lastWorkingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Last Working Date')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await EmployeeService.rejectTrainee(
        userId: widget.employee['id'],
        lastWorkingDate: DateTime.utc(_lastWorkingDate!.year, _lastWorkingDate!.month, _lastWorkingDate!.day, 12, 0, 0).toIso8601String(),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person_off_outlined, color: Color(0xFFEF4444), size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Reject Trainee',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Confirm rejection and disable account for ${widget.employee['employee_name']}.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const Divider(height: 32),
            
            // Rejection Date
            const Text('Last Working Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
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
                      _lastWorkingDate == null ? 'Select Date' : DateFormat('dd-MM-yyyy').format(_lastWorkingDate!),
                      style: TextStyle(
                        color: _lastWorkingDate == null ? const Color(0xFF9CA3AF) : const Color(0xFF111827),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
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
                    onPressed: _isSaving ? null : _confirm,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                    child: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Reject', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
