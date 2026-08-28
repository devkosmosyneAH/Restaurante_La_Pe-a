import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:restaurant_app/Presentation/core/constants/app_constants.dart';
import 'package:restaurant_app/Presentation/core/di/injection_container.dart';
import 'package:restaurant_app/Presentation/core/domain/enums.dart';
import 'package:restaurant_app/Presentation/core/firebase/firebase_initializer.dart';
import 'package:restaurant_app/Presentation/core/sync/hybrid_sync_orchestrator.dart';
import 'package:restaurant_app/Presentation/core/tenant/tenant_context.dart';
import 'package:restaurant_app/Presentation/entities/usuarios/usuario.dart';
import 'package:restaurant_app/Presentation/services/firebase_auth_service.dart';
import 'package:restaurant_app/Presentation/services/session_service.dart';

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
    final generation = ++_sessionGeneration;
    _manualLoginInProgress = true;
    try {
      final normalizedEmail = email.trim();
      if (normalizedEmail.isEmpty ||
          !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(normalizedEmail)) {
        return 'Ingresa un correo electronico valido.';
      }
      if (password.length < 6) return 'Las credenciales ingresadas no son validas.';

      final lockUntil = await SessionService.getLoginLockUntil();
      if (lockUntil != null && lockUntil.isAfter(DateTime.now())) {
        return 'Demasiados intentos. Espera unos minutos e intentalo de nuevo.';
      }

      await FirebaseAppInitializer.initialize().timeout(
        const Duration(seconds: 8),
      );
      final firebase = sl<FirebaseAuthService>();
      final result = await firebase.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      if (!result.isAuthenticated) {
        final attempts = await SessionService.registerFailedLoginAttempt();
        unawaited(_audit('authentication_failed'));
        if (attempts >= 5) {
          return 'Demasiados intentos. Espera unos minutos e intentalo de nuevo.';
        }
        return result.message ?? 'No fue posible autenticar las credenciales.';
      }

      final user = result.user!;
      final previous = _usuario;
      _usuario = _fromFirebaseUser(user);
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

      // This starts only after authentication has been published to the UI.
      unawaited(_hydratePostLogin(user, generation));
      return null;
    } catch (error, stackTrace) {
      debugPrint('authentication_failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return 'No fue posible iniciar sesion en este momento.';
    } finally {
      _manualLoginInProgress = false;
    }
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
    if (hydratedUser.rol == _usuario!.rol && hydratedUser.nombre == _usuario!.nombre) {
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
          firebaseSession['uid']?.toString() ?? firebaseSession['id']?.toString();
      if (persisted != null && (persistedUid == null || persistedUid != firebaseUid)) {
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

      // La sesión persistida puede contener un rol antiguo (por ejemplo,
      // mesero). Rehidratarla desde Firebase corrige el rol sin exigir que el
      // usuario borre el almacenamiento del navegador o vuelva a registrarse.
      final firebaseUser = firebaseAuth.currentUser;
      if (firebaseUser != null) {
        unawaited(_hydratePostLogin(firebaseUser, generation));
      }
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
    final role = session['rol'] as String? ?? session['role'] as String? ?? 'mesero';
    return Usuario(
      id: id,
      restaurantId: AppConstants.restaurantId,
      nombre: session['nombre'] as String? ?? session['name'] as String? ?? 'Usuario',
      email: session['email'] as String?,
      pin: null,
      rol: RolUsuario.fromString(role),
      activo: session['activo'] as bool? ?? true,
      createdAt: DateTime.tryParse(session['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(session['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
