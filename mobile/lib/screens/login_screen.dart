import 'package:flutter/material.dart';
import '../core/pb_api.dart';
import '../screens/employee_dashboard.dart';
import '../screens/manager_dashboard.dart';
import '../services/login_case_service.dart';
import '../services/fcm_service.dart';
import '../services/lead_service.dart';
import '../services/lead_feedback_service.dart';
import '../services/attendance_service.dart';
import '../services/leave_service.dart';
import '../services/holiday_service.dart';
import '../services/profile_service.dart';
import '../services/apply_link_service.dart';
import '../services/device_registration_service.dart';
import '../screens/change_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final headers = await PB.getDeviceHeaders();

      final auth = await PB.pb.collection("users").authWithPassword(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
        headers: headers,
      );

      if (!mounted) return;

      final role = (auth.record.data["role"] ?? "").toString().toLowerCase();

      LoginCaseService.initializeRealtime();
      
       try {
         await FCMService.initialize();
       } catch (e, stackTrace) {
         print('[LoginScreen] FCM init error: $e');
         print(stackTrace);
       }

       // Register device info (device_id, app_version, permissions, fcm_token)
       try {
         await DeviceRegistrationService.register();
       } catch (e, stackTrace) {
         print('[LoginScreen] Device registration error: $e');
         print(stackTrace);
       }

       _performBackgroundSync();

      // Force Password Change Check
      if (auth.record.data["must_change_password"] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
        );
        return;
      }

      if (role == "employee") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EmployeeDashboard()),
        );
      } else if (role == "manager") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ManagerDashboard()),
        );
      } else {
        _showError("Unknown role. Please contact administrator.");
      }
     } catch (e) {
       if (!mounted) return;
       
       String errorMsg = "Invalid username or password";
       if (e.toString().contains("Mobile Device ID is missing") || 
           e.toString().contains("bonded to another device") ||
           e.toString().contains("already registered to another user")) {
         errorMsg = "Your account is already registered to another device. "
             "If you changed your phone, contact your manager.";
       } else if (e.toString().contains("Device ID is required") ||
                  e.toString().contains("device bonding")) {
         errorMsg = "Device registration is required. Please enable device identification.";
       }
       
       _showError(errorMsg);
     } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 48.0 : 24.0,
                    vertical: 32.0,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Image.asset(
                            'assets/images/login.png',
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFDADCE0),
                              width: 1,
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Sign in to continue',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF202124),
                                    letterSpacing: 0,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                TextFormField(
                                  controller: _usernameController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF202124),
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Email or username',
                                    labelStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF5F6368),
                                    ),
                                    floatingLabelStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF1A73E8),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFDADCE0),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFDADCE0),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF1A73E8),
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFD93025),
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFD93025),
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter your email or username';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _handleLogin(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF202124),
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF5F6368),
                                    ),
                                    floatingLabelStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF1A73E8),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: const Color(0xFF5F6368),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() => _obscurePassword = !_obscurePassword);
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFDADCE0),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFDADCE0),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF1A73E8),
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFD93025),
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFD93025),
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter your password';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 32),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      height: 40,
                                      child: ElevatedButton(
                                        onPressed: _isLoading ? null : _handleLogin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF1A73E8),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          disabledBackgroundColor: const Color(0xFFDADCE0),
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                height: 16,
                                                width: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                                ),
                                              )
                                            : const Text(
                                                'Sign in',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.25,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          '© ${DateTime.now().year} Credlawn. All rights reserved.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5F6368),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

void _performBackgroundSync() async {
  try {
    await ProfileService.refreshProfile();
    
    await LeadService.syncUp();
    await LeadFeedbackService.syncUp();
    await AttendanceService.syncUp();
    await LeaveService.syncUp();
    
    await LeadService.syncDown(silent: true);
    await LeadFeedbackService.syncDown();
    await AttendanceService.syncDown();
    await LeaveService.syncDown();
    await HolidayService.syncDown();
    await LoginCaseService.syncFromServer();
    await ApplyLinkService.syncDown();
  } catch (e) {}
}
