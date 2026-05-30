import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/firebase_auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../models/user_model.dart';

/// Remote data source for auth operations (Firebase)
abstract class AuthRemoteDataSource {
  Future<UserModel> signIn({required String email, required String password});
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
    required String phone,
  });
  Future<void> signOut();
  Future<void> forgotPassword({required String email});
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  AuthRemoteDataSourceImpl(this._authService, this._firestoreService);

  @override
  Future<UserModel> signIn(
      {required String email, required String password}) async {
    try {
      final credential =
          await _authService.signInWithEmail(email, password);
      final user = credential.user!;

      // Update last seen in Firestore
      await _firestoreService.updateUser(user.uid, {
        'lastSeen': _firestoreService.serverTimestamp,
      });

      return UserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Authentication failed',
          code: e.code.hashCode, originalError: e);
    } catch (e) {
      throw ServerException('Sign in failed: $e', originalError: e);
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
    required String phone,
  }) async {
    try {
      final credential =
          await _authService.createUserWithEmail(email, password);
      final user = credential.user!;

      // Update display name in Firebase Auth
      await _authService.updateDisplayName(displayName);

      // Create user document in Firestore
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        phone: phone,
      );

      await _firestoreService.setUser(user.uid, {
        ...userModel.toFirestore(),
        'createdAt': _firestoreService.serverTimestamp,
      });

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Registration failed',
          code: e.code.hashCode, originalError: e);
    } catch (e) {
      throw ServerException('Registration failed: $e', originalError: e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      throw ServerException('Sign out failed: $e', originalError: e);
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to send reset email',
          code: e.code.hashCode, originalError: e);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _authService.currentUser;
    if (user == null) return null;
    try {
      final doc = await _firestoreService.getUser(user.uid);
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return UserModel.fromFirebaseUser(user);
    } catch (e) {
      return UserModel.fromFirebaseUser(user);
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _authService.authStateChanges.asyncMap((user) async {
      if (user == null) return null;
      try {
        final doc = await _firestoreService.getUser(user.uid);
        if (doc.exists) return UserModel.fromFirestore(doc);
        return UserModel.fromFirebaseUser(user);
      } catch (_) {
        return UserModel.fromFirebaseUser(user);
      }
    });
  }
}
