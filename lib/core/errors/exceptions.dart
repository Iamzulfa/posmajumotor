abstract class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(super.message);
}

class ServerException extends AppException {
  final int? statusCode;
  ServerException(super.message, {this.statusCode});
}

class ValidationException extends AppException {
  ValidationException(super.message);
}

class CacheException extends AppException {
  CacheException(super.message);
}

class AuthException extends AppException {
  AuthException(super.message);
}

class NotFoundException extends AppException {
  NotFoundException(super.message);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(super.message);
}

class TimeoutException extends AppException {
  TimeoutException(super.message);
}
