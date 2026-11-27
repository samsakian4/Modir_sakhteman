import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/apartment_repository.dart';

class DeactivateApartmentUseCase {
  const DeactivateApartmentUseCase(this._repository);
  final ApartmentRepository _repository;
  Future<Either<Failure, void>> call(String id) => _repository.deactivateApartment(id);
}
