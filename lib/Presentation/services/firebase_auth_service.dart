import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:restaurant_app/Presentation/core/constants/app_constants.dart';
import 'package:restaurant_app/Presentation/core/database/database_helper.dart';
import 'package:restaurant_app/Presentation/services/session_service.dart';

/// Result of the only operation that decides access: Firebase Authentication.
/// Profile, SQLite and browser storage are intentionally excluded.
class FirebaseAuthenticationResult {
  const FirebaseAuthenticationResult._({
    this.user,
    this.failureCode,
    this.message,
  });

  const FirebaseAuthenticationResult.success(User user) : this._(user: user);

  const FirebaseAuthenticationResult.failure({
    required String code,
    required String message,
  }) : this._(failureCode: code, message: message);

  final User? user;
  final String? failureCode;
  final String? message;

  bool get isAuthenticated => user != null;
}

class PostLoginIssue {
  const PostLoginIssue(this.code, this.error);

  final String code;
  final Object error;
}

class PostLoginResult {
  const PostLoginResult({
    required this.session,
    required this.issues,
    required this.isAuthorized,
  });

  final Map<String, dynamic> session;
  final List<PostLoginIssue> issues;

  final bool isAuthorized;
}

/// Service responsible for Firebase credentials. A successful credential is
/// never downgraded because a non-authentication dependency fails afterwards.
class FirebaseAuthService {
  FirebaseAuthService._({
    FirebaseAuth? firebaseAuth,
    DatabaseReference? databaseReference,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _database = databaseReference ?? FirebaseDatabase.instance.ref();

  static FirebaseAuthService? _instance;

  static FirebaseAuthService get instance {
    _instance ??= FirebaseAuthService._();
    return _instance!;
  }

  @visibleForTesting
  static void setInstance(FirebaseAuthService instance) {
    _instance = instance;
  }

  @visibleForTesting
  static void reset() {
    _instance = null;
  }

  final FirebaseAuth _firebaseAuth;
  final DatabaseReference _database;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  User? get currentUser => _firebaseAuth.currentUser;
  bool get isSignedIn => currentUser != null;

  Future<FirebaseAuthenticationResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password,
          )
          .timeout(const Duration(seconds: 15));
      final user = credential.user;
      if (user == null) {
        return const FirebaseAuthenticationResult.failure(
          code: 'authentication_failed',
          message: 'Firebase no devolvio un usuario autenticado.',
        );
      }

      // Authentication ends here. Do not await RTDB, SQLite or browser storage.
      return FirebaseAuthenticationResult.success(user);
    } on TimeoutException {
      return const FirebaseAuthenticationResult.failure(
        code: 'authentication_timeout',
        message:
            'La autenticación está tardando demasiado. Comprueba tu conexión e inténtalo de nuevo.',
      );
    } on FirebaseAuthException catch (error) {
      return FirebaseAuthenticationResult.failure(
        code: 'authentication_failed',
        message: _mapAuthError(error.code),
      );
    } catch (error) {
      debugPrint('firebase_auth.authentication_failed: $error');
      return const FirebaseAuthenticationResult.failure(
        code: 'authentication_failed',
        message: 'No fue posible iniciar sesion en este momento.',
      );
    }
  }

  Future<String?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    required String permission,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) return 'No se pudo crear la cuenta.';

      await user.updateDisplayName('$firstName $lastName'.trim());
      unawaited(
        completePostLogin(
          user,
          extraProfileData: {
            'name': firstName,
            'lastname': lastName,
            'role': role,
            'permission': permission,
            'restaurantId': AppConstants.defaultRestaurantId,
          },
        ),
      );
      return null;
    } on FirebaseAuthException catch (error) {
      return _mapAuthError(error.code);
    } catch (error) {
      debugPrint('firebase_auth.register_failed: $error');
      return 'No fue posible crear la cuenta.';
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await SessionService.logout();
  }

  /// Does not clear local state while a manual login may be starting in parallel.
  Future<Map<String, dynamic>?> restoreSessionFromFirebase() async {
    final user =
        currentUser ??
        await _firebaseAuth
            .authStateChanges()
            .firstWhere((value) => value != null, orElse: () => null)
            .timeout(const Duration(seconds: 5), onTimeout: () => null);
    if (user == null) return null;

    final hydration = await completePostLogin(user);
    return hydration.isAuthorized ? hydration.session : null;
  }

  /// Returns a usable Firebase-backed session immediately. It never requests
  /// RTDB or SQLite synchronously.
  Future<Map<String, dynamic>?> getCurrentAuthenticatedUser() async {
    final user = currentUser;
    if (user == null) return null;

    final hydration = await completePostLogin(user);
    return hydration.isAuthorized ? hydration.session : null;
  }

  /// Best-effort profile, role and storage hydration. Errors are returned with
  /// explicit codes and never thrown to the authentication UI.
  Future<PostLoginResult> completePostLogin(
    User user, {
    Map<String, dynamic>? extraProfileData,
  }) async {
    final issues = <PostLoginIssue>[];
    Map<String, dynamic>? profile;

    try {
      profile = await _syncUserToRealtimeDatabase(
        user,
        extraData: extraProfileData,
      ).timeout(const Duration(seconds: 6));
    } catch (error) {
      issues.add(PostLoginIssue('profile_sync_failed', error));
      debugPrint('post_login.profile_sync_failed: $error');
    }

    // Firebase is the source of truth for access. SQLite must never decide
    // which role is shown after a sign-in.
    final authMetadata = await _readAuthMetadata(user);
    final role = roleFromMetadata(authMetadata) ?? roleFromMetadata(profile);
    final isAuthorized =
        role != null &&
        profile?['uid']?.toString() == user.uid &&
        profile?['restaurantId']?.toString() == AppConstants.restaurantId;

    final session = <String, dynamic>{
      'id': user.uid,
      'uid': user.uid,
      'email': user.email,
      'name': user.displayName ?? profile?['name'] ?? 'Usuario',
      // A caller must check [isAuthorized] before using the fallback role.
      'role': role ?? 'mesero',
      'permission': profile?['permission'] ?? 'operador',
      'restaurantId': AppConstants.restaurantId,
    };
    // Do not let a delayed hydration from a signed-out or replaced user write
    // a stale browser session.
    if (currentUser?.uid != user.uid) {
      return PostLoginResult(
        session: session,
        issues: issues,
        isAuthorized: isAuthorized,
      );
    }
    final persisted = await SessionService.saveUserSessionDetailed(session);
    if (!persisted.success) {
      issues.add(PostLoginIssue('session_storage_failed', persisted.error!));
      debugPrint('post_login.session_storage_failed: ${persisted.error}');
    }
    return PostLoginResult(
      session: session,
      issues: issues,
      isAuthorized: isAuthorized,
    );
  }

  Future<Map<String, dynamic>?> _readAuthMetadata(User user) async {
    try {
      final snapshot = await _database
          .child('auth')
          .child(user.uid)
          .once()
          .timeout(const Duration(seconds: 3));
      final value = snapshot.snapshot.value;
      if (value is Map) {
        return Map<String, dynamic>.from(value.cast<String, dynamic>());
      }
    } catch (error) {
      debugPrint('post_login.auth_metadata_unavailable: $error');
    }
    return null;
  }

  /// Handles the role formats used by both current and legacy RTDB profiles.
  @visibleForTesting
  static String? roleFromMetadata(Map<String, dynamic>? data) {
    if (data == null) return null;
    if (data['admin'] == true) return 'administrador';

    final directRole = _normalizeRole(data['role'] ?? data['rol']);
    if (directRole != null) return directRole;

    final roles = data['roles'];
    if (roles is String) {
      return _normalizeRole(roles);
    }
    if (roles is Map) {
      for (final entry in roles.entries) {
        if (entry.value == true) {
          final normalized = _normalizeRole(entry.key);
          if (normalized != null) return normalized;
        }
      }
    } else if (roles is Iterable) {
      for (final value in roles) {
        final normalized = _normalizeRole(value);
        if (normalized != null) return normalized;
      }
    }
    return null;
  }

  static String? _normalizeRole(Object? rawRole) {
    final value = rawRole?.toString().trim().toLowerCase();
    return switch (value) {
      'administrador' || 'admin' || 'administrator' => 'administrador',
      'cajero' || 'cashier' => 'cajero',
      'mesero' || 'mozo' || 'waiter' => 'mesero',
      'cocina' || 'cocinero' || 'kitchen' => 'cocina',
      _ => null,
    };
  }

  /// SQLite is explicitly outside the critical authentication path.
  Future<String?> _resolveLocalRole(User user) async {
    final email = user.email?.trim();
    if (email == null || email.isEmpty) return null;
    final rows = await DatabaseHelper.instance.query(
      'usuarios',
      where: 'lower(email) = lower(?) AND restaurant_id = ? AND activo = 1',
      whereArgs: [email, AppConstants.restaurantId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final localRole = rows.first['rol']?.toString().trim();
    return localRole == null || localRole.isEmpty ? null : localRole;
  }

  Future<Map<String, dynamic>?> _syncUserToRealtimeDatabase(
    User user, {
    Map<String, dynamic>? extraData,
  }) async {
    final profileRef = _database.child('users').child(user.uid);
    final snapshot = await profileRef.once();
    final profile = <String, dynamic>{
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'updatedAt': ServerValue.timestamp,
      if (extraData != null) ...extraData,
    };
    if (snapshot.snapshot.exists) {
      final existingData = Map<String, dynamic>.from(
        (snapshot.snapshot.value as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{},
      );
      profile.addAll(existingData);
      profile['uid'] = user.uid;
      profile['email'] = profile['email'] ?? user.email;
      profile['displayName'] = profile['displayName'] ?? user.displayName;
    }
    await profileRef.set(profile);
    return profile;
  }

  static String _mapAuthError(String code) {
    return switch (code) {
      'invalid-email' => 'Las credenciales ingresadas no son validas.',
      'user-disabled' => 'No fue posible iniciar sesion con esas credenciales.',
      'user-not-found' => 'Las credenciales ingresadas no son validas.',
      'wrong-password' => 'Las credenciales ingresadas no son validas.',
      'email-already-in-use' => 'No fue posible completar el registro.',
      'weak-password' => 'La contrasena no cumple los requisitos de seguridad.',
      'operation-not-allowed' => 'El metodo de autenticacion no esta habilitado.',
      _ => 'No fue posible completar la solicitud de autenticacion.',
    };
  }
}
