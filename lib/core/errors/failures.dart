import 'exceptions.dart';

abstract class Failure {
  const Failure(this.message);
  final String message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'خطای غیرمنتظره‌ای رخ داد. لطفاً دوباره تلاش کنید.']);
}

Failure mapExceptionToFailure(Object error) {
  return switch (error) {
    NetworkException e => NetworkFailure(e.message),
    AuthException e => AuthFailure(e.message),
    ValidationException e => ValidationFailure(e.message),
    StorageException e => StorageFailure(e.message),
    PermissionException e => PermissionFailure(e.message),
    CacheException e => CacheFailure(e.message),
    ServerException e => ServerFailure(e.message),
    _ => UnknownFailure(error.toString()),
  };
}
