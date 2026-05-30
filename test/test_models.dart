import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ben_iyiyim/features/auth/data/models/user_model.dart';
import 'package:ben_iyiyim/features/auth/domain/entities/user_entity.dart';
import 'package:ben_iyiyim/features/profile/data/models/profile_model.dart';
import 'package:ben_iyiyim/features/profile/domain/entities/profile_entity.dart';
import 'package:ben_iyiyim/features/contacts/data/models/contact_model.dart';
import 'package:ben_iyiyim/features/contacts/domain/entities/contact_entity.dart';
import 'package:ben_iyiyim/features/emergency/data/models/emergency_status_model.dart';
import 'package:ben_iyiyim/features/emergency/domain/entities/emergency_status_entity.dart';

// Mock classes for Firestore DocumentSnapshot
// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('UserModel Tests', () {
    test('should correctly deserialize from Firestore DocumentSnapshot', () {
      final mockDoc = MockDocumentSnapshot();
      final testDate = DateTime(2026, 1, 1, 12, 0, 0);
      final timestamp = Timestamp.fromDate(testDate);

      when(() => mockDoc.id).thenReturn('user_uid_123');
      when(() => mockDoc.data()).thenReturn({
        'email': 'user@example.com',
        'displayName': 'John Doe',
        'photoUrl': 'https://example.com/photo.jpg',
        'phone': '5551234567',
        'fcmToken': 'token_abc_123',
        'createdAt': timestamp,
        'lastSeen': timestamp,
      });

      final model = UserModel.fromFirestore(mockDoc);

      expect(model.uid, 'user_uid_123');
      expect(model.email, 'user@example.com');
      expect(model.displayName, 'John Doe');
      expect(model.photoUrl, 'https://example.com/photo.jpg');
      expect(model.phone, '5551234567');
      expect(model.fcmToken, 'token_abc_123');
      expect(model.createdAt, testDate);
      expect(model.lastSeen, testDate);
    });

    test('should correctly serialize to Firestore Map', () {
      const model = UserModel(
        uid: 'user_uid_123',
        email: 'user@example.com',
        displayName: 'John Doe',
        photoUrl: 'https://example.com/photo.jpg',
        phone: '5551234567',
        fcmToken: 'token_abc_123',
      );

      final map = model.toFirestore();

      expect(map['email'], 'user@example.com');
      expect(map['displayName'], 'John Doe');
      expect(map['photoUrl'], 'https://example.com/photo.jpg');
      expect(map['phone'], '5551234567');
      expect(map['fcmToken'], 'token_abc_123');
      expect(map['lastSeen'], isA<FieldValue>());
    });

    test('should correctly serialize and deserialize to/from local storage Map', () {
      const model = UserModel(
        uid: 'user_uid_123',
        email: 'user@example.com',
        displayName: 'John Doe',
        photoUrl: 'https://example.com/photo.jpg',
        phone: '5551234567',
        fcmToken: 'token_abc_123',
      );

      final map = model.toMap();
      final deserialized = UserModel.fromMap(map);

      expect(deserialized.uid, model.uid);
      expect(deserialized.email, model.email);
      expect(deserialized.displayName, model.displayName);
      expect(deserialized.photoUrl, model.photoUrl);
      expect(deserialized.phone, model.phone);
      expect(deserialized.fcmToken, model.fcmToken);
    });

    test('should construct model from UserEntity', () {
      const entity = UserEntity(
        uid: 'user_uid_123',
        email: 'user@example.com',
        displayName: 'John Doe',
        photoUrl: 'https://example.com/photo.jpg',
        phone: '5551234567',
        fcmToken: 'token_abc_123',
      );

      final model = UserModel.fromEntity(entity);

      expect(model.uid, entity.uid);
      expect(model.email, entity.email);
      expect(model.displayName, entity.displayName);
      expect(model.photoUrl, entity.photoUrl);
    });
  });

  group('ProfileModel Tests', () {
    test('should correctly deserialize from Firestore DocumentSnapshot', () {
      final mockDoc = MockDocumentSnapshot();
      final testDate = DateTime(2026, 2, 2, 10, 0, 0);
      final timestamp = Timestamp.fromDate(testDate);

      when(() => mockDoc.id).thenReturn('profile_uid_123');
      when(() => mockDoc.data()).thenReturn({
        'email': 'profile@example.com',
        'displayName': 'Jane Doe',
        'photoUrl': 'https://example.com/jane.jpg',
        'phone': '5559876543',
        'createdAt': timestamp,
      });

      final model = ProfileModel.fromFirestore(mockDoc);

      expect(model.uid, 'profile_uid_123');
      expect(model.email, 'profile@example.com');
      expect(model.displayName, 'Jane Doe');
      expect(model.photoUrl, 'https://example.com/jane.jpg');
      expect(model.phone, '5559876543');
      expect(model.createdAt, testDate);
    });

    test('should correctly serialize to Firestore Map', () {
      const model = ProfileModel(
        uid: 'profile_uid_123',
        email: 'profile@example.com',
        displayName: 'Jane Doe',
        photoUrl: 'https://example.com/jane.jpg',
        phone: '5559876543',
      );

      final map = model.toFirestore();

      expect(map['displayName'], 'Jane Doe');
      expect(map['phone'], '5559876543');
      expect(map['photoUrl'], 'https://example.com/jane.jpg');
      expect(map['updatedAt'], isA<FieldValue>());
    });

    test('should construct model from ProfileEntity', () {
      const entity = ProfileEntity(
        uid: 'profile_uid_123',
        email: 'profile@example.com',
        displayName: 'Jane Doe',
        photoUrl: 'https://example.com/jane.jpg',
        phone: '5559876543',
      );

      final model = ProfileModel.fromEntity(entity);

      expect(model.uid, entity.uid);
      expect(model.email, entity.email);
      expect(model.displayName, entity.displayName);
      expect(model.photoUrl, entity.photoUrl);
      expect(model.phone, entity.phone);
    });
  });

  group('ContactModel Tests', () {
    test('should correctly deserialize from Firestore DocumentSnapshot', () {
      final mockDoc = MockDocumentSnapshot();
      final testDate = DateTime(2026, 3, 3, 9, 0, 0);
      final timestamp = Timestamp.fromDate(testDate);

      when(() => mockDoc.id).thenReturn('contact_id_123');
      when(() => mockDoc.data()).thenReturn({
        'name': 'Emergency Contact 1',
        'phone': '5550001111',
        'relationship': 'Family',
        'fcmToken': 'contact_token',
        'createdAt': timestamp,
      });

      final model = ContactModel.fromFirestore(mockDoc);

      expect(model.id, 'contact_id_123');
      expect(model.name, 'Emergency Contact 1');
      expect(model.phone, '5550001111');
      expect(model.relationship, 'Family');
      expect(model.fcmToken, 'contact_token');
      expect(model.createdAt, testDate);
    });

    test('should correctly serialize to Firestore Map', () {
      final testDate = DateTime(2026, 3, 3, 9, 0, 0);
      final model = ContactModel(
        id: 'contact_id_123',
        name: 'Emergency Contact 1',
        phone: '5550001111',
        relationship: 'Family',
        fcmToken: 'contact_token',
        createdAt: testDate,
      );

      final map = model.toFirestore();

      expect(map['name'], 'Emergency Contact 1');
      expect(map['phone'], '5550001111');
      expect(map['relationship'], 'Family');
      expect(map['fcmToken'], 'contact_token');
      expect(map['createdAt'], isA<Timestamp>());
      expect((map['createdAt'] as Timestamp).toDate(), testDate);
    });

    test('should serialize to serverTimestamp if createdAt is null', () {
      const model = ContactModel(
        id: 'contact_id_123',
        name: 'Emergency Contact 1',
        phone: '5550001111',
        relationship: 'Family',
        fcmToken: 'contact_token',
        createdAt: null,
      );

      final map = model.toFirestore();

      expect(map['createdAt'], isA<FieldValue>());
    });

    test('should construct model from ContactEntity', () {
      const entity = ContactEntity(
        id: 'contact_id_123',
        name: 'Emergency Contact 1',
        phone: '5550001111',
        relationship: 'Family',
        fcmToken: 'contact_token',
      );

      final model = ContactModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.name, entity.name);
      expect(model.phone, entity.phone);
    });
  });

  group('EmergencyStatusModel Tests', () {
    test('should correctly deserialize safe status from Firestore DocumentSnapshot', () {
      final mockDoc = MockDocumentSnapshot();
      final testDate = DateTime(2026, 4, 4, 15, 0, 0);
      final timestamp = Timestamp.fromDate(testDate);

      when(() => mockDoc.id).thenReturn('status_id_123');
      when(() => mockDoc.data()).thenReturn({
        'status': 'safe',
        'timestamp': timestamp,
        'userName': 'User Safe',
        'userPhone': '5559998888',
      });

      final model = EmergencyStatusModel.fromFirestore(mockDoc);

      expect(model.uid, 'status_id_123');
      expect(model.status, EmergencyStatusType.safe);
      expect(model.timestamp, testDate);
      expect(model.userName, 'User Safe');
      expect(model.userPhone, '5559998888');
    });

    test('should correctly deserialize needHelp status from Firestore DocumentSnapshot', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('status_id_123');
      when(() => mockDoc.data()).thenReturn({
        'status': 'needHelp',
      });

      final model = EmergencyStatusModel.fromFirestore(mockDoc);
      expect(model.status, EmergencyStatusType.needHelp);
    });

    test('should correctly deserialize injured status from Firestore DocumentSnapshot', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('status_id_123');
      when(() => mockDoc.data()).thenReturn({
        'status': 'injured',
      });

      final model = EmergencyStatusModel.fromFirestore(mockDoc);
      expect(model.status, EmergencyStatusType.injured);
    });

    test('should correctly deserialize unknown status from Firestore DocumentSnapshot', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('status_id_123');
      when(() => mockDoc.data()).thenReturn({
        'status': 'something_else',
      });

      final model = EmergencyStatusModel.fromFirestore(mockDoc);
      expect(model.status, EmergencyStatusType.unknown);
    });

    test('should correctly serialize to Firestore Map', () {
      final model = EmergencyStatusModel(
        uid: 'status_id_123',
        status: EmergencyStatusType.safe,
        timestamp: DateTime.now(),
        userName: 'User Safe',
        userPhone: '5559998888',
      );

      final map = model.toFirestore();

      expect(map['status'], 'safe');
      expect(map['timestamp'], isA<FieldValue>());
      expect(map['userName'], 'User Safe');
      expect(map['userPhone'], '5559998888');
    });

    test('should serialize statuses correctly', () {
      const statuses = [
        EmergencyStatusType.safe,
        EmergencyStatusType.needHelp,
        EmergencyStatusType.injured,
        EmergencyStatusType.unknown,
      ];

      const expectedStrs = ['safe', 'needHelp', 'injured', 'unknown'];

      for (int i = 0; i < statuses.length; i++) {
        final model = EmergencyStatusModel(
          uid: 'uid',
          status: statuses[i],
          timestamp: DateTime.now(),
        );
        expect(model.toFirestore()['status'], expectedStrs[i]);
      }
    });
  });
}
