import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/firestore_service.dart';
import '../models/contact_model.dart';

abstract class ContactsRemoteDataSource {
  Future<List<ContactModel>> getContacts(String uid);
  Stream<List<ContactModel>> contactsStream(String uid);
  Future<ContactModel> addContact({
    required String uid,
    required String name,
    required String phone,
    String? email,
    String? relationship,
  });
  Future<ContactModel> updateContact({
    required String uid,
    required ContactModel contact,
  });
  Future<void> deleteContact({required String uid, required String contactId});
}

class ContactsRemoteDataSourceImpl implements ContactsRemoteDataSource {
  final FirestoreService _firestoreService;

  ContactsRemoteDataSourceImpl(this._firestoreService);

  @override
  Future<List<ContactModel>> getContacts(String uid) async {
    try {
      final snapshot = await _firestoreService.getContacts(uid);
      
      print('---- EXISTING FIREBASE STRUCTURE FOR CONTACTS ----');
      for (var doc in snapshot.docs) {
        print('Doc ID: ${doc.id}');
        print('Data: ${doc.data()}');
      }
      print('--------------------------------------------------');

      return snapshot.docs
          .map((doc) => ContactModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Kontağlar yüklenemedi: $e', originalError: e);
    }
  }

  @override
  Stream<List<ContactModel>> contactsStream(String uid) {
    return _firestoreService.contactsStream(uid).map(
          (snapshot) => snapshot.docs
              .map((doc) => ContactModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<ContactModel> addContact({
    required String uid,
    required String name,
    required String phone,
    String? email,
    String? relationship,
  }) async {
    try {
      String? foundAppUserId;
      String? foundFcmToken;

      try {
        final usersRef = _firestoreService.usersRef;
        
        // Check by email first
        if (email != null && email.isNotEmpty) {
          final emailQuery = await usersRef.where('email', isEqualTo: email).get();
          if (emailQuery.docs.isNotEmpty) {
            foundAppUserId = emailQuery.docs.first.id;
            foundFcmToken = emailQuery.docs.first.data()['fcmToken'] as String?;
          }
        }

        // If not found by email, check by phone
        if (foundAppUserId == null && phone.isNotEmpty) {
          final phoneQuery = await usersRef.where('phone', isEqualTo: phone).get();
          if (phoneQuery.docs.isNotEmpty) {
            foundAppUserId = phoneQuery.docs.first.id;
            foundFcmToken = phoneQuery.docs.first.data()['fcmToken'] as String?;
          }
        }
      } catch (_) {
        // Ignore errors during lookup, continue adding contact
      }

      final data = {
        'name': name,
        'phone': phone,
        if (email != null) 'email': email,
        'relationship': relationship,
        if (foundAppUserId != null) 'appUserId': foundAppUserId,
        if (foundFcmToken != null) 'fcmToken': foundFcmToken,
        'createdAt': _firestoreService.serverTimestamp,
      };
      final docRef = await _firestoreService.addContact(uid, data);
      return ContactModel(
        id: docRef.id,
        name: name,
        phone: phone,
        email: email,
        relationship: relationship,
        appUserId: foundAppUserId,
        fcmToken: foundFcmToken,
      );
    } catch (e) {
      throw ServerException('Kontağ eklenemedi: $e', originalError: e);
    }
  }

  @override
  Future<ContactModel> updateContact({
    required String uid,
    required ContactModel contact,
  }) async {
    try {
      await _firestoreService.updateContact(
          uid, contact.id, contact.toFirestore());
      return contact;
    } catch (e) {
      throw ServerException('Kontağ güncellenemedi: $e', originalError: e);
    }
  }

  @override
  Future<void> deleteContact({
    required String uid,
    required String contactId,
  }) async {
    try {
      await _firestoreService.deleteContact(uid, contactId);
    } catch (e) {
      throw ServerException('Kontağ silinemedi: $e', originalError: e);
    }
  }
}
