import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

/// Wrapper around Cloud Firestore for clean database operations
class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService(this._firestore);

  // === COLLECTION REFERENCES ===

  CollectionReference<Map<String, dynamic>> get usersRef =>
      _firestore.collection(AppConstants.usersCollection);

  DocumentReference<Map<String, dynamic>> userDoc(String uid) =>
      usersRef.doc(uid);

  CollectionReference<Map<String, dynamic>> contactsRef(String uid) =>
      userDoc(uid).collection(AppConstants.contactsCollection);

  DocumentReference<Map<String, dynamic>> contactDoc(
          String uid, String contactId) =>
      contactsRef(uid).doc(contactId);

  CollectionReference<Map<String, dynamic>> get statusesRef =>
      _firestore.collection(AppConstants.statusesCollection);

  DocumentReference<Map<String, dynamic>> statusDoc(String uid) =>
      statusesRef.doc(uid);

  CollectionReference<Map<String, dynamic>> get notificationsCollection =>
      _firestore.collection(AppConstants.notificationsCollection);

  // === USER OPERATIONS ===

  /// Create or update user document
  Future<void> setUser(String uid, Map<String, dynamic> data) async {
    await userDoc(uid).set(data, SetOptions(merge: true));
  }

  /// Get user document
  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) async {
    return await userDoc(uid).get();
  }

  /// Stream of user document changes
  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream(String uid) {
    return userDoc(uid).snapshots();
  }

  /// Update specific user fields
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await userDoc(uid).update(data);
  }

  // === CONTACT OPERATIONS ===

  /// Get all contacts for a user
  Future<QuerySnapshot<Map<String, dynamic>>> getContacts(String uid) async {
    return await contactsRef(uid)
        .orderBy('createdAt', descending: false)
        .get();
  }

  /// Stream of user contacts
  Stream<QuerySnapshot<Map<String, dynamic>>> contactsStream(String uid) {
    return contactsRef(uid)
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  /// Add a contact
  Future<DocumentReference<Map<String, dynamic>>> addContact(
      String uid, Map<String, dynamic> data) async {
    return await contactsRef(uid).add(data);
  }

  /// Update a contact
  Future<void> updateContact(
      String uid, String contactId, Map<String, dynamic> data) async {
    await contactDoc(uid, contactId).update(data);
  }

  /// Delete a contact
  Future<void> deleteContact(String uid, String contactId) async {
    await contactDoc(uid, contactId).delete();
  }

  // === STATUS OPERATIONS ===

  /// Save emergency status
  Future<void> setStatus(String uid, Map<String, dynamic> data) async {
    await statusDoc(uid).set(data, SetOptions(merge: true));
  }

  /// Get latest status
  Future<DocumentSnapshot<Map<String, dynamic>>> getStatus(String uid) async {
    return await statusDoc(uid).get();
  }

  /// Stream of status changes
  Stream<DocumentSnapshot<Map<String, dynamic>>> statusStream(String uid) {
    return statusDoc(uid).snapshots();
  }

  // === NOTIFICATIONS ===

  /// Get notifications for a user (sorted by date)
  Stream<QuerySnapshot<Map<String, dynamic>>> notificationsStream(String uid) {
    return notificationsCollection
        .where('recipientUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  /// Mark notification as read
  Future<void> markNotificationRead(String notificationId) async {
    await notificationsCollection.doc(notificationId).update({'read': true});
  }

  // === UTILITY ===

  /// Server timestamp
  FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  /// Enable offline persistence (called once at startup)
  Future<void> enableOfflinePersistence() async {
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
}
