import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/firebase_auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(String uid);
  Stream<ProfileModel> profileStream(String uid);
  Future<ProfileModel> updateProfile({
    required String uid,
    String? displayName,
    String? phone,
    String? photoUrl,
  });
  Future<void> deleteAccount(String uid);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirestoreService _firestoreService;
  final FirebaseAuthService _authService;

  ProfileRemoteDataSourceImpl(this._firestoreService, this._authService);

  @override
  Future<ProfileModel> getProfile(String uid) async {
    try {
      final doc = await _firestoreService.getUser(uid);
      if (!doc.exists) throw const NotFoundException('Profil bulunamadı');
      return ProfileModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Profil yüklenemedi: $e', originalError: e);
    }
  }

  @override
  Stream<ProfileModel> profileStream(String uid) {
    return _firestoreService.userStream(uid).map(
          (doc) => ProfileModel.fromFirestore(doc),
        );
  }

  @override
  Future<ProfileModel> updateProfile({
    required String uid,
    String? displayName,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (phone != null) updates['phone'] = phone;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      updates['updatedAt'] = _firestoreService.serverTimestamp;

      await _firestoreService.updateUser(uid, updates);

      // Also update Firebase Auth display name
      if (displayName != null) {
        await _authService.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await _authService.updatePhotoURL(photoUrl);
      }

      final doc = await _firestoreService.getUser(uid);
      return ProfileModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Profil güncellenemedi: $e', originalError: e);
    }
  }

  @override
  Future<void> deleteAccount(String uid) async {
    try {
      // Delete Firestore data first
      await _firestoreService.userDoc(uid).delete();
      // Then delete Firebase Auth account
      await _authService.deleteAccount();
    } catch (e) {
      throw ServerException('Hesap silinemedi: $e', originalError: e);
    }
  }
}
