import 'package:equatable/equatable.dart';

/// Domain entity representing an emergency contact
class ContactEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? relationship;
  final String? fcmToken;  // For push notification
  final String? appUserId; // Link to user's UID if they have an account
  final DateTime? createdAt;

  const ContactEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.relationship,
    this.fcmToken,
    this.appUserId,
    this.createdAt,
  });

  ContactEntity copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? relationship,
    String? fcmToken,
    String? appUserId,
    DateTime? createdAt,
  }) {
    return ContactEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      relationship: relationship ?? this.relationship,
      fcmToken: fcmToken ?? this.fcmToken,
      appUserId: appUserId ?? this.appUserId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, phone, email, relationship, fcmToken, appUserId, createdAt];
}
