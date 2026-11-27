import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/charge_payment.dart';
import '../repositories/payment_repository.dart';

class GetPaymentsUseCase {
  const GetPaymentsUseCase(this._repository);
  final PaymentRepository _repository;
  Future<Either<Failure, List<ChargePayment>>> call({String? apartmentId, int? jalaliYear, int? jalaliMonth}) {
    return _repository.getPayments(apartmentId: apartmentId, jalaliYear: jalaliYear, jalaliMonth: jalaliMonth);
  }
}
