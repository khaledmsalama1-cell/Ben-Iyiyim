import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/contacts_repository.dart';

class DeleteContactUseCase {
  final ContactsRepository _repository;

  const DeleteContactUseCase(this._repository);

  Future<Either<Failure, void>> call(DeleteContactParams params) {
    return _repository.deleteContact(
      uid: params.uid,
      contactId: params.contactId,
    );
  }
}

class DeleteContactParams extends Equatable {
  final String uid;
  final String contactId;

  const DeleteContactParams({required this.uid, required this.contactId});

  @override
  List<Object> get props => [uid, contactId];
}
