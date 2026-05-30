import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/emergency_status_entity.dart';

/// Data model for emergency status - handles Firestore serialization
class EmergencyStatusModel extends EmergencyStatusEntity {
  const EmergencyStatusModel({
    required super.uid,
    required super.status,
    required super.timestamp,
    super.userName,
    super.userPhone,
  });

  factory EmergencyStatusModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final statusStr = data['status'] as String?;
    
    EmergencyStatusType parsedStatus;
    if (statusStr == 'safe') {
      parsedStatus = EmergencyStatusType.safe;
    } else if (statusStr == 'needHelp') {
      parsedStatus = EmergencyStatusType.needHelp;
    } else if (statusStr == 'injured') {
      parsedStatus = EmergencyStatusType.injured;
    } else {
      parsedStatus = EmergencyStatusType.unknown;
    }

    return EmergencyStatusModel(
      uid: doc.id,
      status: parsedStatus,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userName: data['userName'] as String?,
      userPhone: data['userPhone'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    String statusStr;
    switch (status) {
      case EmergencyStatusType.safe:
        statusStr = 'safe';
        break;
      case EmergencyStatusType.needHelp:
        statusStr = 'needHelp';
        break;
      case EmergencyStatusType.injured:
        statusStr = 'injured';
        break;
      case EmergencyStatusType.unknown:
        statusStr = 'unknown';
        break;
    }

    return {
      'status': statusStr,
      'timestamp': FieldValue.serverTimestamp(),
      'userName': userName,
      'userPhone': userPhone,
    };
  }
}
