import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../models/apartment_model.dart';
import '../models/apartment_summary_model.dart';

abstract class ApartmentRemoteDataSource {
  Future<List<ApartmentSummaryModel>> getApartmentSummaries();
  Future<ApartmentModel> getApartmentById(String id);
  Future<List<Map<String, dynamic>>> getPaymentHistory(String apartmentId);
  Future<double> getDebt(String apartmentId);
  Future<ApartmentModel> createApartment(Map<String, dynamic> data);
  Future<ApartmentModel> updateApartment(String id, Map<String, dynamic> data);
  Future<void> deactivateApartment(String id);
}

class ApartmentRemoteDataSourceImpl implements ApartmentRemoteDataSource {
  ApartmentRemoteDataSourceImpl(this._client);
  final SupabaseClient _client;

  @override
  Future<List<ApartmentSummaryModel>> getApartmentSummaries() async {
    return _guard(() async {
      final ({int year, int month}) period = DateFormatter.currentJalaliYearMonth();
      final List<dynamic> rows = await _client.rpc(SupabaseRpc.getApartmentsWithStatus, params: {'p_jalali_year': period.year, 'p_jalali_month': period.month});
      return rows.cast<Map<String, dynamic>>().map(ApartmentSummaryModel.fromJson).toList();
    });
  }

  @override
  Future<ApartmentModel> getApartmentById(String id) async {
    return _guard(() async {
      final Map<String, dynamic>? row = await _client.from(SupabaseTables.apartments).select().eq('id', id).maybeSingle();
      if (row == null) throw const ServerException('واحد موردنظر یافت نشد.');
      return ApartmentModel.fromJson(row);
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentHistory(String apartmentId) async {
    return _guard(() async {
      final List<dynamic> rows = await _client.rpc(SupabaseRpc.getApartmentPaymentHistory, params: {'p_apartment_id': apartmentId});
      return rows.cast<Map<String, dynamic>>();
    });
  }

  @override
  Future<double> getDebt(String apartmentId) async {
    return _guard(() async {
      final ({int year, int month}) period = DateFormatter.currentJalaliYearMonth();
      final dynamic result = await _client.rpc(SupabaseRpc.getApartmentDebt, params: {'p_apartment_id': apartmentId, 'p_as_of_jalali_year': period.year, 'p_as_of_jalali_month': period.month});
      return (result as num).toDouble();
    });
  }

  @override
  Future<ApartmentModel> createApartment(Map<String, dynamic> data) async {
    return _guard(() async {
      final Map<String, dynamic> row = await _client.from(SupabaseTables.apartments).insert(data).select().single();
      return ApartmentModel.fromJson(row);
    });
  }

  @override
  Future<ApartmentModel> updateApartment(String id, Map<String, dynamic> data) async {
    return _guard(() async {
      final Map<String, dynamic> row = await _client.from(SupabaseTables.apartments).update(data).eq('id', id).select().single();
      return ApartmentModel.fromJson(row);
    });
  }

  @override
  Future<void> deactivateApartment(String id) async {
    return _guard(() async {
      await _client.from(SupabaseTables.apartments).update({'is_active': false}).eq('id', id);
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
