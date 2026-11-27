import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/apartment.dart';
import '../repositories/apartment_repository.dart';

class UpdateApartmentUseCase {
  const UpdateApartmentUseCase(this._repository);
  final ApartmentRepository _repository;
  Future<Either<Failure, Apartment>> call({required String id, required String unitNumber, required String ownerName, String? phone, int? residentsCount, String? notes}) {
    return _repository.updateApartment(id: id, unitNumber: unitNumber, ownerName: ownerName, phone: phone, residentsCount: residentsCount, notes: notes);
  }
}
