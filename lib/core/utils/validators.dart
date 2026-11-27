import '../constants/app_constants.dart';
import 'currency_formatter.dart';

abstract class Validators {
  Validators._();

  static String? required(String? value, {String fieldName = 'این فیلد'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName اجباری است.';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'شماره موبایل اجباری است.';
    final String normalized = CurrencyFormatter.toEnglishDigits(value.trim());
    if (!RegExp(AppConstants.iranPhoneRegexPattern).hasMatch(normalized)) return 'شماره موبایل معتبر نیست.';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'رمز عبور اجباری است.';
    if (value.length < AppConstants.minPasswordLength) return 'رمز عبور باید حداقل ${AppConstants.minPasswordLength} کاراکتر باشد.';
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) return 'لطفاً مبلغ معتبر وارد کنید.';
    final int? parsed = CurrencyFormatter.parseToInt(value);
    if (parsed == null || parsed <= 0) return 'لطفاً مبلغ معتبر وارد کنید.';
    return null;
  }

  static String? unitNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'شماره واحد اجباری است.';
    return null;
  }

  static String? notFutureDate(DateTime? date) {
    if (date == null) return 'تاریخ اجباری است.';
    if (date.isAfter(DateTime.now())) return 'تاریخ نمی‌تواند در آینده باشد.';
    return null;
  }
}
