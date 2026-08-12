import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/pb_api.dart';
import '../services/device_info_service.dart';
import '../services/whatsapp_launcher_service.dart';

class SecurityAuthDialog extends StatefulWidget {
  final String todayStr;

  const SecurityAuthDialog({
    super.key,
    required this.todayStr,
  });

  @override
  State<SecurityAuthDialog> createState() => _SecurityAuthDialogState();
}

class _SecurityAuthDialogState extends State<SecurityAuthDialog> with WidgetsBindingObserver {
  bool _isChecking = false;
  bool _hasLaunchedWhatsApp = false;
  String? _statusError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _hasLaunchedWhatsApp && !_isChecking) {
      _checkServerAuth();
    }
  }

  Future<void> _handleAuthorize() async {
    await DeviceInfoService.ensureInitialized();
    final deviceId = DeviceInfoService.deviceId ?? 'device';
    final empCode = PB.pb.authStore.record?.data['employee_code'] ?? 'EMP';
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

    final text = 'AUTHORIZE_DEVICE:$empCode:$deviceId:$timestamp';

    setState(() {
      _hasLaunchedWhatsApp = true;
      _statusError = null;
    });

    final launched = await WhatsAppLauncherService.launchWhatsApp(
      context: context,
      text: text,
    );

    if (!launched && mounted) {
      setState(() => _statusError = 'Could not open WhatsApp');
    }
  }

  Future<void> _checkServerAuth() async {
    await DeviceInfoService.ensureInitialized();
    final deviceId = DeviceInfoService.deviceId ?? 'device';

    setState(() => _isChecking = true);

    try {
      final res = await PB.pb.send(
        '/api/auth/check-daily-auth?device_id=$deviceId&cycle=${widget.todayStr}',
        method: 'GET',
      );

      if (!mounted) return;

      final isAuthorized = res is Map && res['authorized'] == true;

      if (isAuthorized) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_security_verification_date', widget.todayStr);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session Authorized Successfully!'),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() {
          _statusError = 'Authorization pending. Please send the WhatsApp message from your registered mobile number.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _statusError = 'Could not verify status. Please check your connection and retry.';
        });
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    size: 42,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Security Check',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Please authorize your device to continue to your workspace.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ),
                if (_statusError != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade300.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.info_outline, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _statusError!,
                            style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _isChecking ? null : _handleAuthorize,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E3A8A),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_user_outlined, size: 18),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _hasLaunchedWhatsApp ? 'Open WhatsApp Again' : 'Allow Login',
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_hasLaunchedWhatsApp) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton(
                      onPressed: _isChecking ? null : _checkServerAuth,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white60),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isChecking
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Flexible(
                              child: Text(
                                'I have sent the message',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
