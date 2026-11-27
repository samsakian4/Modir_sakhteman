import 'package:shamsi_date/shamsi_date.dart';

import 'currency_formatter.dart';

abstract class DateFormatter {
  DateFormatter._();

  static const List<String> _jalaliMonths = [
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور', 'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند',
  ];

  static Jalali toJalali(DateTime dateTime) => Jalali.fromDateTime(dateTime);
  static DateTime toGregorian(Jalali jalali) => jalali.toDateTime();

  static String formatFull(DateTime dateTime) {
    final Jalali j = toJalali(dateTime);
    return '${_jalaliMonths[j.month - 1]} ${CurrencyFormatter.toPersianDigits(j.day.toString())}، ${CurrencyFormatter.toPersianDigits(j.year.toString())}';
  }

  static String formatShort(DateTime dateTime) {
    final Jalali j = toJalali(dateTime);
    final String mm = j.month.toString().padLeft(2, '0');
    final String dd = j.day.toString().padLeft(2, '0');
    return CurrencyFormatter.toPersianDigits('$dd/$mm/${j.year}');
  }

  static String jalaliMonthName(int month) {
    if (month < 1 || month > 12) return '';
    return _jalaliMonths[month - 1];
  }

  static ({int year, int month}) currentJalaliYearMonth() {
    final Jalali now = Jalali.now();
    return (year: now.year, month: now.month);
  }

  static String relativeFromNow(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'همین الان';
    if (diff.inMinutes < 60) return '${CurrencyFormatter.toPersianDigits(diff.inMinutes.toString())} دقیقه پیش';
    if (diff.inHours < 24) return '${CurrencyFormatter.toPersianDigits(diff.inHours.toString())} ساعت پیش';
    if (diff.inDays < 30) return '${CurrencyFormatter.toPersianDigits(diff.inDays.toString())} روز پیش';
    return formatShort(dateTime);
  }
}
