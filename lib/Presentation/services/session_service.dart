import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:restaurant_app/Presentation/core/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

abstract class SensitiveSessionStore {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
}

class SessionSaveResult {
  const SessionSaveResult._({required this.success, this.error});

  const SessionSaveResult.success() : this._(success: true);

  const SessionSaveResult.failure(Object error)
    : this._(success: false, error: error);

  final bool success;
  final Object? error;
}

class InMemorySensitiveSessionStore implements SensitiveSessionStore {
  final Map<String, String> _store = <String, String>{};

  @override
  Future<void> write({required String key, required String value}) async {
    _store[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    return _store[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _store.remove(key);
  }

  void clear() {
    _store.clear();
  }
}

class _SharedPreferencesSensitiveSessionStore implements SensitiveSessionStore {
  const _SharedPreferencesSensitiveSessionStore();

  @override
  Future<void> write({required String key, required String value}) async {
    final prefs = await SharedPreferences.getInstance().timeout(
      const Duration(seconds: 2),
    );
    await prefs.setString(key, value).timeout(const Duration(seconds: 2));
  }

  @override
  Future<String?> read({required String key}) async {
    final prefs = await SharedPreferences.getInstance().timeout(
      const Duration(seconds: 2),
    );
    return prefs.getString(key);
  }

  @override
  Future<void> delete({required String key}) async {
    final prefs = await SharedPreferences.getInstance().timeout(
      const Duration(seconds: 2),
    );
    await prefs.remove(key).timeout(const Duration(seconds: 2));
  }
}

class _FlutterSecureSessionStore implements SensitiveSessionStore {
  _FlutterSecureSessionStore()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

  final FlutterSecureStorage _storage;

  @override
  Future<void> write({required String key, required String value}) {
    return _storage
        .write(key: key, value: value)
        .timeout(const Duration(seconds: 2));
  }

  @override
  Future<String?> read({required String key}) {
    return _storage.read(key: key).timeout(const Duration(seconds: 2));
  }

  @override
  Future<void> delete({required String key}) {
    return _storage.delete(key: key).timeout(const Duration(seconds: 2));
  }
}

/// Servicio para manejar la persistencia de sesión del usuario
class SessionService {
  static const String _legacySessionKey = 'user_session';
  static const String _secureSessionKey = 'secure_user_session';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _failedPinAttemptsKey = 'failed_pin_attempts';
  static const String _pinLockUntilKey = 'pin_lock_until';
  static const String _failedLoginAttemptsKey = 'failed_login_attempts';
  static const String _loginLockUntilKey = 'login_lock_until';

  static const Uuid _uuid = Uuid();
  static const Duration _storageTimeout = Duration(seconds: 2);

  static SensitiveSessionStore _sensitiveStore = _FlutterSecureSessionStore();
  static final SensitiveSessionStore _fallbackStore =
      const _SharedPreferencesSensitiveSessionStore();

  static Future<SharedPreferences> _preferences() =>
      SharedPreferences.getInstance().timeout(_storageTimeout);

  @visibleForTesting
  static void overrideSensitiveStore(SensitiveSessionStore store) {
    _sensitiveStore = store;
  }

  @visibleForTesting
  static void resetSensitiveStore() {
    _sensitiveStore = _FlutterSecureSessionStore();
  }

  static Future<String?> _readSensitiveSessionJson() async {
    try {
      final value = await _sensitiveStore
          .read(key: _secureSessionKey)
          .timeout(_storageTimeout);
      if (value != null && value.isNotEmpty) return value;
    } catch (_) {
      // Fallback en entornos sin soporte del plugin seguro.
    }
    return _fallbackStore
        .read(key: _secureSessionKey)
        .timeout(_storageTimeout);
  }

  static Future<void> _writeSensitiveSessionJson(String value) async {
    var persisted = false;
    try {
      await _sensitiveStore
          .write(key: _secureSessionKey, value: value)
          .timeout(_storageTimeout);
      persisted = true;
    } catch (_) {
      // Si el plugin no está disponible, usar fallback persistente en SharedPreferences.
    }

    if (persisted) {
      await _fallbackStore.delete(key: _secureSessionKey).timeout(_storageTimeout);
    } else {
      await _fallbackStore
          .write(key: _secureSessionKey, value: value)
          .timeout(_storageTimeout);
    }
  }

  static Future<void> _deleteSensitiveSessionJson() async {
    try {
      await _sensitiveStore.delete(key: _secureSessionKey).timeout(_storageTimeout);
    } catch (_) {
      // Ignorar; el fallback se limpia igual.
    }
    await _fallbackStore.delete(key: _secureSessionKey).timeout(_storageTimeout);
  }

  static Future<void> logSecurityEvent({
    required String eventType,
    String? userId,
    String? restaurantId,
    Map<String, dynamic>? detail,
  }) async {
    try {
      await DatabaseHelper.instance.insert('security_audit_log', {
        'id': _uuid.v4(),
        'event_type': eventType,
        'user_id': userId,
        'restaurant_id': restaurantId,
        'detail': detail == null || detail.isEmpty ? null : jsonEncode(detail),
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // La auditoría no debe bloquear el flujo principal.
    }
  }

  /// Guardar sesión del usuario
  static Future<bool> saveUserSession(Map<String, dynamic> userData) async {
    return (await saveUserSessionDetailed(userData)).success;
  }

  /// Detailed outcome used by authentication hydration. Keeping the bool API
  /// preserves existing callers while exposing storage failures explicitly.
  static Future<SessionSaveResult> saveUserSessionDetailed(
    Map<String, dynamic> userData,
  ) async {
    try {
      final prefs = await _preferences();

      final normalizedUserData = Map<String, dynamic>.from(userData);
      if (normalizedUserData.containsKey('role') &&
          !normalizedUserData.containsKey('rol')) {
        normalizedUserData['rol'] = normalizedUserData['role'];
      }
      if (normalizedUserData.containsKey('rol') &&
          !normalizedUserData.containsKey('role')) {
        normalizedUserData['role'] = normalizedUserData['rol'];
      }

      final userJson = jsonEncode(normalizedUserData);
      await _writeSensitiveSessionJson(userJson);
      final legacyRemoved = await prefs
          .remove(_legacySessionKey)
          .timeout(_storageTimeout);
      final loggedInSaved = await prefs
          .setBool(_isLoggedInKey, true)
          .timeout(_storageTimeout);
      if (!legacyRemoved || !loggedInSaved) {
        return SessionSaveResult.failure(StateError('session_storage_failed'));
      }

      return const SessionSaveResult.success();
    } catch (error) {
      debugPrint('session_storage_failed: $error');
      return SessionSaveResult.failure(error);
    }
  }

  /// Obtener sesión del usuario actual
  static Future<Map<String, dynamic>?> getCurrentUserSession() async {
    try {
      final prefs = await _preferences();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      if (!isLoggedIn) {
        return null;
      }

      var userJson = await _readSensitiveSessionJson();

      if (userJson == null || userJson.isEmpty) {
        final legacyJson = prefs.getString(_legacySessionKey);
        if (legacyJson != null && legacyJson.isNotEmpty) {
          userJson = legacyJson;
          await _writeSensitiveSessionJson(legacyJson);
          await prefs.remove(_legacySessionKey).timeout(_storageTimeout);
          await logSecurityEvent(
            eventType: 'legacy_session_migrated',
            detail: {'source': 'shared_preferences'},
          );
        }
      }

      if (userJson == null || userJson.isEmpty) {
        await prefs.setBool(_isLoggedInKey, false).timeout(_storageTimeout);
        return null;
      }

      final decoded = jsonDecode(userJson);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Verificar si hay una sesión activa
  static Future<bool> isUserLoggedIn() async {
    try {
      final session = await getCurrentUserSession();
      return session != null;
    } catch (_) {
      return false;
    }
  }

  /// Obtener el número de intentos fallidos recientes de PIN.
  static Future<int> getFailedPinAttempts() async {
    try {
      final prefs = await _preferences();
      return prefs.getInt(_failedPinAttemptsKey) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Obtiene hasta cuándo está bloqueado temporalmente el acceso por PIN.
  static Future<DateTime?> getPinLockUntil() async {
    try {
      final prefs = await _preferences();
      final raw = prefs.getString(_pinLockUntilKey);
      if (raw == null || raw.isEmpty) return null;
      return DateTime.tryParse(raw);
    } catch (_) {
      return null;
    }
  }

  /// Registra un intento fallido y aplica bloqueo temporal si se supera el límite.
  static Future<int> registerFailedPinAttempt({
    int maxAttempts = 3,
    Duration lockDuration = const Duration(seconds: 30),
  }) async {
    try {
      final prefs = await _preferences();
      final attempts = (prefs.getInt(_failedPinAttemptsKey) ?? 0) + 1;
      await prefs.setInt(_failedPinAttemptsKey, attempts).timeout(_storageTimeout);

      if (attempts >= maxAttempts) {
        final lockUntil = DateTime.now().add(lockDuration).toIso8601String();
        await prefs.setString(_pinLockUntilKey, lockUntil).timeout(_storageTimeout);
      }

      return attempts;
    } catch (_) {
      return maxAttempts;
    }
  }

  /// Limpia el contador de intentos y cualquier bloqueo temporal.
  static Future<bool> clearPinSecurityState() async {
    try {
      final prefs = await _preferences();
      await prefs.remove(_failedPinAttemptsKey).timeout(_storageTimeout);
      await prefs.remove(_pinLockUntilKey).timeout(_storageTimeout);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<DateTime?> getLoginLockUntil() async {
    try {
      final prefs = await _preferences();
      final raw = prefs.getString(_loginLockUntilKey);
      if (raw == null || raw.isEmpty) return null;
      final value = DateTime.tryParse(raw);
      if (value != null && value.isBefore(DateTime.now())) {
        await clearLoginSecurityState();
        return null;
      }
      return value;
    } catch (_) {
      return null;
    }
  }

  static Future<int> registerFailedLoginAttempt({
    int maxAttempts = 5,
    Duration lockDuration = const Duration(minutes: 5),
  }) async {
    try {
      final prefs = await _preferences();
      final attempts = (prefs.getInt(_failedLoginAttemptsKey) ?? 0) + 1;
      await prefs.setInt(_failedLoginAttemptsKey, attempts).timeout(_storageTimeout);
      if (attempts >= maxAttempts) {
        await prefs
            .setString(
              _loginLockUntilKey,
              DateTime.now().add(lockDuration).toIso8601String(),
            )
            .timeout(_storageTimeout);
      }
      return attempts;
    } catch (_) {
      return maxAttempts;
    }
  }

  static Future<bool> clearLoginSecurityState() async {
    try {
      final prefs = await _preferences();
      await prefs.remove(_failedLoginAttemptsKey).timeout(_storageTimeout);
      await prefs.remove(_loginLockUntilKey).timeout(_storageTimeout);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Cerrar sesión del usuario
  static Future<bool> logout() async {
    try {
      final prefs = await _preferences();

      await _deleteSensitiveSessionJson();
      await prefs.remove(_legacySessionKey).timeout(_storageTimeout);
      await prefs.setBool(_isLoggedInKey, false).timeout(_storageTimeout);

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Actualizar datos del usuario en sesión
  static Future<bool> updateUserSession(
    Map<String, dynamic> updatedData,
  ) async {
    try {
      final isLoggedIn = await isUserLoggedIn();
      if (!isLoggedIn) {
        return false;
      }

      return saveUserSession(updatedData);
    } catch (_) {
      return false;
    }
  }

  /// Obtener información específica del usuario actual
  static Future<String?> getCurrentUserId() async {
    final session = await getCurrentUserSession();
    return session?['id'] as String? ?? session?['uid'] as String?;
  }

  static Future<String?> getCurrentUserEmail() async {
    final session = await getCurrentUserSession();
    return session?['email'] as String?;
  }

  static Future<String?> getCurrentUserName() async {
    final session = await getCurrentUserSession();
    return session?['nombre'] as String? ?? session?['name'] as String?;
  }

  static Future<String?> getCurrentUserRole() async {
    final session = await getCurrentUserSession();
    return session?['rol'] as String? ?? session?['role'] as String?;
  }

  static Future<String?> getCurrentUserPermission() async {
    final session = await getCurrentUserSession();
    return session?['permission'] as String?;
  }

  /// Método para debug - muestra sólo si hay sesión activa, sin datos sensibles
  static Future<void> debugSessionInfo() async {
    assert(() {
      // Solo se ejecuta en debug builds; ignorado completamente en release
      isUserLoggedIn().then((isLoggedIn) {
        debugPrint('[Session] Estado: ${isLoggedIn ? 'activa' : 'inactiva'}');
      });
      return true;
    }());
  }
}
