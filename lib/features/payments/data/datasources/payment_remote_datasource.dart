import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/list_cache.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/charge_payment.dart';

abstract class PaymentRemoteDataSource {
  Future<List<ChargePayment>> getPayments({String? apartmentId, int? jalaliYear, int? jalaliMonth});
  Future<ChargePayment> createPayment(Map<String, dynamic> data);
  Future<ChargePayment> updatePayment(String id, Map<String, dynamic> data);
  Future<void> voidPayment(String id);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  PaymentRemoteDataSourceImpl(this._client);
  final SupabaseClient _client;

  @override
  Future<List<ChargePayment>> getPayments({String? apartmentId, int? jalaliYear, int? jalaliMonth}) async {
    return _guard(() async {
      var query = _client.from(SupabaseTables.chargePayments).select();
      if (apartmentId != null) query = query.eq('apartment_id', apartmentId);
      if (jalaliYear != null) query = query.eq('year', jalaliYear);
      if (jalaliMonth != null) query = query.eq('month', jalaliMonth);
      final List<Map<String, dynamic>> rows = await ListCache.fetch(box: AppConstants.hivePaymentsBox, key: 'all', useCache: apartmentId == null && jalaliYear == null && jalaliMonth == null, remote: () async => await query.order('payment_date', ascending: false));
      return rows.map(ChargePayment.fromJson).toList();
    });
  }

  @override
  Future<ChargePayment> createPayment(Map<String, dynamic> data) async {
    return _guard(() async {
      final Map<String, dynamic> row = await _client.from(SupabaseTables.chargePayments).insert(data).select().single();
      return ChargePayment.fromJson(row);
    });
  }

  @override
  Future<ChargePayment> updatePayment(String id, Map<String, dynamic> data) async {
    return _guard(() async {
      final Map<String, dynamic> row = await _client.from(SupabaseTables.chargePayments).update(data).eq('id', id).select().single();
      return ChargePayment.fromJson(row);
    });
  }

  @override
  Future<void> voidPayment(String id) async {
    return _guard(() async {
      await _client.from(SupabaseTables.chargePayments).update({'is_void': true}).eq('id', id);
    });
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PostgrestException catch (e) {
      if (e.code == '23505') throw const ValidationException('برای این واحد در این ماه قبلاً پرداخت ثبت شده است. ابتدا آن را ویرایش یا باطل کنید.');
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
