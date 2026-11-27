import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:supabase_flutter/supabase_flutter.dart' as supa show AuthException;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/app_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AppUserModel> login({required String phone, required String password});
  Future<void> logout();
  Future<AppUserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client);
  final SupabaseClient _client;

  String _emailForPhone(String phone) => '$phone@${AppConstants.authEmailDomain}';

  @override
  Future<AppUserModel> login({required String phone, required String password}) async {
    try {
      final AuthResponse response = await _client.auth.signInWithPassword(email: _emailForPhone(phone), password: password);
      final User? authUser = response.user;
      if (authUser == null) throw const AuthException();
      return await _fetchProfile(authUser.id);
    } on supa.AuthException {
      throw const AuthException();
    } on AppException {
      rethrow;
    } catch (e) {
      throw _classifyUnknownError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw _classifyUnknownError(e);
    }
  }

  @override
  Future<AppUserModel?> getCurrentUser() async {
    final User? authUser = _client.auth.currentUser;
    if (authUser == null) return null;
    try {
      return await _fetchProfile(authUser.id);
    } on ServerException {
      await _client.auth.signOut();
      return null;
    }
  }

  Future<AppUserModel> _fetchProfile(String userId) async {
    try {
      final Map<String, dynamic>? row = await _client.from(SupabaseTables.users).select().eq('id', userId).maybeSingle();
      if (row == null) throw const ServerException('پروفایل کاربر یافت نشد.');
      return AppUserModel.fromJson(row);
    } on AppException {
      rethrow;
    } catch (e) {
      throw _classifyUnknownError(e);
    }
  }

  AppException _classifyUnknownError(Object error) {
    final String text = error.toString().toLowerCase();
    if (text.contains('socket') || text.contains('network') || text.contains('connection') || text.contains('timeout') || text.contains('failed to fetch') || text.contains('clientexception')) return const NetworkException();
    return ServerException(error.toString());
  }
}
