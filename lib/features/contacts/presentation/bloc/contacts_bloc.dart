import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/analytics_service.dart';
import '../../domain/entities/contact_entity.dart';
import '../../domain/usecases/add_contact_usecase.dart';
import '../../domain/usecases/delete_contact_usecase.dart';
import '../../domain/usecases/get_contacts_usecase.dart';
import '../../domain/usecases/update_contact_usecase.dart';
import 'contacts_event.dart';
import 'contacts_state.dart';

/// BLoC for managing emergency contacts
class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final GetContactsUseCase _getContactsUseCase;
  final AddContactUseCase _addContactUseCase;
  final UpdateContactUseCase _updateContactUseCase;
  final DeleteContactUseCase _deleteContactUseCase;
  final AnalyticsService _analyticsService;

  StreamSubscription? _contactsSubscription;

  ContactsBloc(
    this._getContactsUseCase,
    this._addContactUseCase,
    this._updateContactUseCase,
    this._deleteContactUseCase,
    this._analyticsService,
  ) : super(const ContactsState()) {
    on<LoadContactsEvent>(_onLoadContacts);
    on<AddContactEvent>(_onAddContact);
    on<UpdateContactEvent>(_onUpdateContact);
    on<DeleteContactEvent>(_onDeleteContact);
  }

  Future<void> _onLoadContacts(
    LoadContactsEvent event,
    Emitter<ContactsState> emit,
  ) async {
    emit(state.copyWith(status: ContactsStatus.loading));

    await emit.forEach(
      _getContactsUseCase.stream(event.uid),
      onData: (result) {
        return result.fold(
          (failure) => state.copyWith(
            status: ContactsStatus.error,
            errorMessage: failure.message,
          ),
          (contacts) => state.copyWith(
            status: ContactsStatus.loaded,
            contacts: contacts,
          ),
        );
      },
      onError: (_, __) => state.copyWith(
        status: ContactsStatus.error,
        errorMessage: 'Kontağlar yüklenemedi',
      ),
    );
  }

  Future<void> _onAddContact(
    AddContactEvent event,
    Emitter<ContactsState> emit,
  ) async {
    if (state.contacts.length >= AppConstants.maxEmergencyContacts) {
      emit(state.copyWith(
        status: ContactsStatus.error,
        errorMessage: 'En fazla 5 acil durum kontağı ekleyebilirsiniz',
      ));
      return;
    }

    emit(state.copyWith(status: ContactsStatus.adding));

    final result = await _addContactUseCase(
      AddContactParams(
        uid: event.uid,
        name: event.name,
        phone: event.phone,
        email: event.email,
        relationship: event.relationship,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ContactsStatus.error,
        errorMessage: failure.message,
      )),
      (contact) {
        // Since stream will update the contacts, we just emit actionSuccess for UI feedback
        emit(state.copyWith(
          status: ContactsStatus.actionSuccess,
          successMessage: 'Kişi başarıyla eklendi',
        ));
        _analyticsService.logContactAdded();
      },
    );
  }

  Future<void> _onUpdateContact(
    UpdateContactEvent event,
    Emitter<ContactsState> emit,
  ) async {
    emit(state.copyWith(status: ContactsStatus.adding));

    final result = await _updateContactUseCase(
      UpdateContactParams(uid: event.uid, contact: event.contact),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ContactsStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        emit(state.copyWith(
          status: ContactsStatus.actionSuccess,
          successMessage: 'Kişi başarıyla güncellendi',
        ));
      },
    );
  }

  Future<void> _onDeleteContact(
    DeleteContactEvent event,
    Emitter<ContactsState> emit,
  ) async {
    emit(state.copyWith(status: ContactsStatus.adding));

    final result = await _deleteContactUseCase(
      DeleteContactParams(uid: event.uid, contactId: event.contactId),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ContactsStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        emit(state.copyWith(
          status: ContactsStatus.actionSuccess,
          successMessage: 'Kişi silindi',
        ));
        _analyticsService.logContactDeleted();
      },
    );
  }

  @override
  Future<void> close() {
    _contactsSubscription?.cancel();
    return super.close();
  }
}
