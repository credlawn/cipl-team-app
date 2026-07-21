import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../services/employee_service.dart';
import '../utils/proper_case_text_formatter.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  
  DateTime? _dateOfBirth;
  DateTime? _trainingStartDate;
  bool _wfh = false;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  List<XFile> _aadharFiles = [];

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<DateTime?> _selectDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
    return picked;
  }

  Future<DateTime?> _selectTrainingStartDate() async {
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
    return picked;
  }

  Future<void> _pickAadharFiles() async {
    if (_aadharFiles.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 2 attachments allowed')),
      );
      return;
    }

    try {
      final List<XFile> picked = await _picker.pickMultiImage(
        imageQuality: 80,
      );
      
      if (picked.isNotEmpty) {
        setState(() {
          _aadharFiles.addAll(picked);
          if (_aadharFiles.length > 2) {
            _aadharFiles = _aadharFiles.sublist(0, 2);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick images')),
      );
    }
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Check for duplicate mobile number
      final mobileNo = _mobileController.text.trim();
      final exists = await EmployeeService.isMobileExists(mobileNo);
      
      if (exists) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mobile number already exists in the system', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Check for duplicate email
      final email = _emailController.text.trim();
      if (email.isNotEmpty) {
        final emailExists = await EmployeeService.isEmailExists(email);
        if (emailExists) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email address already exists in the system', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              backgroundColor: Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }

      await EmployeeService.addEmployee(
        employeeName: _nameController.text.trim(),
        mobileNo: mobileNo,
        email: _emailController.text.trim(),
        dateOfBirth: _dateOfBirth,
        dateOfJoining: _trainingStartDate,
        wfh: _wfh,
        aadharFiles: _aadharFiles,
      );
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Trainee added successfully', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Add New Trainee',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF64748B)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF1F5F9), height: 1),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
        : Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name *',
                    hint: 'e.g. John Doe',
                    icon: Icons.person_outline,
                    isRequired: true,
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: [ProperCaseTextFormatter()],
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _mobileController,
                    label: 'Mobile Number *',
                    hint: '10 digit number',
                    icon: Icons.phone_android_outlined,
                    isRequired: true,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Mobile required';
                      if (value.length != 10) return 'Must be 10 digits';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address *',
                    hint: 'official email',
                    icon: Icons.alternate_email_outlined,
                    isRequired: true,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Email required';
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) return 'Invalid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildDatePicker(
                    label: 'Date of Birth *',
                    value: _dateOfBirth,
                    onTap: _selectDateOfBirth,
                    validator: (v) => v == null ? 'Selection required' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildDatePicker(
                    label: 'Training Start Date *',
                    value: _trainingStartDate,
                    onTap: _selectTrainingStartDate,
                    validator: (v) => v == null ? 'Selection required' : null,
                  ),
                  const SizedBox(height: 24),
                  
                  // Aadhar Card Attach Section
                  _buildAttachmentSection(
                    files: _aadharFiles,
                    onAdd: _pickAadharFiles,
                    onRemove: (idx) => setState(() => _aadharFiles.removeAt(idx)),
                    validator: (v) => (v == null || v.isEmpty) ? 'Attachment required' : null,
                  ),
                  
                  const SizedBox(height: 24),
                  _buildSwitchField(
                    label: 'Allow Work From Home',
                    icon: Icons.home_work_outlined,
                    value: _wfh,
                    onChanged: (value) => setState(() => _wfh = value),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveEmployee,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Create Account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Account will be sent for BH approval',
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildAttachmentSection({
    required List<XFile> files,
    required VoidCallback onAdd,
    required Function(int) onRemove,
    String? Function(List<XFile>?)? validator,
  }) {
    return FormField<List<XFile>>(
      initialValue: files,
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attachment_outlined, size: 18, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Text(
                  'Attach Aadhar Card *',
                  style: TextStyle(
                    fontSize: 13, 
                    fontWeight: FontWeight.w600, 
                    color: state.hasError ? const Color(0xFFEF4444) : const Color(0xFF64748B)
                  ),
                ),
                const Spacer(),
                Text(
                  '${files.length}/2',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                onAdd();
                state.didChange(files);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: state.hasError ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0),
                    width: state.hasError ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 20, color: files.length >= 2 ? Colors.grey : const Color(0xFF3B82F6)),
                    const SizedBox(width: 10),
                    Text(
                      files.isEmpty ? 'Upload images (Front & Back)' : 'Add more files',
                      style: TextStyle(
                        fontSize: 13, 
                        fontWeight: FontWeight.w600, 
                        color: files.length >= 2 ? Colors.grey : const Color(0xFF3B82F6)
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (state.hasError) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(state.errorText!, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
              ),
            ],
            if (files.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: files.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final file = entry.value;
                  return Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          image: DecorationImage(
                            image: FileImage(File(file.path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: InkWell(
                          onTap: () {
                            onRemove(idx);
                            state.didChange(files);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ],
        );
      }
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
        ),
        errorStyle: const TextStyle(fontSize: 12),
      ),
      validator: isRequired && validator == null 
        ? (value) => value == null || value.trim().isEmpty ? 'Required' : null
        : validator,
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? value,
    required Future<DateTime?> Function() onTap,
    String? Function(DateTime?)? validator,
  }) {
    return FormField<DateTime>(
      initialValue: value,
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                final picked = await onTap();
                if (picked != null) {
                  state.didChange(picked);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(
                    color: state.hasError ? const Color(0xFFEF4444) : const Color(0xFF64748B), 
                    fontSize: 13, 
                    fontWeight: FontWeight.w500
                  ),
                  prefixIcon: Icon(
                    Icons.calendar_today_outlined, 
                    size: 18, 
                    color: state.hasError ? const Color(0xFFEF4444) : const Color(0xFF64748B)
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: state.hasError ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: state.hasError ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: state.hasError ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                  ) : null,
                  errorStyle: const TextStyle(height: 0), // Use manual error text for better control
                ),
                child: Text(
                  value == null ? 'Select date' : '${value.day}/${value.month}/${value.year}',
                  style: TextStyle(fontSize: 14, color: value == null ? const Color(0xFF94A3B8) : const Color(0xFF1E293B)),
                ),
              ),
            ),
            if (state.hasError) ...[
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 12),
                child: Text(state.errorText!, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
              ),
            ],
          ],
        );
      }
    );
  }

  Widget _buildSwitchField({
    required String label,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF64748B)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
              ),
            ),
            // Custom Square Toggle Switch
            Container(
              width: 40,
              height: 22,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: value ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    left: value ? 18 : 0,
                    right: value ? 0 : 18,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
