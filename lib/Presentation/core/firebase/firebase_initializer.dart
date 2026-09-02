import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseAppInitializer {
  const FirebaseAppInitializer._();

  static Future<void>? _initialization;

  // TODO: DEBUG TEMPORAL - remover después de diagnosticar
  static String persistenceDiagnostic = 'NO EJECUTADO';

  static String? _readEnv(String key) {
    try {
      return dotenv.env[key]?.trim();
    } on Object catch (error) {
      debugPrint(
        'Firebase env unavailable before dotenv init for $key: $error',
      );
      return null;
    }
  }

  static bool _hasRequiredEnvForCurrentPlatform() {
    final required = <String>{
      'FIREBASE_API_KEY',
      'FIREBASE_MESSAGING_SENDER_ID',
      'FIREBASE_PROJECT_ID',
      'FIREBASE_AUTH_DOMAIN',
      'FIREBASE_DATABASE_URL',
      'FIREBASE_STORAGE_BUCKET',
    };

    if (kIsWeb) {
      required.addAll({'FIREBASE_WEB_APP_ID'});
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      required.add('FIREBASE_IOS_APP_ID');
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      required.add('FIREBASE_ANDROID_APP_ID');
    }

    for (final key in required) {
      final value = _readEnv(key);
      if (value == null || value.isEmpty) {
        debugPrint('Firebase config missing: $key');
        return false;
      }
    }

    return true;
  }

  static FirebaseOptions? buildOptionsForCurrentPlatform() {
    if (!_hasRequiredEnvForCurrentPlatform()) {
      return null;
    }

    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: _readEnv('FIREBASE_API_KEY')!,
        appId: _readEnv('FIREBASE_WEB_APP_ID')!,
        messagingSenderId: _readEnv('FIREBASE_MESSAGING_SENDER_ID')!,
        projectId: _readEnv('FIREBASE_PROJECT_ID')!,
        authDomain: _readEnv('FIREBASE_AUTH_DOMAIN')!,
        databaseURL: _readEnv('FIREBASE_DATABASE_URL')!,
        storageBucket: _readEnv('FIREBASE_STORAGE_BUCKET')!,
      );
    }

    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      debugPrint(
        'Firebase initialization skipped for unsupported platform: $defaultTargetPlatform',
      );
      return null;
    }

    return FirebaseOptions(
      apiKey: _readEnv('FIREBASE_API_KEY')!,
      appId: defaultTargetPlatform == TargetPlatform.iOS
          ? _readEnv('FIREBASE_IOS_APP_ID')!
          : _readEnv('FIREBASE_ANDROID_APP_ID')!,
      messagingSenderId: _readEnv('FIREBASE_MESSAGING_SENDER_ID')!,
      projectId: _readEnv('FIREBASE_PROJECT_ID')!,
      authDomain: _readEnv('FIREBASE_AUTH_DOMAIN')!,
      databaseURL: _readEnv('FIREBASE_DATABASE_URL')!,
      storageBucket: _readEnv('FIREBASE_STORAGE_BUCKET')!,
    );
  }

  static Future<void> initialize() {
    if (Firebase.apps.isNotEmpty) {
      debugPrint('Firebase already initialized; skipping duplicate init.');
      return Future.value();
    }

    if (_initialization != null) {
      return _initialization!;
    }

    final current = _initialize();
    _initialization = current;

    return _initialization!.whenComplete(() {
      if (identical(_initialization, current)) {
        _initialization = null;
      }
    });
  }

  static Future<void> _initialize() async {
    final options = buildOptionsForCurrentPlatform();
    if (options == null) {
      debugPrint(
        'Firebase initialization skipped because required environment variables are missing.',
      );
      return;
    }

    if (kIsWeb) {
      await Firebase.initializeApp(options: options);

      // Safari can reject persistent browser storage while Firebase Auth itself
      // remains usable for the current tab. Do not fail initialization or login
      // because LOCAL persistence is unavailable.
      try {
        await FirebaseAuth.instance
            .setPersistence(Persistence.LOCAL)
            .timeout(const Duration(seconds: 3));
        // TODO: DEBUG TEMPORAL - remover después de diagnosticar
        persistenceDiagnostic =
            '${DateTime.now().toIso8601String()} OK (Persistence.LOCAL)';
      } catch (error) {
        // TODO: DEBUG TEMPORAL - remover después de diagnosticar
        final status = error is TimeoutException ? 'TIMEOUT' : 'FALLÓ';
        persistenceDiagnostic =
            '${DateTime.now().toIso8601String()} $status ${error.runtimeType}: $error';
        debugPrint('firebase_auth.persistence_unavailable: $error');
      }
      return;
    }

    await Firebase.initializeApp(options: options);
  }
}
