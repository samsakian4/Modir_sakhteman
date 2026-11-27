import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/charge_payment.dart';
import '../repositories/apartment_repository.dart';

class GetApartmentPaymentHistoryUseCase {
  const GetApartmentPaymentHistoryUseCase(this._repository);
  final ApartmentRepository _repository;
  Future<Either<Failure, List<ChargePayment>>> call(String apartmentId) => _repository.getPaymentHistory(apartmentId);
}
