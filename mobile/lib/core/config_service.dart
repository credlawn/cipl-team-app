import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  ConfigService._();

  static const String remoteConfigUrl = 'https://config.cipl.me/credlawn.json';
  static const String devBaseUrl = String.fromEnvironment('BASE_URL');
  static const String companyWhatsAppNumber = '919752146314';

  static String baseUrl = '';
  static String bugsinkDsn = '';
  static bool isConfigured = false;

  static Future<bool> init() async {
    // 0. Developer Override for local IP testing via --dart-define=BASE_URL=...
    if (devBaseUrl.isNotEmpty) {
      baseUrl = devBaseUrl;
      isConfigured = true;
      return true;
    }

    final prefs = await SharedPreferences.getInstance();

    // 1. Load from cache for instant startup
    final cachedBase = prefs.getString('cached_base_url');
    final cachedDsn = prefs.getString('cached_bugsink_dsn');

    if (cachedBase != null && cachedBase.isNotEmpty) {
      baseUrl = cachedBase;
      bugsinkDsn = cachedDsn ?? '';
      isConfigured = true;
    }

    // 2. Fetch live config from Cloudflare
    try {
      final response = await http
          .get(Uri.parse(remoteConfigUrl))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        final fetchedBaseUrl = data['base_url']?.toString() ?? '';
        final fetchedDsn = data['bugsink_dsn']?.toString() ?? '';

        if (fetchedBaseUrl.isNotEmpty) {
          baseUrl = fetchedBaseUrl;
          bugsinkDsn = fetchedDsn;
          isConfigured = true;

          await prefs.setString('cached_base_url', fetchedBaseUrl);
          await prefs.setString('cached_bugsink_dsn', fetchedDsn);
        }
      }
    } catch (_) {
      // Retain cached values if offline
    }

    return isConfigured;
  }
}
