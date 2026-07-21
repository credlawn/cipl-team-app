import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/employee_service.dart';
import '../core/pb_api.dart';
import '../utils/proper_case_text_formatter.dart';

class BHEditEmployeeScreen extends StatefulWidget {
  final Map<String, dynamic> employee;

  const BHEditEmployeeScreen({
    super.key,
    required this.employee,
  });

  @override
  State<BHEditEmployeeScreen> createState() => _BHEditEmployeeScreenState();
}

class _BHEditEmployeeScreenState extends State<BHEditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _designationController;
  late TextEditingController _departmentController;
  late TextEditingController _verticalController;
  late TextEditingController _leaveBalanceController;
  late TextEditingController _salaryController;
  
  // State
  DateTime? _dateOfBirth;
  DateTime? _dateOfJoining;
  DateTime? _payrollStartDate;
  DateTime? _lastWorkingDate;
  bool _wfh = false;
  bool _disabled = false;
  bool _noAtn = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _parseData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.employee['employee_name']?.toString() ?? '');
    _codeController = TextEditingController(text: widget.employee['employee_code']?.toString() ?? '');
    _mobileController = TextEditingController(text: widget.employee['mobile_no']?.toString() ?? '');
    _emailController = TextEditingController(text: widget.employee['email']?.toString() ?? '');
    _designationController = TextEditingController(text: widget.employee['designation']?.toString() ?? '');
    _departmentController = TextEditingController(text: widget.employee['department']?.toString() ?? '');
    _verticalController = TextEditingController(text: widget.employee['vertical']?.toString() ?? '');
    _leaveBalanceController = TextEditingController(text: widget.employee['paid_leave_balance']?.toString() ?? '0');
    _salaryController = TextEditingController(text: widget.employee['salary']?.toString() ?? '0');
  }

  void _parseData() {
    _wfh = widget.employee['wfh'] == true;
    _disabled = widget.employee['disabled'] == true;
    _noAtn = widget.employee['no_atn'] == true;
    
    _dateOfBirth = _parseDate(widget.employee['date_of_birth']);
    _dateOfJoining = _parseDate(widget.employee['date_of_joining']);
    _payrollStartDate = _parseDate(widget.employee['payroll_start_date']);
    _lastWorkingDate = _parseDate(widget.employee['last_working_date']);
  }

  DateTime? _parseDate(dynamic dateStr) {
    if (dateStr == null || dateStr.toString().isEmpty) return null;
    try {
      return DateTime.parse(dateStr.toString());
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _designationController.dispose();
    _departmentController.dispose();
    _verticalController.dispose();
    _leaveBalanceController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(String field) async {
    DateTime? initialDate;
    DateTime firstDate = DateTime(1960);
    DateTime lastDate = DateTime(2100);
    
    switch (field) {
      case 'dob':
        initialDate = _dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 25));
        lastDate = DateTime.now();
        break;
      case 'doj':
        initialDate = _dateOfJoining ?? DateTime.now();
        break;
      case 'payroll':
        initialDate = _payrollStartDate ?? DateTime.now();
        break;
      case 'last_working':
        initialDate = _lastWorkingDate ?? DateTime.now();
        break;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
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
      setState(() {
        switch (field) {
          case 'dob':
            _dateOfBirth = picked;
            break;
          case 'doj':
            _dateOfJoining = picked;
            break;
          case 'payroll':
            _payrollStartDate = picked;
            break;
          case 'last_working':
            _lastWorkingDate = picked;
            break;
        }
      });
    }
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      final mobile = _mobileController.text.trim();
      final email = _emailController.text.trim();
      
      // Check duplicate mobile
      if (mobile != widget.employee['mobile_no']?.toString()) {
        if (await EmployeeService.isMobileExists(mobile)) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mobile number already exists'), backgroundColor: Color(0xFFEF4444)),
          );
          return;
        }
      }
      
      // Check duplicate email
      if (email.isNotEmpty && email != widget.employee['email']?.toString()) {
        if (await EmployeeService.isEmailExists(email)) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email address already exists'), backgroundColor: Color(0xFFEF4444)),
          );
          return;
        }
      }
      final data = <String, dynamic>{
        'employee_name': _nameController.text.trim(),
        'employee_code': _codeController.text.trim(),
        'mobile_no': _mobileController.text.trim(),
        'username': _mobileController.text.trim(),
        'email': _emailController.text.trim(),
        'designation': _designationController.text.trim(),
        'department': _departmentController.text.trim(),
        'vertical': _verticalController.text.trim(),
        'paid_leave_balance': int.tryParse(_leaveBalanceController.text) ?? 0,
        'salary': _salaryController.text.trim(),
        'wfh': _wfh,
        'disabled': _disabled,
        'no_atn': _noAtn,
      };

      data['date_of_birth'] = _dateOfBirth == null 
          ? '' 
          : DateTime.utc(_dateOfBirth!.year, _dateOfBirth!.month, _dateOfBirth!.day, 12, 0, 0).toIso8601String();
      data['date_of_joining'] = _dateOfJoining == null 
          ? '' 
          : DateTime.utc(_dateOfJoining!.year, _dateOfJoining!.month, _dateOfJoining!.day, 12, 0, 0).toIso8601String();
      data['payroll_start_date'] = _payrollStartDate == null 
          ? '' 
          : DateTime.utc(_payrollStartDate!.year, _payrollStartDate!.month, _payrollStartDate!.day, 12, 0, 0).toIso8601String();
      data['last_working_date'] = _lastWorkingDate == null 
          ? '' 
          : DateTime.utc(_lastWorkingDate!.year, _lastWorkingDate!.month, _lastWorkingDate!.day, 12, 0, 0).toIso8601String();

      await PB.pb.collection('users').update(widget.employee['id'], body: data);

      if (!mounted) return;
      
      final isTrainee = _designationController.text == 'Trainee';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text('${isTrainee ? 'Trainee' : 'Employee'} updated successfully', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(e.toString().replaceAll('Exception: ', ''), style: const TextStyle(fontSize: 14))),
            ],
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
    final designation = widget.employee['designation']?.toString() ?? '';
    final title = designation == 'Trainee' ? 'Edit Trainee' : 'Edit Employee';
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
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
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                _buildTextField('Full Name *', _nameController, Icons.person_outline, required: true, formatters: [ProperCaseTextFormatter()]),
                const SizedBox(height: 12),
                _buildTextField('Employee Code *', _codeController, Icons.badge_outlined, required: true),
                const SizedBox(height: 12),
                _buildTextField('Mobile Number *', _mobileController, Icons.phone_android_outlined, required: true, keyboardType: TextInputType.phone, formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)], 
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Required';
                    if (val.trim().length != 10) return 'Must be 10 digits';
                    return null;
                  }
                ),
                const SizedBox(height: 12),
                _buildTextField('Email Address *', _emailController, Icons.alternate_email_outlined, required: true, keyboardType: TextInputType.emailAddress,
                  readOnly: true,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Required';
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(val.trim())) return 'Invalid email format';
                    return null;
                  }
                ),
                
                const SizedBox(height: 24),
                _buildDropdownField(
                  'Designation', 
                  _designationController.text, 
                  Icons.work_outline, 
                  ['Trainee', 'Relationship Executive'],
                  (val) => setState(() => _designationController.text = val!),
                ),
                const SizedBox(height: 12),
                _buildTextField('Department', _departmentController, Icons.business_outlined),
                const SizedBox(height: 12),
                _buildTextField('Vertical', _verticalController, Icons.category_outlined),
                
                const SizedBox(height: 24),
                _buildDateField('Date of Birth', _dateOfBirth, 'dob'),
                const SizedBox(height: 12),
                _buildDateField('Date of Joining', _dateOfJoining, 'doj'),
                const SizedBox(height: 12),
                _buildDateField('Payroll Start Date', _payrollStartDate, 'payroll'),
                const SizedBox(height: 12),
                _buildDateField('Last Working Date', _lastWorkingDate, 'last_working'),
                
                const SizedBox(height: 24),
                _buildTextField('Paid Leave Balance', _leaveBalanceController, Icons.event_available, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _buildTextField('In Hand Salary', _salaryController, Icons.currency_rupee, keyboardType: TextInputType.number),
                
                const SizedBox(height: 24),
                _buildSwitchField('Allow Work From Home', Icons.home_work_outlined, _wfh, (val) => setState(() => _wfh = val)),
                const SizedBox(height: 12),
                _buildSwitchField('Account Disabled', Icons.block, _disabled, (val) => setState(() => _disabled = val)),
                const SizedBox(height: 12),
                _buildSwitchField('No Attendance Tracking', Icons.event_busy, _noAtn, (val) => setState(() => _noAtn = val)),
                
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool required = false, TextInputType? keyboardType, List<TextInputFormatter>? formatters, String? Function(String?)? validator, bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      readOnly: readOnly,
      style: TextStyle(fontSize: 14, color: readOnly ? const Color(0xFF64748B) : const Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5)),
      ),
      validator: validator ?? (required ? (val) => val == null || val.trim().isEmpty ? 'Required' : null : null),
    );
  }

  Widget _buildDropdownField(String label, String value, IconData icon, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Theme(
          data: Theme.of(context).copyWith(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
          ),
          child: PopupMenuButton<String>(
            onSelected: onChanged,
            offset: const Offset(1000, 50),
            constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (context) => items.map((e) => PopupMenuItem(
              value: e,
              height: 40,
              child: Text(
                e, 
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
              ),
            )).toList(),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
                suffixIcon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B), size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5)),
              ),
              child: Text(
                value.isEmpty ? 'Select' : value,
                style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, String field) {
    return InkWell(
      onTap: () => _selectDate(field),
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
          prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF64748B)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: Text(
          date == null ? 'Select date' : '${date.day}/${date.month}/${date.year}',
          style: TextStyle(fontSize: 14, color: date == null ? const Color(0xFF94A3B8) : const Color(0xFF1E293B)),
        ),
      ),
    );
  }

  Widget _buildSwitchField(String label, IconData icon, bool value, ValueChanged<bool> onChanged) {
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
