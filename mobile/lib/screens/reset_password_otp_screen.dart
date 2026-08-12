import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/config_service.dart';
import '../core/pb_api.dart';
import '../services/whatsapp_launcher_service.dart';

class ResetPasswordOtpScreen extends StatefulWidget {
  final String deviceId;

  const ResetPasswordOtpScreen({
    super.key,
    required this.deviceId,
  });

  @override
  State<ResetPasswordOtpScreen> createState() => _ResetPasswordOtpScreenState();
}

class _ResetPasswordOtpScreenState extends State<ResetPasswordOtpScreen> {
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleReopenWhatsApp() async {
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final text = 'RESET_PASSWORD:${widget.deviceId}:$timestamp';

    await WhatsAppLauncherService.launchWhatsApp(
      context: context,
      text: text,
    );
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final otp = _otpController.text.trim();
    final newPass = _passwordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (newPass != confirmPass) {
      _showError('Passwords do not match');
      return;
    }

    if (newPass == 'Cred@2026') {
      _showError('You cannot use the default password. Please choose a unique password.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await PB.pb.send(
        '/api/auth/reset-password-otp',
        method: 'POST',
        body: {
          'device_id': widget.deviceId,
          'otp': otp,
          'password': newPass,
          'password_confirm': confirmPass,
        },
      );

      if (!mounted) return;

      final success = response is Map && response['success'] == true;
      final message = response is Map && response['message'] != null
          ? response['message'].toString()
          : 'Password reset successfully! Please sign in with your new password.';

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );

        Navigator.pop(context);
      } else {
        _showError(response is Map && response['error'] != null ? response['error'].toString() : 'Failed to reset password');
      }
    } catch (e) {
      if (!mounted) return;
      String errorMsg = 'Failed to reset password. Please verify the OTP.';
      final errStr = e.toString();

      if (errStr.contains('Invalid or expired OTP')) {
        errorMsg = 'Invalid or expired OTP. Please request a new OTP via WhatsApp.';
      } else if (errStr.contains('Device ID is required')) {
        errorMsg = 'Device identification failed. Please restart the app.';
      } else if (errStr.contains('Password must')) {
        errorMsg = errStr.replaceAll(RegExp(r'.*data:\s*\{[^}]*error:\s*([^,}]+).*'), r'\1').replaceAll('"', '');
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
        backgroundColor: const Color(0xFFD93025),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF202124)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reset Password',
          style: TextStyle(
            color: Color(0xFF202124),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Container(
                padding: const EdgeInsets.all(32),
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
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FE),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_reset,
                            size: 36,
                            color: Color(0xFF1A73E8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'Enter Verification Code',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF202124),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'We sent a 6-digit OTP to your registered WhatsApp. Enter the code and set your new password.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF5F6368),
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // OTP Input Field
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        maxLength: 6,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6,
                          color: Color(0xFF202124),
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: '6-Digit OTP',
                          counterText: '',
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            letterSpacing: 0,
                            color: Color(0xFF5F6368),
                          ),
                          floatingLabelStyle: const TextStyle(
                            fontSize: 14,
                            letterSpacing: 0,
                            color: Color(0xFF1A73E8),
                          ),
                          prefixIcon: const Icon(Icons.security, color: Color(0xFF5F6368), size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: Color(0xFFDADCE0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length != 6) {
                            return 'Please enter the complete 6-digit OTP';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // New Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(fontSize: 15, color: Color(0xFF202124)),
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF5F6368)),
                          floatingLabelStyle: const TextStyle(fontSize: 14, color: Color(0xFF1A73E8)),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF5F6368), size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: const Color(0xFF5F6368),
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: Color(0xFFDADCE0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter a new password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return 'Must include at least one uppercase letter (A-Z)';
                          }
                          if (!RegExp(r'[a-z]').hasMatch(value)) {
                            return 'Must include at least one lowercase letter (a-z)';
                          }
                          if (!RegExp(r'[0-9]').hasMatch(value)) {
                            return 'Must include at least one number (0-9)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleResetPassword(),
                        style: const TextStyle(fontSize: 15, color: Color(0xFF202124)),
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF5F6368)),
                          floatingLabelStyle: const TextStyle(fontSize: 14, color: Color(0xFF1A73E8)),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF5F6368), size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: const Color(0xFF5F6368),
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: Color(0xFFDADCE0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleResetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A73E8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            disabledBackgroundColor: const Color(0xFFDADCE0),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Reset Password',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.25,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Reopen WhatsApp Button
                      Center(
                        child: TextButton.icon(
                          onPressed: _handleReopenWhatsApp,
                          icon: const Icon(Icons.refresh, size: 16, color: Color(0xFF1A73E8)),
                          label: const Text(
                            "Didn't receive OTP? Open WhatsApp",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1A73E8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
