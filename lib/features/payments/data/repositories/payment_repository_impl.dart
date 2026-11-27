import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/charge_payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  const PaymentRepositoryImpl(this._remote);
  final PaymentRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<ChargePayment>>> getPayments({String? apartmentId, int? jalaliYear, int? jalaliMonth}) async {
    try {
      return Right(await _remote.getPayments(apartmentId: apartmentId, jalaliYear: jalaliYear, jalaliMonth: jalaliMonth));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, ChargePayment>> createPayment({required String apartmentId, required double amount, required DateTime paymentDate, required int jalaliYear, required int jalaliMonth, String? description}) async {
    try {
      final ChargePayment result = await _remote.createPayment({
        'apartment_id': apartmentId, 'amount': amount, 'payment_date': paymentDate.toIso8601String().split('T').first, 'year': jalaliYear, 'month': jalaliMonth, 'description': description,
      });
      return Right(result);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, ChargePayment>> updatePayment({required String id, required double amount, required DateTime paymentDate, required int jalaliYear, required int jalaliMonth, String? description}) async {
    try {
      final ChargePayment result = await _remote.updatePayment(id, {
        'amount': amount, 'payment_date': paymentDate.toIso8601String().split('T').first, 'year': jalaliYear, 'month': jalaliMonth, 'description': description,
      });
      return Right(result);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> voidPayment(String id) async {
    try {
      await _remote.voidPayment(id);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
