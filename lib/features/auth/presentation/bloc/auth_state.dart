import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error, passwordResetSent }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
  final String? resetEmail;
  
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.resetEmail,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    String? resetEmail,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      resetEmail: resetEmail,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, resetEmail];
}
