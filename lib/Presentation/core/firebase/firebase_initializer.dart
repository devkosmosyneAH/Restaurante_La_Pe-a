import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseAppInitializer {
  const FirebaseAppInitializer._();

  // Configuración pública del cliente web de Firebase para La Peña.
  // Los dart-define o el archivo de entorno tienen prioridad sobre estos
  // valores para permitir cambiar de proyecto sin modificar el código.
  static const Map<String, String> _webDefaults = {
    'FIREBASE_API_KEY': 'AIzaSyCyMYO7DLe4WlJeGeBkOJqjV5uHXHClFHQ',
    'FIREBASE_WEB_APP_ID': '1:1062396228506:web:9ae562109a517ed7a38023',
    'FIREBASE_MESSAGING_SENDER_ID': '1062396228506',
    'FIREBASE_PROJECT_ID': 'restaura-a1e34',
    'FIREBASE_AUTH_DOMAIN': 'restaura-a1e34.firebaseapp.com',
    'FIREBASE_DATABASE_URL':
        'https://restaura-a1e34-default-rtdb.firebaseio.com',
    'FIREBASE_STORAGE_BUCKET': 'restaura-a1e34.firebasestorage.app',
  };

  static Future<void>? _initialization;

  // TODO: DEBUG TEMPORAL - remover después de diagnosticar
  static String persistenceDiagnostic = 'NO EJECUTADO';

  static String? _readEnv(String key) {
    try {
      final configured = dotenv.env[key]?.trim();
      if (configured != null && configured.isNotEmpty) return configured;
      if (kIsWeb) return _webDefaults[key];
      return configured;
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
    // El futuro en curso tiene prioridad: Firebase.apps puede dejar de estar
    // vacío antes de que termine la configuración posterior de Auth.
    if (_initialization != null) {
      return _initialization!;
    }

    if (Firebase.apps.isNotEmpty) {
      debugPrint('Firebase already initialized; skipping duplicate init.');
      return Future.value();
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
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        // Firebase toma la configuración nativa de google-services.json o
        // GoogleService-Info.plist cuando no existe un archivo de entorno.
        await Firebase.initializeApp();
        if (Firebase.apps.isEmpty) {
          throw StateError(
            'Firebase.initializeApp() termino sin crear la app [DEFAULT].',
          );
        }
        return;
      }
      debugPrint(
        'Firebase initialization skipped because required environment variables are missing.',
      );
      throw StateError(
        'Firebase no se inicializo: faltan variables de configuracion para '
        'la plataforma actual.',
      );
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
      if (Firebase.apps.isEmpty) {
        throw StateError(
          'Firebase.initializeApp() termino sin crear la app [DEFAULT].',
        );
      }
      return;
    }

    await Firebase.initializeApp(options: options);
    if (Firebase.apps.isEmpty) {
      throw StateError(
        'Firebase.initializeApp() termino sin crear la app [DEFAULT].',
      );
    }
  }
}
