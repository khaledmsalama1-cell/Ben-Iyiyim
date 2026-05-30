import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSignInEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthRegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  final String phone;

  const AuthRegisterEvent({
    required this.email,
    required this.password,
    required this.displayName,
    required this.phone,
  });

  @override
  List<Object> get props => [email, password, displayName, phone];
}

class AuthSignOutEvent extends AuthEvent {}

class AuthForgotPasswordEvent extends AuthEvent {
  final String email;

  const AuthForgotPasswordEvent(this.email);

  @override
  List<Object> get props => [email];
}

class AuthCheckStatusEvent extends AuthEvent {}

class AuthStateChangedEvent extends AuthEvent {
  // Fired by the auth state stream
}

class AuthUserChangedEvent extends AuthEvent {
  final UserEntity? user;

  const AuthUserChangedEvent(this.user);

  @override
  List<Object?> get props => [user];
}
