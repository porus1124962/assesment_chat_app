// App Exceptions
abstract class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

class AuthException extends AppException {
  AuthException(String message) : super(message);
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message);
}

class FirestoreException extends AppException {
  FirestoreException(String message) : super(message);
}

class CacheException extends AppException {
  CacheException(String message) : super(message);
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message);
}

class TimeoutException extends AppException {
  TimeoutException(String message) : super('Request timeout: $message');
}
