import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/list_cache.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/goal.dart';

abstract class GoalRemoteDataSource {
  Future<List<Goal>> getGoals();
  Future<Goal> createGoal(Map<String, dynamic> data);
  Future<Goal> updateGoal(String id, Map<String, dynamic> data);
  Future<Goal> changeStatus(String id, Map<String, dynamic> data);
}

class GoalRemoteDataSourceImpl implements GoalRemoteDataSource {
  GoalRemoteDataSourceImpl(this._client);
  final SupabaseClient _client;

  @override
  Future<List<Goal>> getGoals() async {
    return _guard(() async {
      final List<Map<String, dynamic>> rows = await ListCache.fetch(box: AppConstants.hiveGoalsBox, key: 'all', remote: () async => await _client.from(SupabaseTables.goals).select().order('created_at', ascending: false));
      return rows.map(Goal.fromJson).toList();
    });
  }

  @override
  Future<Goal> createGoal(Map<String, dynamic> data) async {
    return _guard(() async {
      final Map<String, dynamic> row = await _client.from(SupabaseTables.goals).insert(data).select().single();
      return Goal.fromJson(row);
    });
  }

  @override
  Future<Goal> updateGoal(String id, Map<String, dynamic> data) async {
    return _guard(() async {
      final Map<String, dynamic> row = await _client.from(SupabaseTables.goals).update(data).eq('id', id).select().single();
      return Goal.fromJson(row);
    });
  }

  @override
  Future<Goal> changeStatus(String id, Map<String, dynamic> data) async {
    return _guard(() async {
      final Map<String, dynamic> row = await _client.from(SupabaseTables.goals).update(data).eq('id', id).select().single();
      return Goal.fromJson(row);
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
