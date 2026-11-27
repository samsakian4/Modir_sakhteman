import 'package:shamsi_date/shamsi_date.dart' hide DateFormatter;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/enums/expense_category.dart';
import '../../domain/entities/monthly_report.dart';

abstract class ReportRemoteDataSource {
  Future<MonthlyReport> getMonthlyReport({required int jalaliYear, required int jalaliMonth});
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  ReportRemoteDataSourceImpl(this._client);
  final SupabaseClient _client;

  @override
  Future<MonthlyReport> getMonthlyReport({required int jalaliYear, required int jalaliMonth}) async {
    return _guard(() async {
      final List<Map<String, dynamic>> paymentRows = await _client.from(SupabaseTables.chargePayments).select().eq('year', jalaliYear).eq('month', jalaliMonth).eq('is_void', false);
      final double totalIncome = paymentRows.fold<double>(0, (sum, row) => sum + (row['amount'] as num).toDouble());

      final Jalali start = Jalali(jalaliYear, jalaliMonth, 1);
      final Jalali end = jalaliMonth == 12 ? Jalali(jalaliYear + 1, 1, 1) : Jalali(jalaliYear, jalaliMonth + 1, 1);
      final String startStr = DateFormatter.toGregorian(start).toIso8601String().split('T').first;
      final String endStr = DateFormatter.toGregorian(end).toIso8601String().split('T').first;

      final List<Map<String, dynamic>> expenseRows = await _client.from(SupabaseTables.expenses).select().eq('is_void', false).gte('expense_date', startStr).lt('expense_date', endStr);

      double totalExpenses = 0;
      final Map<ExpenseCategory, double> byCategory = {};
      for (final Map<String, dynamic> row in expenseRows) {
        final double amount = (row['amount'] as num).toDouble();
        totalExpenses += amount;
        final ExpenseCategory category = ExpenseCategory.fromDbValue(row['category'] as String);
        byCategory[category] = (byCategory[category] ?? 0) + amount;
      }

      int paidCount = 0;
      int totalActive = 0;
      try {
        final List<dynamic> statusRows = await _client.rpc(SupabaseRpc.getApartmentsWithStatus, params: {'p_jalali_year': jalaliYear, 'p_jalali_month': jalaliMonth});
        totalActive = statusRows.length;
        for (final dynamic row in statusRows) {
          final Map<String, dynamic> map = row as Map<String, dynamic>;
          if (map['is_paid_this_month'] as bool? ?? false) paidCount++;
        }
      } catch (_) {
        // Apartment status breakdown is a best-effort addition to the report; if it fails
        // the core income/expense figures above are still returned.
      }

      final List<CategoryBreakdown> breakdown = [for (final MapEntry<ExpenseCategory, double> entry in byCategory.entries) CategoryBreakdown(category: entry.key, amount: entry.value)];
      breakdown.sort((a, b) => b.amount.compareTo(a.amount));

      return MonthlyReport(
        jalaliYear: jalaliYear,
        jalaliMonth: jalaliMonth,
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        paidUnitsCount: paidCount,
        unpaidUnitsCount: totalActive - paidCount,
        totalActiveApartments: totalActive,
        categoryBreakdown: breakdown,
      );
    });
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PostgrestException catch (e) {
      if (e.code == '42501' || e.message.toLowerCase().contains('rls')) throw const PermissionException();
      throw ServerException(e.message);
    } on AppException {
      rethrow;
    } catch (e) {
      final String text = e.toString().toLowerCase();
      if (text.contains('socket') || text.contains('network') || text.contains('timeout') || text.contains('failed to fetch') || text.contains('clientexception')) throw const NetworkException();
      throw ServerException(e.toString());
    }
  }
}
