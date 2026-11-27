import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/apartment.dart';
import '../repositories/apartment_repository.dart';

class GetApartmentByIdUseCase {
  const GetApartmentByIdUseCase(this._repository);
  final ApartmentRepository _repository;
  Future<Either<Failure, Apartment>> call(String id) => _repository.getApartmentById(id);
}
