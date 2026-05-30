import 'package:equatable/equatable.dart';
import '../../domain/entities/contact_entity.dart';

enum ContactsStatus { initial, loading, loaded, adding, error, actionSuccess }

class ContactsState extends Equatable {
  final ContactsStatus status;
  final List<ContactEntity> contacts;
  final String? errorMessage;
  final String? successMessage;
  
  // Keep track of currentContacts while adding/modifying if needed, 
  // but it's simpler to just use 'contacts' for the UI and set status=adding
  
  const ContactsState({
    this.status = ContactsStatus.initial,
    this.contacts = const [],
    this.errorMessage,
    this.successMessage,
  });

  bool get hasMaxContacts => contacts.length >= 5;
  int get remainingSlots => 5 - contacts.length;

  ContactsState copyWith({
    ContactsStatus? status,
    List<ContactEntity>? contacts,
    String? errorMessage,
    String? successMessage,
  }) {
    return ContactsState(
      status: status ?? this.status,
      contacts: contacts ?? this.contacts,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [status, contacts, errorMessage, successMessage];
}
