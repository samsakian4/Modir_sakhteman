import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/apartment_summary.dart';
import '../repositories/apartment_repository.dart';

class GetApartmentSummariesUseCase {
  const GetApartmentSummariesUseCase(this._repository);
  final ApartmentRepository _repository;
  Future<Either<Failure, List<ApartmentSummary>>> call() => _repository.getApartmentSummaries();
}
