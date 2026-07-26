import 'package:pocketbase/pocketbase.dart';
import '../core/pb_api.dart';
import '../models/profile_model.dart';

class ProfileService {
  static ProfileModel? getProfile() {
    try {
      final record = PB.pb.authStore.record;
      if (record != null) {
        return ProfileModel.fromJson(record.toJson());
      }
    } catch (_) {}
    return null;
  }

  static Future<ProfileModel?> refreshProfile() async {
    try {
      final record = PB.pb.authStore.record;
      if (record == null) return null;

      final refreshed = await PB.pb
          .collection('users')
          .getOne(record.id)
          .timeout(const Duration(seconds: 2));
      
      PB.pb.authStore.save(PB.pb.authStore.token, refreshed);
      
      return ProfileModel.fromJson(refreshed.toJson());
    } catch (e) {
      PB.handleAuthError(e);
      return null;
    }
  }

  static Future<bool> updateFcmToken(
    String fcmToken, {
    String? appVersion,
    String? appPermissionStatus,
  }) async {
    try {
      final record = PB.pb.authStore.record;
      if (record == null) return false;

      final Map<String, dynamic> body = {'fcm_token': fcmToken};
      if (appVersion != null) body['app_version'] = appVersion;
      if (appPermissionStatus != null) body['app_permission_status'] = appPermissionStatus;

      final updated = await PB.pb
          .collection('users')
          .update(record.id, body: body);
      
      PB.pb.authStore.save(PB.pb.authStore.token, updated);
      
      return true;
    } catch (e) {
      PB.handleAuthError(e);
      return false;
    }
  }

   static Future<bool> clearFcmToken() async {
     try {
       final record = PB.pb.authStore.record;
       if (record == null) return false;

       await PB.pb
           .collection('users')
           .update(record.id, body: {'fcm_token': ''});
       
       return true;
     } catch (e) {
       PB.handleAuthError(e);
       return false;
     }
   }

   /// Update all device-related fields on user record
   static Future<bool> updateDeviceInfo(Map<String, dynamic> payload) async {
     try {
       final record = PB.pb.authStore.record;
       if (record == null) return false;

       final updated = await PB.pb
           .collection('users')
           .update(record.id, body: payload);
       
       PB.pb.authStore.save(PB.pb.authStore.token, updated);
       
       return true;
     } catch (e) {
       PB.handleAuthError(e);
       return false;
     }
   }
 }