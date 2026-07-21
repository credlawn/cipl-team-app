import 'package:flutter/services.dart';

class NativeCameraService {
  static const platform = MethodChannel('com.credlawn.cipl/camera');

  static Future<String?> captureFrontSelfie() async {
    try {
      final String? imagePath = await platform.invokeMethod('captureFrontSelfie');
      return imagePath;
    } on PlatformException catch (e) {
      throw Exception('Failed to capture selfie: ${e.message}');
    }
  }
}
