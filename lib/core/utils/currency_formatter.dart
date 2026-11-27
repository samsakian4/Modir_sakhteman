import 'package:intl/intl.dart';

abstract class CurrencyFormatter {
  CurrencyFormatter._();
  static const List<String> _persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

  static String toPersianDigits(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final ch = String.fromCharCode(rune);
      final int? d = int.tryParse(ch);
      buffer.write(d != null ? _persianDigits[d] : ch);
    }
    return buffer.toString();
  }

  static String toEnglishDigits(String input) {
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final ch = String.fromCharCode(rune);
      final int pIdx = persian.indexOf(ch);
      final int aIdx = arabic.indexOf(ch);
      if (pIdx != -1) {
        buffer.write(pIdx.toString());
      } else if (aIdx != -1) {
        buffer.write(aIdx.toString());
      } else {
        buffer.write(ch);
      }
    }
    return buffer.toString();
  }

  static String formatAmount(num amount) => toPersianDigits(NumberFormat.decimalPattern('en').format(amount));
  static String formatWithUnit(num amount) => '${formatAmount(amount)} تومان';

  static int? parseToInt(String formatted) {
    final String normalized = toEnglishDigits(formatted).replaceAll(',', '').trim();
    if (normalized.isEmpty) return null;
    return int.tryParse(normalized);
  }
}
