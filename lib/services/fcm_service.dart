import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background handler - minimal processing
}

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitializing = false;
  static String? _currentToken;
  static final StreamController<String> _tokenRefreshController =
      StreamController<String>.broadcast();

  /// Initialize FCM service
  static Future<void> initialize() async {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      await _initializeLocalNotifications();
      await _requestNotificationPermission();

      // Fetch and cache the FCM token immediately
      try {
        _currentToken = await _messaging.getToken();
      } catch (e) {
        print('[FCMService] Token fetch during init failed: $e');
      }

      _setupTokenRefreshListener();
      _setupMessageHandlers();
    } catch (e, stackTrace) {
      print('[FCMService] Initialization error: $e');
      print(stackTrace);
    } finally {
      _isInitializing = false;
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(settings: initSettings);

    // Notification channels
    const ipaChannel = AndroidNotificationChannel(
      'ipa_notification',
      'IPA Notification',
      description: 'Notifications for IP Approvals.',
      importance: Importance.high,
    );

    const celebrationChannel = AndroidNotificationChannel(
      'celebration_notification',
      'Celebration Notification',
      description: 'Notifications for Birthdays and Celebrations.',
      importance: Importance.high,
    );

    final plugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await plugin?.createNotificationChannel(ipaChannel);
    await plugin?.createNotificationChannel(celebrationChannel);
  }

  static Future<void> _requestNotificationPermission() async {
    int retries = 0;
    while (retries < 3) {
      try {
        await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        return;
      } catch (e) {
        if (e.toString().contains("already running")) {
          await Future.delayed(const Duration(seconds: 2));
          retries++;
        } else {
          rethrow;
        }
      }
    }
  }

  static void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((newToken) {
      _currentToken = newToken;
      _tokenRefreshController.add(newToken);
    });
  }

  static void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        final channelId = message.data['channel_id'] ?? 'ipa_notification';
        final channelName = channelId == 'celebration_notification'
            ? 'Celebration Notification'
            : 'IPA Notification';

        final channelDescription = channelId == 'celebration_notification'
            ? 'Notifications for Birthdays and Celebrations.'
            : 'Notifications for IP Approvals.';

        await _localNotifications.show(
          id: message.hashCode,
          title: message.notification!.title,
          body: message.notification!.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channelId,
              channelName,
              channelDescription: channelDescription,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification tap - can be extended later
    });
  }

  /// Get the current FCM token
  static Future<String?> getToken() async {
    if (_currentToken != null) return _currentToken;
    _currentToken = await _messaging.getToken();
    return _currentToken;
  }

  /// Stream of token refresh events
  static Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  /// Clear FCM token (call on logout)
  static Future<void> clearToken() async {
    try {
      await _messaging.deleteToken();
      _currentToken = null;
    } catch (e) {
      print('[FCMService] Clear token error: $e');
    }
  }
}
