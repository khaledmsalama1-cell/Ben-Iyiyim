import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/contact_entity.dart';

/// Data model for emergency contact with Firestore serialization
class ContactModel extends ContactEntity {
  const ContactModel({
    required super.id,
    required super.name,
    required super.phone,
    super.email,
    super.relationship,
    super.fcmToken,
    super.appUserId,
    super.createdAt,
  });

  factory ContactModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ContactModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String?,
      relationship: data['relationship'] as String?,
      fcmToken: data['fcmToken'] as String?,
      appUserId: data['appUserId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String?,
      relationship: map['relationship'] as String?,
      fcmToken: map['fcmToken'] as String?,
      appUserId: map['appUserId'] as String?,
    );
  }

  factory ContactModel.fromEntity(ContactEntity entity) {
    return ContactModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      email: entity.email,
      relationship: entity.relationship,
      fcmToken: entity.fcmToken,
      appUserId: entity.appUserId,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'relationship': relationship,
      'fcmToken': fcmToken,
      'appUserId': appUserId,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
