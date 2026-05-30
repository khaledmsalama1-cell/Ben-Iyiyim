import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/contact_entity.dart';

/// Contract for emergency contacts CRUD operations
abstract class ContactsRepository {
  /// Get all contacts for a user
  Future<Either<Failure, List<ContactEntity>>> getContacts(String uid);

  /// Stream of contacts for real-time updates
  Stream<Either<Failure, List<ContactEntity>>> contactsStream(String uid);

  /// Add a new contact
  Future<Either<Failure, ContactEntity>> addContact({
    required String uid,
    required String name,
    required String phone,
    String? email,
    String? relationship,
  });

  /// Update an existing contact
  Future<Either<Failure, ContactEntity>> updateContact({
    required String uid,
    required ContactEntity contact,
  });

  /// Delete a contact
  Future<Either<Failure, void>> deleteContact({
    required String uid,
    required String contactId,
  });
}
