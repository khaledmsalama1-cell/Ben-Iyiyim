/// Base class for data-layer exceptions
class AppException implements Exception {
  final String message;
  final int? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code, super.originalError});
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.originalError});
}

class CacheException extends AppException {
  const CacheException(super.message, {super.originalError});
}

class NetworkException extends AppException {
  const NetworkException(
      [super.message = 'İnternet bağlantısı bulunamadı']);
}

class PermissionException extends AppException {
  const PermissionException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}
