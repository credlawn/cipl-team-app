import 'package:flutter/material.dart';
import '../core/pb_api.dart';
import 'login_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Future<void> _changePassword() async {
    final oldPass = _oldPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (oldPass.isEmpty) {
      _showError('Please enter your current password');
      return;
    }

    // New Validation Rules
    final uppercaseRegex = RegExp(r'[A-Z]');
    final lowercaseRegex = RegExp(r'[a-z]');
    final numberRegex = RegExp(r'[0-9]');

    if (newPass.length < 8) {
      _showError('Password must be at least 8 characters long');
      return;
    }

    if (!uppercaseRegex.hasMatch(newPass)) {
      _showError('Include at least one uppercase letter (A-Z)');
      return;
    }

    if (!lowercaseRegex.hasMatch(newPass)) {
      _showError('Include at least one lowercase letter (a-z)');
      return;
    }

    if (!numberRegex.hasMatch(newPass)) {
      _showError('Include at least one number (0-9)');
      return;
    }

    if (newPass != confirmPass) {
      _showError('Passwords do not match');
      return;
    }

    if (newPass == 'Cred@2026') {
      _showError('You cannot use the default password. Please choose a unique one.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = PB.pb.authStore.record;
      if (user == null) return;

      // Update password AND set must_change_password = false
      await PB.pb.collection('users').update(user.id, body: {
        'oldPassword': oldPass,
        'password': newPass,
        'passwordConfirm': confirmPass,
        'must_change_password': false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully! Please login again with your new password.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Forced Logout after password change (to re-authenticate with new credentials)
        await PB.logout();
        
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Something went wrong while changing your password.';
        
        // Human-friendly parsing for PocketBase errors
        final errorStr = e.toString();
        if (errorStr.contains('oldPassword')) {
          errorMessage = 'The current password you entered is incorrect. Please try again.';
        } else if (errorStr.contains('passwordConfirm')) {
          errorMessage = 'Password confirmation does not match.';
        } else if (errorStr.contains('password')) {
          errorMessage = 'New password is not secure enough. Please use a stronger password.';
        }

        _showError(errorMessage);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Disables back button and swipe to go back
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A73E8).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.security_rounded, color: Color(0xFF1A73E8), size: 40),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Security Update',
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.w400, 
                        color: Color(0xFF202124),
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'For your security, please update your password. Your new password must be at least 8 characters long and include an uppercase letter (A-Z), a lowercase letter (a-z), and a number (0-9).',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF5F6368), 
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Input Fields
                    _buildField(
                      controller: _oldPasswordController,
                      label: 'Current Password',
                      obscure: _obscureOld,
                      onToggle: () => setState(() => _obscureOld = !_obscureOld),
                    ),
                    const SizedBox(height: 24),
                    _buildField(
                      controller: _newPasswordController,
                      label: 'New Password',
                      obscure: _obscureNew,
                      onToggle: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                    const SizedBox(height: 24),
                    _buildField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      obscure: _obscureConfirm,
                      onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    
                    const SizedBox(height: 40),

                    // Submit Button (Google Style)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A73E8),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Update Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 16, color: Color(0xFF202124)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 16, color: Color(0xFF5F6368)),
        floatingLabelStyle: const TextStyle(fontSize: 16, color: Color(0xFF1A73E8)),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, 
            color: const Color(0xFF5F6368),
            size: 20,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFDADCE0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFDADCE0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

class RoundedRectangleType extends RoundedRectangleBorder {
  const RoundedRectangleType({super.borderRadius});
}
