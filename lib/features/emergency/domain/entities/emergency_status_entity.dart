import 'package:equatable/equatable.dart';

/// Represents an emergency status record in Firestore
enum EmergencyStatusType { safe, unknown, needHelp, injured }

class EmergencyStatusEntity extends Equatable {
  final String uid;
  final EmergencyStatusType status;
  final DateTime timestamp;
  final String? userName;
  final String? userPhone;

  const EmergencyStatusEntity({
    required this.uid,
    required this.status,
    required this.timestamp,
    this.userName,
    this.userPhone,
  });

  @override
  List<Object?> get props => [uid, status, timestamp, userName, userPhone];

  EmergencyStatusEntity copyWith({
    String? uid,
    EmergencyStatusType? status,
    DateTime? timestamp,
    String? userName,
    String? userPhone,
  }) {
    return EmergencyStatusEntity(
      uid: uid ?? this.uid,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
    );
  }
}
