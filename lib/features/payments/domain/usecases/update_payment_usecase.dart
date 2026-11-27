import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/charge_payment.dart';
import '../repositories/payment_repository.dart';

class UpdatePaymentUseCase {
  const UpdatePaymentUseCase(this._repository);
  final PaymentRepository _repository;
  Future<Either<Failure, ChargePayment>> call({required String id, required double amount, required DateTime paymentDate, required int jalaliYear, required int jalaliMonth, String? description}) {
    return _repository.updatePayment(id: id, amount: amount, paymentDate: paymentDate, jalaliYear: jalaliYear, jalaliMonth: jalaliMonth, description: description);
  }
}
