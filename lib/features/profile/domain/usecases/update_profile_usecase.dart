import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository _repository;

  const UpdateProfileUseCase(this._repository);

  Future<Either<Failure, ProfileEntity>> call(UpdateProfileParams params) {
    return _repository.updateProfile(
      uid: params.uid,
      displayName: params.displayName,
      phone: params.phone,
      photoUrl: params.photoUrl,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String uid;
  final String? displayName;
  final String? phone;
  final String? photoUrl;

  const UpdateProfileParams({
    required this.uid,
    this.displayName,
    this.phone,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [uid, displayName, phone, photoUrl];
}
