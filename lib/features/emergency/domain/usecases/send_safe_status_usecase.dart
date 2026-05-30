import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/emergency_status_entity.dart';
import '../repositories/emergency_repository.dart';

/// Use case: Send the "I am safe" emergency status
class SendSafeStatusUseCase {
  final EmergencyRepository _repository;

  const SendSafeStatusUseCase(this._repository);

  Future<Either<Failure, EmergencyStatusEntity>> call(
      SendSafeStatusParams params) {
    return _repository.sendSafeStatus(
      uid: params.uid,
      userName: params.userName,
      contactTokens: params.contactTokens,
      contactAppUserIds: params.contactAppUserIds,
      status: params.status,
    );
  }
}

class SendSafeStatusParams extends Equatable {
  final String uid;
  final String userName;
  final List<String> contactTokens;
  final List<String> contactAppUserIds;
  final EmergencyStatusType status;

  const SendSafeStatusParams({
    required this.uid,
    required this.userName,
    required this.contactTokens,
    this.contactAppUserIds = const [],
    this.status = EmergencyStatusType.safe,
  });

  @override
  List<Object> get props => [uid, userName, contactTokens, contactAppUserIds, status];
}
