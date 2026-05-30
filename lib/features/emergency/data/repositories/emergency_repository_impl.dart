import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/emergency_status_entity.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../datasources/emergency_remote_datasource.dart';

class EmergencyRepositoryImpl implements EmergencyRepository {
  final EmergencyRemoteDataSource _remoteDataSource;

  EmergencyRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, EmergencyStatusEntity>> sendSafeStatus({
    required String uid,
    required String userName,
    required List<String> contactTokens,
    List<String> contactAppUserIds = const [],
    EmergencyStatusType status = EmergencyStatusType.safe,
  }) async {
    try {
      final result = await _remoteDataSource.sendSafeStatus(
        uid: uid,
        userName: userName,
        contactTokens: contactTokens,
        contactAppUserIds: contactAppUserIds,
        status: status,
      );
      return Right(result);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Acil durum mesajı gönderilemedi: $e'));
    }
  }

  @override
  Future<Either<Failure, EmergencyStatusEntity?>> getStatus(String uid) async {
    try {
      final result = await _remoteDataSource.getStatus(uid);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Durum alınamadı: $e'));
    }
  }

  @override
  Stream<EmergencyStatusEntity?> statusStream(String uid) {
    return _remoteDataSource.statusStream(uid);
  }
}
