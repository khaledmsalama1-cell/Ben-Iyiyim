import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/contact_entity.dart';
import '../repositories/contacts_repository.dart';

class GetContactsUseCase {
  final ContactsRepository _repository;

  const GetContactsUseCase(this._repository);

  Future<Either<Failure, List<ContactEntity>>> call(String uid) {
    return _repository.getContacts(uid);
  }

  Stream<Either<Failure, List<ContactEntity>>> stream(String uid) {
    return _repository.contactsStream(uid);
  }
}
