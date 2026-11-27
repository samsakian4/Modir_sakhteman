import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/activity_item.dart';
import '../models/dashboard_summary_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardSummaryModel> getSummary();
  Future<List<ActivityItem>> getRecentActivity({int limit = 5});
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  DashboardRemoteDataSourceImpl(this._client);
  final SupabaseClient _client;

  @override
  Future<DashboardSummaryModel> getSummary() async {
    return _guard(() async {
      final ({int year, int month}) period = DateFormatter.currentJalaliYearMonth();
      final dynamic result = await _client.rpc(SupabaseRpc.getDashboardSummary, params: {'p_jalali_year': period.year, 'p_jalali_month': period.month});
      final Map<String, dynamic> row = (result as List).first as Map<String, dynamic>;
      return DashboardSummaryModel.fromJson(row);
    });
  }

  @override
  Future<List<ActivityItem>> getRecentActivity({int limit = 5}) async {
    return _guard(() async {
      final List<Map<String, dynamic>> paymentRows = await _client.from(SupabaseTables.chargePayments).select().eq('is_void', false).order('created_at', ascending: false).limit(limit);
      final List<Map<String, dynamic>> expenseRows = await _client.from(SupabaseTables.expenses).select().eq('is_void', false).order('created_at', ascending: false).limit(limit);

      final List<ActivityItem> items = [
        for (final Map<String, dynamic> row in paymentRows) ActivityItem(type: ActivityType.payment, title: 'ثبت پرداخت شارژ', amount: (row['amount'] as num).toDouble(), occurredAt: DateTime.parse(row['created_at'] as String)),
        for (final Map<String, dynamic> row in expenseRows) ActivityItem(type: ActivityType.expense, title: row['title'] as String, amount: (row['amount'] as num).toDouble(), occurredAt: DateTime.parse(row['created_at'] as String)),
      ];
      items.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
      return items.take(limit).toList();
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
