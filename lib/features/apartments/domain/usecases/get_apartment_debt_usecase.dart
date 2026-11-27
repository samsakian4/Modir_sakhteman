import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/apartment_repository.dart';

class GetApartmentDebtUseCase {
  const GetApartmentDebtUseCase(this._repository);
  final ApartmentRepository _repository;
  Future<Either<Failure, double>> call(String apartmentId) => _repository.getDebt(apartmentId);
}
