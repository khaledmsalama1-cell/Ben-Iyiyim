import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/contact_entity.dart';
import '../repositories/contacts_repository.dart';

class UpdateContactUseCase {
  final ContactsRepository _repository;

  const UpdateContactUseCase(this._repository);

  Future<Either<Failure, ContactEntity>> call(UpdateContactParams params) {
    return _repository.updateContact(
      uid: params.uid,
      contact: params.contact,
    );
  }
}

class UpdateContactParams extends Equatable {
  final String uid;
  final ContactEntity contact;

  const UpdateContactParams({required this.uid, required this.contact});

  @override
  List<Object> get props => [uid, contact];
}
