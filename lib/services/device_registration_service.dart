import 'dart:async';
import '../services/device_info_service.dart';
import '../services/app_version_service.dart';
import '../services/permission_service.dart';
import '../services/fcm_service.dart';
import '../services/profile_service.dart';
import '../core/pb_api.dart';

/// Orchestrates device information registration/update on user profile
class DeviceRegistrationService {
  static StreamSubscription<String>? _tokenRefreshSubscription;

  /// Initialize the service - set up listeners
  static void initialize() {
    // Subscribe to FCM token refresh events
    _tokenRefreshSubscription = FCMService.onTokenRefresh.listen((token) {
      // Only register if user is authenticated
      if (PB.pb.authStore.isValid) {
        register();
      }
    });
  }

   /// Register or update all device info on the user record
   /// Call this after login, and it will also be called automatically on token refresh
   static Future<bool> register() async {
     try {
       // Ensure all dependent services are ready
       await Future.wait([
         DeviceInfoService.ensureInitialized(),
         AppVersionService.init(),
       ]);

       // Collect all device info in parallel
       final results = await Future.wait([
         DeviceInfoService.getDeviceInfo(),
         AppVersionService.getVersion(),
         PermissionService.collectPermissionStatus(),
         FCMService.getToken(),
       ]);

       final deviceInfo = results[0] as Map<String, String>;
       final appVersion = results[1] as String;
       final permissionStatus = results[2] as String;
       final fcmToken = results[3] as String?;

       // Prepare payload for user record update
       final Map<String, dynamic> payload = {
         'app_version': appVersion,
         'app_permission_status': permissionStatus,
       };

       // Only include device_id if user record doesn't already have it
       final currentUser = PB.pb.authStore.record;
       final currentDeviceId = currentUser?.data['device_id']?.toString();
       if (currentUser == null || currentDeviceId == null || currentDeviceId.isEmpty) {
         payload.addAll(deviceInfo); // device_id, model, os_version
       } else {
         // User already has device_id set, only update model and os_version if they changed
         final currentModel = currentUser.data['device_model']?.toString();
         final currentOs = currentUser.data['android_version']?.toString();
         final newModel = deviceInfo['model'];
         final newOs = deviceInfo['os_version'];
         
         if (newModel != null && newModel.isNotEmpty && newModel != currentModel) {
           payload['device_model'] = newModel;
         }
         if (newOs != null && newOs.isNotEmpty && newOs != currentOs) {
           payload['android_version'] = newOs;
         }
       }

       if (fcmToken != null && fcmToken.isNotEmpty) {
         payload['fcm_token'] = fcmToken;
       }
       // else: if no token, existing_token (if any) remains unchanged

       // Update user record via ProfileService
       final success = await ProfileService.updateDeviceInfo(payload);
       if (!success) {
         print('[DeviceRegistrationService] Profile update failed');
       }
       return success;
     } catch (e, stackTrace) {
       print('[DeviceRegistrationService] register error: $e');
       print(stackTrace);
       return false;
     }
   }

  /// Clean up resources (call on app termination if needed)
  static void dispose() {
    _tokenRefreshSubscription?.cancel();
  }
}
