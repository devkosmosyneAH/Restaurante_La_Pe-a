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
  const PostLoginResult({required this.session, required this.issues});

  final Map<String, dynamic> session;
  final List<PostLoginIssue> issues;
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

    final persisted = await SessionService.getCurrentUserSession();
    if (persisted != null && persisted['uid']?.toString() == user.uid) {
      return persisted;
    }

    final session = _sessionFromUser(user);
    unawaited(completePostLogin(user));
    return session;
  }

  /// Returns a usable Firebase-backed session immediately. It never requests
  /// RTDB or SQLite synchronously.
  Future<Map<String, dynamic>?> getCurrentAuthenticatedUser() async {
    final user = currentUser;
    if (user == null) return null;

    final existingSession = await SessionService.getCurrentUserSession();
    if (existingSession != null && existingSession['uid']?.toString() == user.uid) {
      return existingSession;
    }

    final session = _sessionFromUser(user);
    unawaited(completePostLogin(user));
    return session;
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

    var role = _remoteRoleOrDefault(profile);
    try {
      final localRole = await _resolveLocalRole(user).timeout(
        const Duration(seconds: 3),
      );
      if (localRole != null) role = localRole;
    } catch (error) {
      issues.add(PostLoginIssue('local_database_failed', error));
      debugPrint('post_login.local_database_failed: $error');
    }

    final session = <String, dynamic>{
      'id': user.uid,
      'uid': user.uid,
      'email': user.email,
      'name': user.displayName ?? profile?['name'] ?? 'Usuario',
      'role': role,
      'permission': profile?['permission'] ?? 'operador',
      'restaurantId': AppConstants.restaurantId,
    };
    // Do not let a delayed hydration from a signed-out or replaced user write
    // a stale browser session.
    if (currentUser?.uid != user.uid) {
      return PostLoginResult(session: session, issues: issues);
    }
    final persisted = await SessionService.saveUserSessionDetailed(session);
    if (!persisted.success) {
      issues.add(PostLoginIssue('session_storage_failed', persisted.error!));
      debugPrint('post_login.session_storage_failed: ${persisted.error}');
    }
    return PostLoginResult(session: session, issues: issues);
  }

  Map<String, dynamic> _sessionFromUser(User user) => <String, dynamic>{
    'id': user.uid,
    'uid': user.uid,
    'email': user.email,
    'name': user.displayName ?? 'Usuario',
    'role': 'mesero',
    'permission': 'operador',
    'restaurantId': AppConstants.restaurantId,
  };

  String _remoteRoleOrDefault(Map<String, dynamic>? profile) {
    final remoteRole = profile?['role']?.toString().trim();
    return remoteRole == null || remoteRole.isEmpty ? 'mesero' : remoteRole;
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
