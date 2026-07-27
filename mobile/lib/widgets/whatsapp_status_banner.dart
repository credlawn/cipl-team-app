import 'package:flutter/material.dart';
import '../core/pb_api.dart';

class WhatsAppStatusBanner extends StatefulWidget {
  const WhatsAppStatusBanner({super.key});

  @override
  State<WhatsAppStatusBanner> createState() => _WhatsAppStatusBannerState();
}

class _WhatsAppStatusBannerState extends State<WhatsAppStatusBanner> {
  bool _isLoading = true;
  String _status = 'error'; // 'active', 'idle', 'error'
  String _message = 'Checking WhatsApp API Status...';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await PB.pb.send('/api/whatsapp/status');
      if (mounted && response is Map<String, dynamic>) {
        final status = response['status'] as String? ?? 'error';
        final details = response['details'] as List<dynamic>? ?? [];

        String subtitle = 'Outbound messages and real-time inbox status check.';
        if (status == 'active') {
          subtitle = 'Outbound messages and real-time inbox are active.';
        } else if (status == 'idle') {
          subtitle = 'Inbox is active, no recent customer messages.';
        } else {
          if (details.isNotEmpty) {
            subtitle = details.first.toString();
          } else {
            subtitle = 'Webhook subscription is missing or invalid in Meta console.';
          }
        }

        setState(() {
          _status = status;
          _message = subtitle;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'error';
          _message = 'Failed to check connection status: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade500.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Checking WhatsApp API status...',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Color bannerColor;
    Color borderColor;
    Color iconColor;
    IconData icon;
    String titleText;

    if (_status == 'active') {
      bannerColor = const Color(0xFF25D366).withValues(alpha: 0.1);
      borderColor = const Color(0xFF25D366).withValues(alpha: 0.2);
      iconColor = const Color(0xFF25D366);
      icon = Icons.check_circle_rounded;
      titleText = 'WhatsApp API Connected';
    } else if (_status == 'idle') {
      bannerColor = const Color(0xFFF59E0B).withValues(alpha: 0.1);
      borderColor = const Color(0xFFF59E0B).withValues(alpha: 0.2);
      iconColor = const Color(0xFFF59E0B);
      icon = Icons.check_circle_rounded; // Show check circle for idle too since config is good
      titleText = 'WhatsApp API Connected';
    } else {
      bannerColor = const Color(0xFFEF4444).withValues(alpha: 0.1);
      borderColor = const Color(0xFFEF4444).withValues(alpha: 0.2);
      iconColor = const Color(0xFFEF4444);
      icon = Icons.error_outline_rounded;
      titleText = 'WhatsApp Connection Error';
    }

    return GestureDetector(
      onTap: _checkStatus,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bannerColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleText,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _message,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.refresh_rounded, color: iconColor.withValues(alpha: 0.6), size: 16),
          ],
        ),
      ),
    );
  }
}
