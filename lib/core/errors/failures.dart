abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Please check your internet connection']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation error']);
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Storage error occurred']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unknown error occurred']);
}
