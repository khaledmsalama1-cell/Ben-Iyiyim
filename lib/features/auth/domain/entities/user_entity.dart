import 'package:equatable/equatable.dart';

/// Domain entity for an authenticated user
/// This is the pure domain object, decoupled from Firebase
class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? phone;
  final String? fcmToken;
  final DateTime? createdAt;
  final DateTime? lastSeen;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.phone,
    this.fcmToken,
    this.createdAt,
    this.lastSeen,
  });

  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phone,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? lastSeen,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        photoUrl,
        phone,
        fcmToken,
        createdAt,
        lastSeen,
      ];
}
