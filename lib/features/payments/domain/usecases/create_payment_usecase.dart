import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/charge_payment.dart';
import '../repositories/payment_repository.dart';

class CreatePaymentUseCase {
  const CreatePaymentUseCase(this._repository);
  final PaymentRepository _repository;
  Future<Either<Failure, ChargePayment>> call({required String apartmentId, required double amount, required DateTime paymentDate, required int jalaliYear, required int jalaliMonth, String? description}) {
    return _repository.createPayment(apartmentId: apartmentId, amount: amount, paymentDate: paymentDate, jalaliYear: jalaliYear, jalaliMonth: jalaliMonth, description: description);
  }
}
