import 'package:equatable/equatable.dart';
import '../../domain/entities/contact_entity.dart';

abstract class ContactsEvent extends Equatable {
  const ContactsEvent();

  @override
  List<Object?> get props => [];
}

class LoadContactsEvent extends ContactsEvent {
  final String uid;

  const LoadContactsEvent(this.uid);

  @override
  List<Object> get props => [uid];
}

class AddContactEvent extends ContactsEvent {
  final String uid;
  final String name;
  final String phone;
  final String? email;
  final String? relationship;

  const AddContactEvent({
    required this.uid,
    required this.name,
    required this.phone,
    this.email,
    this.relationship,
  });

  @override
  List<Object?> get props => [uid, name, phone, email, relationship];
}

class UpdateContactEvent extends ContactsEvent {
  final String uid;
  final ContactEntity contact;

  const UpdateContactEvent({required this.uid, required this.contact});

  @override
  List<Object> get props => [uid, contact];
}

class DeleteContactEvent extends ContactsEvent {
  final String uid;
  final String contactId;

  const DeleteContactEvent({required this.uid, required this.contactId});

  @override
  List<Object> get props => [uid, contactId];
}
