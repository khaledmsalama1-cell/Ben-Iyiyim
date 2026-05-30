import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository _repository;

  const GetProfileUseCase(this._repository);

  Future<Either<Failure, ProfileEntity>> call(String uid) {
    return _repository.getProfile(uid);
  }

  Stream<Either<Failure, ProfileEntity>> stream(String uid) {
    return _repository.profileStream(uid);
  }
}
