import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:restaurant_app/firebase_options.dart';

class FirebaseAppInitializer {
  const FirebaseAppInitializer._();

  static Future<void>? _initialization;
  static String persistenceDiagnostic = 'NO EJECUTADO';

  static FirebaseOptions buildOptionsForCurrentPlatform() {
    return DefaultFirebaseOptions.currentPlatform;
  }

  static Future<void> initialize() {
    if (Firebase.apps.isNotEmpty) {
      debugPrint('FirebaseAppInitializer: Firebase already initialized.');
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
    final target = kIsWeb ? 'WEB' : defaultTargetPlatform.name;

    try {
      debugPrint('FirebaseAppInitializer: initialising Firebase for $target.');
      final options = buildOptionsForCurrentPlatform();
      await Firebase.initializeApp(options: options);

      if (Firebase.apps.isEmpty) {
        throw StateError(
          'Firebase.initializeApp() finalizó sin crear la app [DEFAULT].',
        );
      }

      if (kIsWeb) {
        try {
          await FirebaseAuth.instance
              .setPersistence(Persistence.LOCAL)
              .timeout(const Duration(seconds: 8));
          persistenceDiagnostic =
              '${DateTime.now().toIso8601String()} OK (Persistence.LOCAL)';
          debugPrint(
            'FirebaseAppInitializer: Persistence.LOCAL enabled successfully.',
          );
        } catch (error, stackTrace) {
          persistenceDiagnostic =
              '${DateTime.now().toIso8601String()} FALLÓ ${error.runtimeType}: $error';
          debugPrint(
            'FirebaseAppInitializer: Persistence.LOCAL no se pudo habilitar: $error',
          );
          debugPrintStack(stackTrace: stackTrace);
          // Safari o modo privado pueden bloquear persistence local sin impedir
          // que Firebase Auth siga funcionando para la sesión actual del tab.
        }
      }

      debugPrint(
        'FirebaseAppInitializer: Firebase ready for $target.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'FirebaseAppInitializer: initialization failed for $target: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }
}
