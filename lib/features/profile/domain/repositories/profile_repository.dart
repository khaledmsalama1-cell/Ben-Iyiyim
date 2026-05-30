import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile(String uid);
  Stream<Either<Failure, ProfileEntity>> profileStream(String uid);
  Future<Either<Failure, ProfileEntity>> updateProfile({
    required String uid,
    String? displayName,
    String? phone,
    String? photoUrl,
  });
  Future<Either<Failure, void>> deleteAccount(String uid);
}
