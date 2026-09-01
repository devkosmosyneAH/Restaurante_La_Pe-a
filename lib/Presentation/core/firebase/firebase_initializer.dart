import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseAppInitializer {
  const FirebaseAppInitializer._();

  static Future<void>? _initialization;

  static String _requireEnv(String key) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('Falta la variable de entorno Firebase: $key');
    }
    return value;
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
    if (kIsWeb) {
      final options = FirebaseOptions(
        apiKey: _requireEnv('FIREBASE_API_KEY'),
        appId: _requireEnv('FIREBASE_WEB_APP_ID'),
        messagingSenderId: _requireEnv('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: _requireEnv('FIREBASE_PROJECT_ID'),
        authDomain: _requireEnv('FIREBASE_AUTH_DOMAIN'),
        databaseURL: _requireEnv('FIREBASE_DATABASE_URL'),
        storageBucket: _requireEnv('FIREBASE_STORAGE_BUCKET'),
      );

      await Firebase.initializeApp(options: options);

      // Safari can reject persistent browser storage while Firebase Auth itself
      // remains usable for the current tab. Do not fail initialization or login
      // because LOCAL persistence is unavailable.
      try {
        await FirebaseAuth.instance
            .setPersistence(Persistence.LOCAL)
            .timeout(const Duration(seconds: 3));
      } catch (error) {
        debugPrint('firebase_auth.persistence_unavailable: $error');
      }
      return;
    }

    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      debugPrint(
        'Firebase initialization skipped for unsupported platform: $defaultTargetPlatform',
      );
      return;
    }

    final options = FirebaseOptions(
      apiKey: _requireEnv('FIREBASE_API_KEY'),
      appId: defaultTargetPlatform == TargetPlatform.iOS
          ? _requireEnv('FIREBASE_IOS_APP_ID')
          : _requireEnv('FIREBASE_ANDROID_APP_ID'),
      messagingSenderId: _requireEnv('FIREBASE_MESSAGING_SENDER_ID'),
      projectId: _requireEnv('FIREBASE_PROJECT_ID'),
      authDomain: _requireEnv('FIREBASE_AUTH_DOMAIN'),
      databaseURL: _requireEnv('FIREBASE_DATABASE_URL'),
      storageBucket: _requireEnv('FIREBASE_STORAGE_BUCKET'),
    );

    await Firebase.initializeApp(options: options);
  }
}
