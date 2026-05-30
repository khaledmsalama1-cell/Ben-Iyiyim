import 'package:firebase_auth/firebase_auth.dart';

/// Wrapper around FirebaseAuth for clean, testable interface
class FirebaseAuthService {
  final FirebaseAuth _auth;

  FirebaseAuthService(this._auth);

  /// Current authenticated user (nullable)
  User? get currentUser => _auth.currentUser;

  /// UID of current user
  String? get currentUid => _auth.currentUser?.uid;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Create account with email and password
  Future<UserCredential> createUserWithEmail(
      String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Update display name
  Future<void> updateDisplayName(String displayName) async {
    await _auth.currentUser?.updateDisplayName(displayName);
  }

  /// Update photo URL
  Future<void> updatePhotoURL(String photoUrl) async {
    await _auth.currentUser?.updatePhotoURL(photoUrl);
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  /// Delete account
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }

  /// Reload user data
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;
}
