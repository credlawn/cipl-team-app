import 'dart:convert';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/device_info_service.dart';
import '../services/profile_service.dart';
import '../services/fcm_service.dart';

class PB {
  PB._();

  static final PocketBase pb = PocketBase('https://app.cipl.me'); // LIVE SERVER
  // static final PocketBase pb = PocketBase('http://192.168.29.184:8090'); // LOCAL TESTING
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('pb_token');
    final savedModel = prefs.getString('pb_model');

    if (savedToken != null && savedModel != null) {
      try {
        pb.authStore.save(savedToken, RecordModel.fromJson(jsonDecode(savedModel)));
      } catch (_) {
        await prefs.remove('pb_token');
        await prefs.remove('pb_model');
      }
    }

    pb.authStore.onChange.listen((event) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        if (pb.authStore.isValid) {
          await prefs.setString('pb_token', pb.authStore.token);
          final model = pb.authStore.model;
          if (model is RecordModel) {
            await prefs.setString('pb_model', jsonEncode(model.toJson()));
          }
        } else {
          await prefs.remove('pb_token');
          await prefs.remove('pb_model');
        }
      } catch (_) {}
    });

    _initialized = true;
  }

  static Future<void> logout() async {
    pb.authStore.clear();
    await FCMService.clearToken();
    await ProfileService.clearFcmToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pb_token');
    await prefs.remove('pb_model');
  }

  /// Global Error Handler: Instant logout for 400, 401, 403 errors
  static void handleAuthError(dynamic e) {
    if (e is ClientException) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        logout();
      }
    }
  }

  /// Get device headers for API requests (delegates to DeviceInfoService)
  static Future<Map<String, String>> getDeviceHeaders() async {
    await DeviceInfoService.ensureInitialized();
    final info = await DeviceInfoService.getDeviceInfo();
    return {
      'X-Device-Id': info['device_id'] ?? '',
      'X-Device-Model': info['model'] ?? '',
      'X-Android-Version': info['os_version'] ?? '',
    };
  }
}
