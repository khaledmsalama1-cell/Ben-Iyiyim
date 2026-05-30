import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/emergency_status_entity.dart';

/// Contract for emergency status operations
abstract class EmergencyRepository {
  /// Send status to Firestore + notify contacts via FCM
  Future<Either<Failure, EmergencyStatusEntity>> sendSafeStatus({
    required String uid,
    required String userName,
    required List<String> contactTokens,
    List<String> contactAppUserIds = const [],
    EmergencyStatusType status = EmergencyStatusType.safe,
  });

  /// Get latest status for a user
  Future<Either<Failure, EmergencyStatusEntity?>> getStatus(String uid);

  /// Stream of current user's status
  Stream<EmergencyStatusEntity?> statusStream(String uid);
}
