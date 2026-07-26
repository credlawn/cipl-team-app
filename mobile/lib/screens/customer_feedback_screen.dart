import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../core/pb_api.dart';
import '../widgets/date_of_birth_picker.dart';
import '../widgets/follow_up_picker.dart';
import '../utils/ocr_helper.dart';
import '../utils/uppercase_text_formatter.dart';
import 'package:image_picker/image_picker.dart';
import '../services/lead_service.dart';

class CustomerFeedbackScreen extends StatefulWidget {
  final String leadId;
  final String customerName;
  final String mobileNo;
  final String currentStatus;
  final DateTime? currentStatusDate;

  const CustomerFeedbackScreen({
    required this.leadId,
    required this.customerName,
    required this.mobileNo,
    required this.currentStatus,
    this.currentStatusDate,
    super.key,
  });

  @override
  State<CustomerFeedbackScreen> createState() => _CustomerFeedbackScreenState();
}

class _CustomerFeedbackScreenState extends State<CustomerFeedbackScreen> {
  String? _selectedStatus;
  bool _isSubmitting = false;

  final _arnController = TextEditingController();
  final _dobController = TextEditingController();
  final _remarksController = TextEditingController();
  final _followupDateController = TextEditingController();
  final _followupTimeController = TextEditingController();
  DateTime? _selectedDob;
  DateTime? _selectedFollowupDate;
  TimeOfDay? _selectedFollowupTime;

  // Statuses where change is permanently blocked
  static const _lockedStatuses = {'IP Approved'};

  // Statuses where a warning dialog is shown before allowing change
  static const _warnStatuses = {
    'IP Decline', 'Not Eligible', 'Denied',
    'Already Carded', 'Recently Applied', 'No Docs',
  };

  // Shows warning dialog, returns true if user confirms change
  Future<bool> _showWarningDialog() async {
    final dateStr = widget.currentStatusDate != null
        ? DateFormat('dd MMM').format(widget.currentStatusDate!)
        : 'earlier';

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 28),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Already Marked',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This lead was previously marked as:',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFF59E0B), width: 1),
              ),
              child: Text(
                '${widget.currentStatus}  ·  $dateStr',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF92400E),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Are you sure you want to change the status?',
              style: TextStyle(fontSize: 14, color: Color(0xFF374151), height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Change Anyway'),
          ),
        ],
      ),
    ) ?? false;
  }

  final List<Map<String, dynamic>> _statusOptions = [
    {'label': 'Hold', 'icon': Icons.pause_circle_outline, 'color': Color(0xFF9C27B0), 'fields': ['remarks']},
    {'label': 'Follow Up', 'icon': Icons.schedule_outlined, 'color': Color(0xFF00BCD4), 'fields': ['followup_date', 'followup_time']},
    {'label': 'IP Approved', 'icon': Icons.check_circle_outline, 'color': Color(0xFF4CAF50), 'fields': ['arn', 'dob']},
    {'label': 'IP Decline', 'icon': Icons.cancel_outlined, 'color': Color(0xFFF44336), 'fields': ['dob']},
    {'label': 'No Docs', 'icon': Icons.description_outlined, 'color': Color(0xFF795548), 'fields': ['remarks', 'dob']},
    {'label': 'Not Eligible', 'icon': Icons.block_outlined, 'color': Color(0xFF795548), 'fields': ['remarks']},
    {'label': 'Denied', 'icon': Icons.close_outlined, 'color': Color(0xFFFF9800), 'fields': ['remarks']},
    {'label': 'Already Carded', 'icon': Icons.credit_card_outlined, 'color': Color(0xFF607D8B), 'fields': ['remarks']},
    {'label': 'Recently Applied', 'icon': Icons.history_outlined, 'color': Color(0xFF607D8B), 'fields': ['remarks']},
    {'label': 'Voicemail', 'icon': Icons.voicemail_outlined, 'color': Color(0xFF9E9E9E), 'fields': []},
  ];

  @override
  void dispose() {
    _arnController.dispose();
    _dobController.dispose();
    _remarksController.dispose();
    _followupDateController.dispose();
    _followupTimeController.dispose();
    super.dispose();
  }

  List<String> _getRequiredFields() {
    final status = _statusOptions.firstWhere(
      (s) => s['label'] == _selectedStatus,
      orElse: () => {'fields': []},
    );
    return List<String>.from(status['fields'] ?? []);
  }

  bool _validateFields() {
    final requiredFields = _getRequiredFields();
    
    if (requiredFields.contains('arn') && _arnController.text.trim().isEmpty) {
      return false;
    }
    if (requiredFields.contains('dob') && _selectedDob == null) {
      return false;
    }
    if (requiredFields.contains('remarks') && _remarksController.text.trim().isEmpty) {
      return false;
    }
    if (requiredFields.contains('followup_date') && _selectedFollowupDate == null) {
      return false;
    }
    if (requiredFields.contains('followup_time') && _selectedFollowupTime == null) {
      return false;
    }
    
    return true;
  }

  Future<void> _selectDate() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DateOfBirthPicker(
        initialDate: _selectedDob,
        onDateSelected: (date) {
          setState(() {
            _selectedDob = date;
            _dobController.text = DateFormat('dd/MM/yyyy').format(date);
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _selectFollowup() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FollowUpPicker(
        initialDate: _selectedFollowupDate,
        initialTime: _selectedFollowupTime,
        onDateTimeSelected: (dateTime) {
          setState(() {
            _selectedFollowupDate = dateTime;
            _selectedFollowupTime = TimeOfDay.fromDateTime(dateTime);
            
            _followupDateController.text = DateFormat('dd/MM/yyyy').format(dateTime);
            _followupTimeController.text = DateFormat('h:mm a').format(dateTime);
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_selectedStatus == null) {
      _showSnackBar('Please select a status', Icons.warning_amber_rounded, Colors.orange.shade700);
      return;
    }

    // ARN Validation
    final arn = _arnController.text.trim();
    if (arn.isNotEmpty) {
      if (arn.startsWith('D') || arn.startsWith('2')) {
        if (arn.length < 16) {
          _showSnackBar('ARN must be at least 16 characters', Icons.warning_amber_rounded, Colors.orange.shade700);
          return;
        }
      }
    }

    if (!_validateFields()) {
      _showSnackBar('Please fill all required fields', Icons.warning_amber_rounded, Colors.orange.shade700);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      DateTime? combinedFollowupTime;
      if (_selectedFollowupDate != null && _selectedFollowupTime != null) {
        combinedFollowupTime = DateTime(
          _selectedFollowupDate!.year,
          _selectedFollowupDate!.month,
          _selectedFollowupDate!.day,
          _selectedFollowupTime!.hour,
          _selectedFollowupTime!.minute,
        );
      }

      await LeadService.updateLeadStatus(
        widget.leadId,
        _selectedStatus!,
        followupTime: combinedFollowupTime,
        arnNo: _arnController.text.trim().isEmpty ? null : _arnController.text.trim(),
        dateOfBirth: _selectedDob,
        remarks: _remarksController.text.trim().isEmpty ? null : _remarksController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to update status', Icons.error_outline, Colors.red.shade600);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackBar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  Future<void> _scanArn() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF3B82F6)),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                OcrHelper.pickImage(ImageSource.camera, (text) {
                  setState(() {
                    _arnController.text = text;
                  });
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF3B82F6)),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                OcrHelper.pickImage(ImageSource.gallery, (text) {
                  setState(() {
                    _arnController.text = text;
                  });
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    required Color statusColor,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            prefixIcon: icon != null ? Icon(icon, color: statusColor, size: 20) : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon, color: statusColor, size: 20),
                    onPressed: onSuffixTap,
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: statusColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date of Birth',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _selectedDob != null ? statusColor : const Color(0xFFE5E7EB),
                width: _selectedDob != null ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: statusColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDob != null
                        ? DateFormat('dd/MM/yyyy').format(_selectedDob!)
                        : 'Select date of birth',
                    style: TextStyle(
                      fontSize: 15,
                      color: _selectedDob != null ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFollowupDateField(Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Follow-up Date',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectFollowup,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _selectedFollowupDate != null ? statusColor : const Color(0xFFE5E7EB),
                width: _selectedFollowupDate != null ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.event, color: statusColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedFollowupDate != null
                        ? DateFormat('dd/MM/yyyy').format(_selectedFollowupDate!)
                        : 'Select follow-up date',
                    style: TextStyle(
                      fontSize: 15,
                      color: _selectedFollowupDate != null ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFollowupTimeField(Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Follow-up Time',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectFollowup,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _selectedFollowupTime != null ? statusColor : const Color(0xFFE5E7EB),
                width: _selectedFollowupTime != null ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: statusColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedFollowupTime != null
                        ? _selectedFollowupTime!.format(context)
                        : 'Select follow-up time',
                    style: TextStyle(
                      fontSize: 15,
                      color: _selectedFollowupTime != null ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedStatusData = _statusOptions.firstWhere(
      (s) => s['label'] == _selectedStatus,
      orElse: () => {'fields': [], 'color': Colors.grey},
    );
    final fields = List<String>.from(selectedStatusData['fields'] ?? []);
    final statusColor = selectedStatusData['color'] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Update Status',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
      ),
      body: _lockedStatuses.contains(widget.currentStatus)
          ? _buildLockedBody()
          : Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.customerName,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF6B7280)),
                          const SizedBox(width: 6),
                          Text(
                            widget.mobileNo,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_selectedStatus != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStatus = null;
                        _arnController.clear();
                        _dobController.clear();
                        _remarksController.clear();
                        _followupDateController.clear();
                        _followupTimeController.clear();
                        _selectedDob = null;
                        _selectedFollowupDate = null;
                        _selectedFollowupTime = null;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColor,
                            statusColor.withOpacity(0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              selectedStatusData['icon'],
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedStatus!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.close, color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedStatus == null) ...[
                    const Text(
                      'Select New Status',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: _statusOptions.length,
                    itemBuilder: (context, index) {
                      final status = _statusOptions[index];
                      final isSelected = _selectedStatus == status['label'];
                      return GestureDetector(
                        onTap: () async {
                          // If current status is in warn group, show warning dialog first
                          if (_warnStatuses.contains(widget.currentStatus)) {
                            final confirmed = await _showWarningDialog();
                            if (!confirmed) return;
                          }
                          setState(() {
                            if (_selectedStatus == status['label']) {
                              _selectedStatus = null;
                              _arnController.clear();
                              _dobController.clear();
                              _remarksController.clear();
                              _followupDateController.clear();
                              _followupTimeController.clear();
                              _selectedDob = null;
                              _selectedFollowupDate = null;
                              _selectedFollowupTime = null;
                            } else {
                              _selectedStatus = status['label'];
                              _arnController.clear();
                              _dobController.clear();
                              _remarksController.clear();
                              _followupDateController.clear();
                              _followupTimeController.clear();
                              _selectedDob = null;
                              _selectedFollowupDate = null;
                              _selectedFollowupTime = null;
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      status['color'],
                                      status['color'].withOpacity(0.85),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isSelected ? null : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? status['color'] : const Color(0xFFE5E7EB),
                              width: isSelected ? 2 : 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: status['color'].withOpacity(0.25),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                      spreadRadius: 0,
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.25)
                                      : status['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  status['icon'],
                                  color: isSelected ? Colors.white : status['color'],
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  status['label'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : const Color(0xFF374151),
                                    letterSpacing: 0.2,
                                    height: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  ],
                  if (_selectedStatus != null && fields.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.edit_note, color: statusColor, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Additional Details',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (fields.contains('arn')) ...[ 
                              _buildTextField(
                                controller: _arnController,
                                label: 'ARN Number',
                                hint: 'Enter ARN number',
                                icon: Icons.badge_outlined,
                                suffixIcon: Icons.camera_alt_outlined,
                                onSuffixTap: _scanArn,
                                statusColor: statusColor,
                                textCapitalization: TextCapitalization.characters,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(16),
                                  UpperCaseTextFormatter(),
                                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                            if (fields.contains('dob')) ...[
                              _buildDateField(statusColor),
                              const SizedBox(height: 16),
                            ],
                            if (fields.contains('followup_date')) ...[
                              _buildFollowupDateField(statusColor),
                              const SizedBox(height: 16),
                            ],
                            if (fields.contains('followup_time')) ...[
                              _buildFollowupTimeField(statusColor),
                              const SizedBox(height: 16),
                            ],
                            if (fields.contains('remarks')) ...[
                              _buildTextField(
                                controller: _remarksController,
                                label: 'Remarks',
                                hint: 'Enter remarks',
                                statusColor: statusColor,
                                maxLines: 3,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_isSubmitting || _selectedStatus == null) ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Update Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 48,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Status Locked',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            Builder(builder: (context) {
              final dateStr = widget.currentStatusDate != null
                  ? ' on ${DateFormat('dd MMM yyyy').format(widget.currentStatusDate!)}'
                  : '';
              return Text(
                'This lead is marked as "IP Approved"$dateStr.\n\nStatus cannot be changed once IP Approved.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.6,
                ),
              );
            }),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Go Back'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4CAF50),
                side: const BorderSide(color: Color(0xFF4CAF50)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
