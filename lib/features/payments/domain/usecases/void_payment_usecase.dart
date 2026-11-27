import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/payment_repository.dart';

class VoidPaymentUseCase {
  const VoidPaymentUseCase(this._repository);
  final PaymentRepository _repository;
  Future<Either<Failure, void>> call(String id) => _repository.voidPayment(id);
}
