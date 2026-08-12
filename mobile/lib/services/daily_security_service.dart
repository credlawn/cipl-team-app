import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/pb_api.dart';
import '../widgets/security_auth_dialog.dart';

/// Manages daily enterprise device authorization and WhatsApp 24-hour window session
/// with a 9:00 AM workday cycle cutoff.
class DailySecurityService {
  DailySecurityService._();

  static const String _keyLastVerificationDate = 'last_security_verification_date';

  /// Calculates the business cycle key with a 9:00 AM workday boundary.
  /// Any time at or after 9:00 AM starts today's cycle.
  /// Time before 9:00 AM falls back to the previous day's cycle.
  static String getCycleKey([DateTime? date]) {
    final now = date ?? DateTime.now();
    if (now.hour >= 9) {
      return DateFormat('yyyy-MM-dd').format(now);
    } else {
      final previousDay = now.subtract(const Duration(days: 1));
      return DateFormat('yyyy-MM-dd').format(previousDay);
    }
  }

  /// Checks if daily security authorization is needed and presents the Allow Login dialog
  static Future<void> checkDailyVerification(BuildContext context) async {
    try {
      final user = PB.pb.authStore.record;
      if (user == null) return;

      final currentCycle = getCycleKey();
      final prefs = await SharedPreferences.getInstance();
      final lastCycle = prefs.getString(_keyLastVerificationDate);

      if (lastCycle == currentCycle) {
        // Already authorized for the current 9:00 AM workday cycle
        return;
      }

      if (!context.mounted) return;

      // Ensure frame rendered before opening dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => SecurityAuthDialog(todayStr: currentCycle),
          );
        }
      });
    } catch (_) {
      // Fail safely to not block user access
    }
  }
}
