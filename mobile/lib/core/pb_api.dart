import 'dart:convert';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_logger.dart';
import 'config_service.dart';
import '../services/device_info_service.dart';
import '../services/profile_service.dart';
import '../services/fcm_service.dart';

class PB {
  PB._();

  static late PocketBase pb;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    pb = PocketBase(ConfigService.baseUrl);

    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('pb_token');
    final savedModel = prefs.getString('pb_model');

    if (savedToken != null && savedModel != null) {
      try {
        pb.authStore.save(savedToken, RecordModel.fromJson(jsonDecode(savedModel)));
        if (pb.authStore.isValid && pb.authStore.record != null) {
          final user = pb.authStore.record!;
          AppLogger.setUserScope(
            id: user.id,
            email: user.data['email']?.toString(),
            name: user.data['name']?.toString(),
            role: user.data['role']?.toString(),
          );
        }
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
            AppLogger.setUserScope(
              id: model.id,
              email: model.data['email']?.toString(),
              name: model.data['name']?.toString(),
              role: model.data['role']?.toString(),
            );
          }
        } else {
          await prefs.remove('pb_token');
          await prefs.remove('pb_model');
          AppLogger.clearUserScope();
        }
      } catch (_) {}
    });

    _initialized = true;
  }

  static Future<void> logout() async {
    pb.authStore.clear();
    AppLogger.clearUserScope();
    await FCMService.clearToken();
    await ProfileService.clearFcmToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pb_token');
    await prefs.remove('pb_model');
  }

  /// Global Error Handler: Instant logout for 400, 401, 403 errors, log server errors
  static void handleAuthError(dynamic e, [StackTrace? stackTrace]) {
    if (e is ClientException) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        logout();
      } else if (e.statusCode >= 500) {
        AppLogger.captureException(e, stackTrace: stackTrace, tag: 'PocketBaseServerError');
      }
    } else if (e != null) {
      AppLogger.captureException(e, stackTrace: stackTrace, tag: 'PocketBaseError');
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
