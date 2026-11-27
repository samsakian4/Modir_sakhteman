abstract class AppException implements Exception {
  const AppException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException([super.message = 'ذخیره اطلاعات انجام نشد. دوباره تلاش کنید.']);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'اتصال به اینترنت برقرار نیست. لطفاً دوباره تلاش کنید.']);
}

class AuthException extends AppException {
  const AuthException([super.message = 'شماره موبایل یا رمز عبور صحیح نیست.', this.code]);
  final int? code;
}

class ValidationException extends AppException {
  const ValidationException([super.message = 'لطفاً اطلاعات را به‌درستی وارد کنید.']);
}

class StorageException extends AppException {
  const StorageException([super.message = 'این نوع فایل قابل قبول نیست.']);
}

class PermissionException extends AppException {
  const PermissionException([super.message = 'شما اجازه انجام این عملیات را ندارید.']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'خطا در خواندن اطلاعات محلی.']);
}
