import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, ProfileEntity>> getProfile(String uid) async {
    try {
      final profile = await _remoteDataSource.getProfile(uid);
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Profil alınamadı: $e'));
    }
  }

  @override
  Stream<Either<Failure, ProfileEntity>> profileStream(String uid) {
    return _remoteDataSource.profileStream(uid).map(
          (profile) => Right<Failure, ProfileEntity>(profile),
        ).handleError(
          (error) => Left<Failure, ProfileEntity>(
            ServerFailure('Profil yüklenemedi: $error'),
          ),
        );
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile({
    required String uid,
    String? displayName,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      final profile = await _remoteDataSource.updateProfile(
        uid: uid,
        displayName: displayName,
        phone: phone,
        photoUrl: photoUrl,
      );
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Profil güncellenemedi: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String uid) async {
    try {
      await _remoteDataSource.deleteAccount(uid);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Hesap silinemedi: $e'));
    }
  }
}
