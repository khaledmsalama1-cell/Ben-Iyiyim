import 'package:equatable/equatable.dart';
import '../../../contacts/domain/entities/contact_entity.dart';
import '../../domain/entities/emergency_status_entity.dart';

/// Events for the EmergencyBloc
abstract class EmergencyEvent extends Equatable {
  const EmergencyEvent();

  @override
  List<Object?> get props => [];
}

/// User tapped the "I am safe" button
class SendSafeStatusEvent extends EmergencyEvent {
  final String uid;
  final String userName;
  final List<ContactEntity> contacts;
  final EmergencyStatusType status;

  const SendSafeStatusEvent({
    required this.uid,
    required this.userName,
    required this.contacts,
    this.status = EmergencyStatusType.safe,
  });

  @override
  List<Object> get props => [uid, userName, contacts, status];
}

/// Load current status
class LoadEmergencyStatusEvent extends EmergencyEvent {
  final String uid;

  const LoadEmergencyStatusEvent(this.uid);

  @override
  List<Object> get props => [uid];
}

/// Trigger SMS fallback (offline mode)
class TriggerSmsFallbackEvent extends EmergencyEvent {
  final List<ContactEntity> contacts;
  final String userName;

  const TriggerSmsFallbackEvent({
    required this.contacts,
    required this.userName,
  });

  @override
  List<Object> get props => [contacts, userName];
}

/// Reset emergency state
class ResetEmergencyEvent extends EmergencyEvent {}
