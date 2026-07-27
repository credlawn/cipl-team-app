import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AppLogger {
  AppLogger._();

  static const String bugsinkDsn = 'https://b3661f94be124cb0b68cbdd673c29cbe@error.cipl.me/1';

  /// Filters out routine offline network drops & expected auth expirations
  static FutureOr<SentryEvent?> filterError(SentryEvent event, Hint hint) {
    final exception = event.throwable;

    // Ignore offline network disconnects
    if (exception is SocketException || exception is HandshakeException) {
      return null;
    }

    // Ignore routine PocketBase exceptions (auth timeouts or background SSE network aborts)
    if (exception is ClientException) {
      if (exception.statusCode == 401 || exception.statusCode == 403) {
        return null;
      }
      if (exception.isAbort || exception.statusCode == 0) {
        return null;
      }
      final original = exception.originalError?.toString().toLowerCase() ?? '';
      if (original.contains('socketexception') || original.contains('connection abort') || original.contains('network is unreachable')) {
        return null;
      }
    }

    return event;
  }

  /// Explicitly capture caught exceptions to Bugsink
  static Future<void> captureException(
    dynamic exception, {
    dynamic stackTrace,
    String? tag,
    Map<String, dynamic>? extra,
  }) async {
    if (kDebugMode) {
      debugPrint('[AppLogger Error] $exception');
    }

    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (scope) {
        if (tag != null) {
          scope.setTag('module', tag);
        }
        if (extra != null) {
          extra.forEach((key, value) {
            scope.setExtra(key, value);
          });
        }
      },
    );
  }

  /// Attach authenticated user context to Bugsink reports
  static void setUserScope({
    required String id,
    String? email,
    String? name,
    String? role,
  }) {
    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: id,
        email: email,
        username: name,
        data: {
          if (role != null) 'role': role,
        },
      ));
    });
  }

  /// Clear user context on logout
  static void clearUserScope() {
    Sentry.configureScope((scope) {
      scope.setUser(null);
    });
  }
}
