import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/charge_payment.dart';
import '../../domain/entities/apartment.dart';
import '../../domain/entities/apartment_summary.dart';
import '../../domain/repositories/apartment_repository.dart';
import '../datasources/apartment_remote_datasource.dart';
import '../models/apartment_model.dart';

class ApartmentRepositoryImpl implements ApartmentRepository {
  const ApartmentRepositoryImpl(this._remote);
  final ApartmentRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<ApartmentSummary>>> getApartmentSummaries() async {
    try {
      return Right(await _remote.getApartmentSummaries());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Apartment>> getApartmentById(String id) async {
    try {
      return Right(await _remote.getApartmentById(id));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<ChargePayment>>> getPaymentHistory(String apartmentId) async {
    try {
      final rows = await _remote.getPaymentHistory(apartmentId);
      return Right(rows.map(ChargePayment.fromJson).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, double>> getDebt(String apartmentId) async {
    try {
      return Right(await _remote.getDebt(apartmentId));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Apartment>> createApartment({required String unitNumber, required String ownerName, String? phone, int? residentsCount, String? notes}) async {
    try {
      final ApartmentModel result = await _remote.createApartment({'unit_number': unitNumber, 'owner_name': ownerName, 'phone': phone, 'residents_count': residentsCount, 'notes': notes});
      return Right(result);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Apartment>> updateApartment({required String id, required String unitNumber, required String ownerName, String? phone, int? residentsCount, String? notes}) async {
    try {
      final ApartmentModel result = await _remote.updateApartment(id, {'unit_number': unitNumber, 'owner_name': ownerName, 'phone': phone, 'residents_count': residentsCount, 'notes': notes});
      return Right(result);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deactivateApartment(String id) async {
    try {
      await _remote.deactivateApartment(id);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
