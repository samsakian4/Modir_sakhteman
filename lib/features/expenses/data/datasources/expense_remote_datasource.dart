import 'package:shamsi_date/shamsi_date.dart' hide DateFormatter;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/list_cache.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/models/expense.dart';

abstract class ExpenseRemoteDataSource {
  Future<List<Expense>> getExpenses({String? category, int? jalaliYear, int? jalaliMonth});
  Future<Expense> createExpense(Map<String, dynamic> data);
  Future<Expense> updateExpense(String id, Map<String, dynamic> data);
  Future<void> voidExpense(String id);
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  ExpenseRemoteDataSourceImpl(this._client);
  final SupabaseClient _client;

  @override
  Future<List<Expense>> getExpenses({String? category, int? jalaliYear, int? jalaliMonth}) async {
    return _guard(() async {
      var query = _client.from(SupabaseTables.expenses).select();
      if (category != null) query = query.eq('category', category);
      if (jalaliYear != null && jalaliMonth != null) {
        final Jalali start = Jalali(jalaliYear, jalaliMonth, 1);
        final Jalali end = jalaliMonth == 12 ? Jalali(jalaliYear + 1, 1, 1) : Jalali(jalaliYear, jalaliMonth + 1, 1);
        final DateTime startGregorian = DateFormatter.toGregorian(start);
        final DateTime endGregorian = DateFormatter.toGregorian(end);
        query = query.gte('expense_date', startGregorian.toIso8601String().split('T').first).lt('expense_date', endGregorian.toIso8601String().split('T').first);
      }
      final List<Map<String, dynamic>> rows = await ListCache.fetch(box: AppConstants.hiveExpensesBox, key: 'all', useCache: category == null && jalaliYear == null && jalaliMonth == null, remote: () async => await query.order('expense_date', ascending: false));
      return rows.map(Expense.fromJson).toList();
    });
  }

  @override
  Future<Expense> createExpense(Map<String, dynamic> data) async {
    return _guard(() async {
      final Map<String, dynamic> row = await _client.from(SupabaseTables.expenses).insert(data).select().single();
      return Expense.fromJson(row);
    });
  }

  @override
  Future<Expense> updateExpense(String id, Map<String, dynamic> data) async {
    return _guard(() async {
      final Map<String, dynamic> row = await _client.from(SupabaseTables.expenses).update(data).eq('id', id).select().single();
      return Expense.fromJson(row);
    });
  }

  @override
  Future<void> voidExpense(String id) async {
    return _guard(() async {
      await _client.from(SupabaseTables.expenses).update({'is_void': true}).eq('id', id);
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
