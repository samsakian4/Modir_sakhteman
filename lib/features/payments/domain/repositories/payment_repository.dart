import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/charge_payment.dart';

abstract class PaymentRepository {
  Future<Either<Failure, List<ChargePayment>>> getPayments({String? apartmentId, int? jalaliYear, int? jalaliMonth});
  Future<Either<Failure, ChargePayment>> createPayment({required String apartmentId, required double amount, required DateTime paymentDate, required int jalaliYear, required int jalaliMonth, String? description});
  Future<Either<Failure, ChargePayment>> updatePayment({required String id, required double amount, required DateTime paymentDate, required int jalaliYear, required int jalaliMonth, String? description});
  Future<Either<Failure, void>> voidPayment(String id);
}
