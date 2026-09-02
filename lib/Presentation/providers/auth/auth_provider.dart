import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restaurant_app/Presentation/core/constants/app_constants.dart';
import 'package:restaurant_app/Presentation/core/di/injection_container.dart';
import 'package:restaurant_app/Presentation/core/domain/enums.dart';
import 'package:restaurant_app/Presentation/core/firebase/firebase_initializer.dart';
import 'package:restaurant_app/Presentation/core/sync/hybrid_sync_orchestrator.dart';
import 'package:restaurant_app/Presentation/core/tenant/tenant_context.dart';
import 'package:restaurant_app/Presentation/entities/usuarios/usuario.dart';
import 'package:restaurant_app/Presentation/services/firebase_auth_service.dart';
import 'package:restaurant_app/Presentation/services/session_service.dart';
import 'package:restaurant_app/Presentation/services/diagnostic_logger.dart';
import 'package:restaurant_app/Presentation/services/web_storage_diagnostics.dart';

/// Owns the active Firebase-authenticated user. Browser persistence and local
/// data enrich the session afterwards, but cannot revoke a valid credential.
class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier();

  Usuario? _usuario;
  bool _isSessionRestoring = false;
  bool _manualLoginInProgress = false;
  int _sessionGeneration = 0;

  Usuario? get usuario => _usuario;
  bool get isAuthenticated => _usuario != null;
  bool get isSessionRestoring => _isSessionRestoring;

  void _startCloudSyncIfAuthenticated() {
    if (!isAuthenticated || !sl.isRegistered<HybridSyncOrchestrator>()) return;
    if (!sl<FirebaseAuthService>().isSignedIn) return;
    unawaited(sl<HybridSyncOrchestrator>().start());
  }

  Future<void> _stopCloudSync() async {
    if (!sl.isRegistered<HybridSyncOrchestrator>()) return;
    await sl<HybridSyncOrchestrator>().stop();
  }

  Future<void> _audit(
    String eventType, {
    String? userId,
    Map<String, dynamic>? detail,
  }) => SessionService.logSecurityEvent(
    eventType: eventType,
    userId: userId,
    restaurantId: AppConstants.restaurantId,
    detail: detail,
  );

  /// Only Firebase credential validation decides whether this method succeeds.
  Future<String?> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    ++_sessionGeneration;
    _manualLoginInProgress = true;
    // TODO: DEBUG TEMPORAL - remover después de diagnosticar
    final diagnostic = DiagnosticLogger();
    diagnostic.section('CONTEXTO');
    diagnostic.line(
      'Timestamp inicio: ${diagnostic.startedAt.toIso8601String()}',
    );
    diagnostic.line(
      'Plataforma: ${kIsWeb ? 'WEB' : defaultTargetPlatform.name} (kIsWeb=$kIsWeb)',
    );
    await _captureLoginContext(diagnostic);
    diagnostic.section('PASOS');
    try {
      final normalizedEmail = email.trim();
      if (normalizedEmail.isEmpty ||
          !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(normalizedEmail)) {
        return _diagnosticFailure(
          diagnostic,
          'Ingresa un correo electronico valido.',
        );
      }
      diagnostic.line('Correo validado: OK (valor omitido por seguridad)');
      if (password.length < 6) {
        return _diagnosticFailure(
          diagnostic,
          'Las credenciales ingresadas no son validas.',
        );
      }
      diagnostic.line('Contrasena validada: OK (valor omitido por seguridad)');

      final lockUntil = await diagnostic.measure(
        'SessionService.getLoginLockUntil()',
        SessionService.getLoginLockUntil,
      );
      if (lockUntil != null && lockUntil.isAfter(DateTime.now())) {
        return _diagnosticFailure(
          diagnostic,
          'Demasiados intentos. Espera unos minutos e intentalo de nuevo.',
        );
      }

      await diagnostic.measure(
        'FirebaseAppInitializer.initialize()',
        () => FirebaseAppInitializer.initialize().timeout(
          const Duration(seconds: 8),
        ),
      );
      diagnostic.line(
        'Firebase Persistence.LOCAL: ${FirebaseAppInitializer.persistenceDiagnostic}',
      );
      final firebase = sl<FirebaseAuthService>();
      final result = await diagnostic.measure(
        'FirebaseAuth.signInWithEmailAndPassword()',
        () => firebase.signInWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        ),
      );
      if (!result.isAuthenticated) {
        diagnostic.line(
          'Resultado Firebase: FALLÓ (${result.failureCode}: ${result.message})',
        );
        final attempts = await SessionService.registerFailedLoginAttempt();
        unawaited(_audit('authentication_failed'));
        if (attempts >= 5) {
          return _diagnosticFailure(
            diagnostic,
            'Demasiados intentos. Espera unos minutos e intentalo de nuevo.',
          );
        }
        return _diagnosticFailure(
          diagnostic,
          result.message ?? 'No fue posible autenticar las credenciales.',
        );
      }

      final user = result.user!;
      diagnostic.line('Usuario obtenido: OK uid=${user.uid}');
      // The router listens to this notifier. Publishing a Firebase user before
      // its role is resolved made every account enter as the mesero default.
      final hydration = await diagnostic.measure(
        'FirebaseAuthService.completePostLogin()',
        () => firebase.completePostLogin(user, diagnosticLogger: diagnostic),
      );
      for (final issue in hydration.issues) {
        unawaited(
          _audit(
            issue.code,
            userId: user.uid,
            detail: {'error': issue.error.toString()},
          ),
        );
      }
      if (!hydration.isAuthorized) {
        unawaited(_audit('authorization_profile_missing', userId: user.uid));
        await firebase.signOut();
        return _diagnosticFailure(
          diagnostic,
          'Esta cuenta no tiene un rol autorizado para La Peña.',
        );
      }

      final previous = _usuario;
      _usuario = _fromSessionMap(hydration.session);
      _setTenant(_usuario!);
      _startCloudSyncIfAuthenticated();
      unawaited(SessionService.clearLoginSecurityState());
      unawaited(SessionService.clearPinSecurityState());
      unawaited(
        _audit(
          'login_success',
          userId: _usuario!.id,
          detail: {'rol': _usuario!.rol.value},
        ),
      );
      if (previous != _usuario) notifyListeners();

      return null;
    } catch (error, stackTrace) {
      debugPrint('authentication_failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      diagnostic.section('ERROR FINAL');
      diagnostic.line('Timestamp: ${DateTime.now().toIso8601String()}');
      diagnostic.line('Tipo: ${error.runtimeType}');
      diagnostic.line('Mensaje: $error');
      diagnostic.line(
        'Firebase Persistence.LOCAL: ${FirebaseAppInitializer.persistenceDiagnostic}',
      );
      diagnostic.line('StackTrace completo:\n$stackTrace');
      return diagnostic.text;
    } finally {
      _manualLoginInProgress = false;
    }
  }

  // TODO: DEBUG TEMPORAL - remover después de diagnosticar
  Future<void> _captureLoginContext(DiagnosticLogger diagnostic) async {
    try {
      final web = await readWebStorageDiagnostics();
      diagnostic.line('User-Agent: ${web.userAgent ?? 'NO APLICA'}');
      diagnostic.line('Modo privado detectado: ${web.privateMode}');
      diagnostic.line('localStorage disponible: ${web.localStorage}');
      diagnostic.line('indexedDB disponible: ${web.indexedDb}');
    } catch (error, stackTrace) {
      diagnostic.line(
        'Contexto web: FALLÓ ${error.runtimeType}: $error\n$stackTrace',
      );
    }

    final preferencesStarted = DateTime.now();
    try {
      await SharedPreferences.getInstance().timeout(const Duration(seconds: 2));
      diagnostic.result(
        'SharedPreferences.getInstance() prueba',
        preferencesStarted,
        'OK',
      );
    } catch (error, stackTrace) {
      diagnostic.result(
        'SharedPreferences.getInstance() prueba',
        preferencesStarted,
        'FALLÓ',
        error: error,
        stackTrace: stackTrace,
      );
    }

    final secureStarted = DateTime.now();
    try {
      const key = '__login_diagnostic_secure_test__';
      const store = FlutterSecureStorage();
      await store
          .write(key: key, value: 'diagnostic')
          .timeout(const Duration(seconds: 2));
      await store.read(key: key).timeout(const Duration(seconds: 2));
      await store.delete(key: key).timeout(const Duration(seconds: 2));
      diagnostic.result(
        'FlutterSecureStorage write/read/delete prueba',
        secureStarted,
        'OK',
      );
    } catch (error, stackTrace) {
      diagnostic.result(
        'FlutterSecureStorage write/read/delete prueba',
        secureStarted,
        'FALLÓ',
        error: error,
        stackTrace: stackTrace,
      );
    }

    final connectivityStarted = DateTime.now();
    try {
      final connectivity = await Connectivity().checkConnectivity().timeout(
        const Duration(seconds: 2),
      );
      diagnostic.line(
        'Conectividad: OK (${connectivity.toString()}) (${DateTime.now().difference(connectivityStarted).inMilliseconds}ms)',
      );
    } catch (error, stackTrace) {
      diagnostic.result(
        'Conectividad checkConnectivity()',
        connectivityStarted,
        'FALLÓ',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  // TODO: DEBUG TEMPORAL - remover después de diagnosticar
  String _diagnosticFailure(
    DiagnosticLogger diagnostic,
    String fallbackMessage,
  ) {
    diagnostic.section('ERROR FINAL');
    diagnostic.line('Timestamp: ${DateTime.now().toIso8601String()}');
    diagnostic.line('Mensaje funcional: $fallbackMessage');
    return diagnostic.text;
  }

  Future<void> _hydratePostLogin(User user, int generation) async {
    final hydration = await sl<FirebaseAuthService>().completePostLogin(user);
    for (final issue in hydration.issues) {
      unawaited(
        _audit(
          issue.code,
          userId: user.uid,
          detail: {'error': issue.error.toString()},
        ),
      );
    }

    if (generation != _sessionGeneration || _usuario?.id != user.uid) return;
    final hydratedUser = _fromSessionMap(hydration.session);
    if (hydratedUser.rol == _usuario!.rol &&
        hydratedUser.nombre == _usuario!.nombre) {
      return;
    }
    _usuario = hydratedUser;
    _setTenant(hydratedUser);
    notifyListeners();
  }

  Usuario _fromFirebaseUser(User user) => Usuario(
    id: user.uid,
    restaurantId: AppConstants.restaurantId,
    nombre: user.displayName ?? 'Usuario',
    email: user.email,
    pin: null,
    rol: RolUsuario.mesero,
    activo: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Future<String?> loginWithPin(String pin) async {
    if (pin.isEmpty) return 'Ingresa tus credenciales de acceso.';
    return 'El acceso por PIN ya no esta disponible. Usa correo y contrasena.';
  }

  /// A manual login wins over a background restoration at every await boundary.
  Future<void> restoreSession() async {
    if (_manualLoginInProgress || isAuthenticated) return;
    final generation = _sessionGeneration;
    _setSessionRestoring(true);
    try {
      final persisted = await SessionService.getCurrentUserSession();
      if (_manualLoginInProgress || generation != _sessionGeneration) return;
      final firebaseAuth = sl<FirebaseAuthService>();
      final firebaseSession = await firebaseAuth.restoreSessionFromFirebase();
      if (_manualLoginInProgress || generation != _sessionGeneration) return;
      if (firebaseSession == null) return;

      final persistedUid =
          persisted?['uid']?.toString() ?? persisted?['id']?.toString();
      final firebaseUid =
          firebaseSession['uid']?.toString() ??
          firebaseSession['id']?.toString();
      if (persisted != null &&
          (persistedUid == null || persistedUid != firebaseUid)) {
        unawaited(_audit('session_identity_mismatch'));
      }

      final restored = _fromSessionMap(firebaseSession);
      if (!restored.activo) {
        unawaited(_audit('session_invalid_inactive', userId: restored.id));
        await SessionService.logout();
        return;
      }
      final previous = _usuario;
      _usuario = restored;
      _setTenant(restored);
      _startCloudSyncIfAuthenticated();
      unawaited(_audit('session_restored', userId: restored.id));
      if (previous != _usuario) notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('session_restore_failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!_manualLoginInProgress && generation == _sessionGeneration) {
        unawaited(_audit('session_restore_failed'));
        await SessionService.logout();
      }
    } finally {
      _setSessionRestoring(false);
    }
  }

  void _setSessionRestoring(bool value) {
    if (_isSessionRestoring == value) return;
    _isSessionRestoring = value;
    notifyListeners();
  }

  Future<void> logout() async {
    ++_sessionGeneration;
    await _stopCloudSync();
    final current = _usuario;
    if (current != null) unawaited(_audit('logout', userId: current.id));
    final hadUser = _usuario != null;
    _usuario = null;
    sl<TenantContext>().clear();
    await sl<FirebaseAuthService>().signOut();
    if (hadUser) notifyListeners();
  }

  void _setTenant(Usuario user) {
    sl<TenantContext>().setFromSession(
      restaurantId: user.restaurantId,
      userId: user.id,
      rol: user.rol.value,
    );
  }

  Usuario _fromSessionMap(Map<String, dynamic> session) {
    final id = session['id'] as String? ?? session['uid'] as String?;
    if (id == null) throw StateError('Session data no contiene id/uid');
    final role =
        session['rol'] as String? ?? session['role'] as String? ?? 'mesero';
    return Usuario(
      id: id,
      restaurantId: AppConstants.restaurantId,
      nombre:
          session['nombre'] as String? ??
          session['name'] as String? ??
          'Usuario',
      email: session['email'] as String?,
      pin: null,
      rol: RolUsuario.fromString(role),
      activo: session['activo'] as bool? ?? true,
      createdAt:
          DateTime.tryParse(session['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(session['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
