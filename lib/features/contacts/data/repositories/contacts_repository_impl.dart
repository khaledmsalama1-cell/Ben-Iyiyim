import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/contact_entity.dart';
import '../../domain/repositories/contacts_repository.dart';
import '../datasources/contacts_remote_datasource.dart';
import '../models/contact_model.dart';

class ContactsRepositoryImpl implements ContactsRepository {
  final ContactsRemoteDataSource _remoteDataSource;

  ContactsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<ContactEntity>>> getContacts(String uid) async {
    try {
      final contacts = await _remoteDataSource.getContacts(uid);
      return Right(contacts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Kontağlar alınamadı: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<ContactEntity>>> contactsStream(String uid) {
    return _remoteDataSource.contactsStream(uid).map(
          (contacts) => Right<Failure, List<ContactEntity>>(contacts),
        ).handleError(
          (error) => Left<Failure, List<ContactEntity>>(
            ServerFailure('Kontağlar yüklenemedi: $error'),
          ),
        );
  }

  @override
  Future<Either<Failure, ContactEntity>> addContact({
    required String uid,
    required String name,
    required String phone,
    String? email,
    String? relationship,
  }) async {
    try {
      final contact = await _remoteDataSource.addContact(
        uid: uid,
        name: name,
        phone: phone,
        email: email,
        relationship: relationship,
      );
      return Right(contact);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Kontağ eklenemedi: $e'));
    }
  }

  @override
  Future<Either<Failure, ContactEntity>> updateContact({
    required String uid,
    required ContactEntity contact,
  }) async {
    try {
      final result = await _remoteDataSource.updateContact(
        uid: uid,
        contact: ContactModel.fromEntity(contact),
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Kontağ güncellenemedi: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteContact({
    required String uid,
    required String contactId,
  }) async {
    try {
      await _remoteDataSource.deleteContact(uid: uid, contactId: contactId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Kontağ silinemedi: $e'));
    }
  }
}
