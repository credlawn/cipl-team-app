import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/config_service.dart';

enum WhatsAppType { standard, business }

/// Smart WhatsApp Launcher with dynamic app detection (Standard vs Business)
class WhatsAppLauncherService {
  WhatsAppLauncherService._();

  /// Launches WhatsApp with smart single-app bypass or dual-app chooser
  static Future<bool> launchWhatsApp({
    required BuildContext context,
    required String text,
    String? phone,
  }) async {
    final targetPhone = phone ?? ConfigService.companyWhatsAppNumber;
    final encodedText = Uri.encodeComponent(text);

    final standardIntentUrl = 'intent://send?phone=$targetPhone&text=$encodedText#Intent;package=com.whatsapp;scheme=whatsapp;end';
    final businessIntentUrl = 'intent://send?phone=$targetPhone&text=$encodedText#Intent;package=com.whatsapp.w4b;scheme=whatsapp;end';
    final standardSchemeUrl = 'whatsapp://send?phone=$targetPhone&text=$encodedText';
    final fallbackUrl = 'https://wa.me/$targetPhone?text=$encodedText';

    bool hasStandard = false;
    bool hasBusiness = false;

    try {
      hasStandard = await canLaunchUrl(Uri.parse(standardIntentUrl)) ||
          await canLaunchUrl(Uri.parse(standardSchemeUrl));
    } catch (_) {}

    try {
      hasBusiness = await canLaunchUrl(Uri.parse(businessIntentUrl));
    } catch (_) {}

    // Case 1: Both installed -> Show chooser BottomSheet
    if (hasStandard && hasBusiness) {
      if (!context.mounted) return false;
      final selected = await _showAppChooser(context);
      if (selected == null) return false; // User dismissed

      if (selected == WhatsAppType.business) {
        final ok = await _launchUri(businessIntentUrl);
        if (ok) return true;
        return _launchUri(fallbackUrl);
      } else {
        final ok = await _launchUri(standardIntentUrl);
        if (ok) return true;
        final okScheme = await _launchUri(standardSchemeUrl);
        if (okScheme) return true;
        return _launchUri(fallbackUrl);
      }
    }

    // Case 2: Only Business installed -> Direct launch (0 extra clicks)
    if (hasBusiness && !hasStandard) {
      final ok = await _launchUri(businessIntentUrl);
      if (ok) return true;
      return _launchUri(fallbackUrl);
    }

    // Case 3: Only Standard installed -> Direct launch (0 extra clicks)
    if (hasStandard && !hasBusiness) {
      final ok = await _launchUri(standardIntentUrl);
      if (ok) return true;
      final okScheme = await _launchUri(standardSchemeUrl);
      if (okScheme) return true;
      return _launchUri(fallbackUrl);
    }

    // Case 4: Fallback to Universal Link (https://wa.me)
    final launchedFallback = await _launchUri(fallbackUrl);
    if (launchedFallback) return true;

    // Case 5: Neither available -> Show alert
    if (context.mounted) {
      _showNotInstalledDialog(context);
    }
    return false;
  }

  static Future<bool> _launchUri(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    return false;
  }

  static Future<WhatsAppType?> _showAppChooser(BuildContext context) {
    return showModalBottomSheet<WhatsAppType>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose WhatsApp Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select the app with your official CIPL registered number:',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF16A34A), size: 22),
                ),
                title: const Text(
                  'WhatsApp',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1E293B)),
                ),
                subtitle: const Text('Regular / Personal account', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF94A3B8)),
                onTap: () => Navigator.pop(ctx, WhatsAppType.standard),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.business_center_outlined, color: Color(0xFF2563EB), size: 22),
                ),
                title: const Text(
                  'WhatsApp Business',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1E293B)),
                ),
                subtitle: const Text('Business account', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF94A3B8)),
                onTap: () => Navigator.pop(ctx, WhatsAppType.business),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  static void _showNotInstalledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'WhatsApp Not Available',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          'WhatsApp is not installed on this device. Please install WhatsApp to proceed, or contact HR for assistance.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: Color(0xFF1A73E8), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
