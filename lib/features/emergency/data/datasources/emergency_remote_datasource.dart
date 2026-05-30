import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/firestore_service.dart';
import '../models/emergency_status_model.dart';
import '../../domain/entities/emergency_status_entity.dart';

/// Remote data source for emergency status operations
abstract class EmergencyRemoteDataSource {
  Future<EmergencyStatusModel> sendSafeStatus({
    required String uid,
    required String userName,
    required List<String> contactTokens,
    List<String> contactAppUserIds = const [],
    EmergencyStatusType status = EmergencyStatusType.safe,
  });

  Future<EmergencyStatusModel?> getStatus(String uid);
  Stream<EmergencyStatusModel?> statusStream(String uid);
}

class EmergencyRemoteDataSourceImpl implements EmergencyRemoteDataSource {
  final FirestoreService _firestoreService;

  EmergencyRemoteDataSourceImpl(this._firestoreService);

  @override
  Future<EmergencyStatusModel> sendSafeStatus({
    required String uid,
    required String userName,
    required List<String> contactTokens,
    List<String> contactAppUserIds = const [],
    EmergencyStatusType status = EmergencyStatusType.safe,
  }) async {
    try {
      String statusStr = 'safe';
      if (status == EmergencyStatusType.needHelp) {
        statusStr = 'needHelp';
      } else if (status == EmergencyStatusType.injured) {
        statusStr = 'injured';
      }

      final statusData = {
        'status': statusStr,
        'timestamp': _firestoreService.serverTimestamp,
        'userName': userName,
      };

      // Save to Firestore
      await _firestoreService.setStatus(uid, statusData);

      // Write in-app notifications for users who have the app
      for (final appUserId in contactAppUserIds) {
        if (appUserId.isNotEmpty) {
          await _firestoreService.notificationsCollection.add({
            'recipientUid': appUserId,
            'senderUid': uid,
            'senderName': userName,
            'type': 'emergency_status',
            'status': statusStr,
            'createdAt': _firestoreService.serverTimestamp,
            'read': false,
            'title': 'Acil Durum Güncellemesi',
            'body': '$userName $statusStr durumunda olduğunu bildirdi.',
          });
        }
      }

      // Return the status entity
      return EmergencyStatusModel(
        uid: uid,
        status: status,
        timestamp: DateTime.now(),
        userName: userName,
      );
    } catch (e) {
      throw ServerException('Durum gönderilemedi: $e', originalError: e);
    }
  }

  @override
  Future<EmergencyStatusModel?> getStatus(String uid) async {
    try {
      final doc = await _firestoreService.getStatus(uid);
      if (!doc.exists) return null;
      return EmergencyStatusModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Durum alınamadı: $e', originalError: e);
    }
  }

  @override
  Stream<EmergencyStatusModel?> statusStream(String uid) {
    return _firestoreService.statusStream(uid).map((doc) {
      if (!doc.exists) return null;
      return EmergencyStatusModel.fromFirestore(doc);
    });
  }
}
