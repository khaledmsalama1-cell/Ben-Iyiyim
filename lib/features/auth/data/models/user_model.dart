import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';

/// Data model for user - handles Firestore serialization
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.photoUrl,
    super.phone,
    super.fcmToken,
    super.createdAt,
    super.lastSeen,
  });

  /// Create from Firebase Auth user
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? user.email?.split('@').first ?? 'Kullanıcı',
      photoUrl: user.photoURL,
    );
  }

  /// Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? 'Kullanıcı',
      photoUrl: data['photoUrl'] as String?,
      phone: data['phone'] as String?,
      fcmToken: data['fcmToken'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
    );
  }

  /// Create from Map (e.g., local storage)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      photoUrl: map['photoUrl'] as String?,
      phone: map['phone'] as String?,
      fcmToken: map['fcmToken'] as String?,
    );
  }

  /// Serialize to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phone': phone,
      'fcmToken': fcmToken,
      'lastSeen': FieldValue.serverTimestamp(),
    };
  }

  /// Serialize to Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phone': phone,
      'fcmToken': fcmToken,
    };
  }

  /// Convert entity to model
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      phone: entity.phone,
      fcmToken: entity.fcmToken,
      createdAt: entity.createdAt,
      lastSeen: entity.lastSeen,
    );
  }
}
