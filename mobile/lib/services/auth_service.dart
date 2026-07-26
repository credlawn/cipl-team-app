import 'package:pocketbase/pocketbase.dart';
import '../core/pb_api.dart';

class AuthService {
  static Future<RecordModel?> login(String email, String password) async {
    try {
      final authData = await PB.pb
          .collection('users')
          .authWithPassword(email, password);

      return authData.record;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isLoggedIn() async {
    return PB.pb.authStore.isValid;
  }

  static Future<void> logout() async {
    await PB.logout();
  }
}
