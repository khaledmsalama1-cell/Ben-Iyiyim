import 'package:equatable/equatable.dart';
import '../../domain/entities/emergency_status_entity.dart';

enum EmergencyStatus { initial, loading, sent, offline, smsFallbackTriggered, error, loaded }

class EmergencyState extends Equatable {
  final EmergencyStatus status;
  final EmergencyStatusEntity? activeStatus;
  final String? errorMessage;
  final int notifiedCount;
  final String? smsPhone;
  final String? smsMessage;

  const EmergencyState({
    this.status = EmergencyStatus.initial,
    this.activeStatus,
    this.errorMessage,
    this.notifiedCount = 0,
    this.smsPhone,
    this.smsMessage,
  });

  EmergencyState copyWith({
    EmergencyStatus? status,
    EmergencyStatusEntity? activeStatus,
    String? errorMessage,
    int? notifiedCount,
    String? smsPhone,
    String? smsMessage,
  }) {
    return EmergencyState(
      status: status ?? this.status,
      activeStatus: activeStatus ?? this.activeStatus,
      errorMessage: errorMessage,
      notifiedCount: notifiedCount ?? this.notifiedCount,
      smsPhone: smsPhone ?? this.smsPhone,
      smsMessage: smsMessage ?? this.smsMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        activeStatus,
        errorMessage,
        notifiedCount,
        smsPhone,
        smsMessage,
      ];
}
