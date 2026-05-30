import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/contact_entity.dart';
import '../repositories/contacts_repository.dart';

class AddContactUseCase {
  final ContactsRepository _repository;

  const AddContactUseCase(this._repository);

  Future<Either<Failure, ContactEntity>> call(AddContactParams params) {
    return _repository.addContact(
      uid: params.uid,
      name: params.name,
      phone: params.phone,
      email: params.email,
      relationship: params.relationship,
    );
  }
}

class AddContactParams extends Equatable {
  final String uid;
  final String name;
  final String phone;
  final String? email;
  final String? relationship;

  const AddContactParams({
    required this.uid,
    required this.name,
    required this.phone,
    this.email,
    this.relationship,
  });

  @override
  List<Object?> get props => [uid, name, phone, email, relationship];
}
