import 'package:equatable/equatable.dart';

/// Base class for all domain-layer failures
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Failure from server/Firebase operations
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// Failure from local cache/storage
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Network connectivity failure
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'İnternet bağlantısı bulunamadı']);
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Permission failure
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}
