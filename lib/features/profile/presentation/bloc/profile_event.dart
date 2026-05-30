import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {
  final String uid;

  const LoadProfileEvent(this.uid);

  @override
  List<Object> get props => [uid];
}

class UpdateProfileEvent extends ProfileEvent {
  final String uid;
  final String? displayName;
  final String? phone;
  final String? photoUrl;

  const UpdateProfileEvent({
    required this.uid,
    this.displayName,
    this.phone,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [uid, displayName, phone, photoUrl];
}

class DeleteAccountEvent extends ProfileEvent {
  final String uid;

  const DeleteAccountEvent(this.uid);

  @override
  List<Object> get props => [uid];
}
