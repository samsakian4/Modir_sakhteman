import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/charge_payment.dart';
import '../entities/apartment.dart';
import '../entities/apartment_summary.dart';

abstract class ApartmentRepository {
  Future<Either<Failure, List<ApartmentSummary>>> getApartmentSummaries();
  Future<Either<Failure, Apartment>> getApartmentById(String id);
  Future<Either<Failure, List<ChargePayment>>> getPaymentHistory(String apartmentId);
  Future<Either<Failure, double>> getDebt(String apartmentId);
  Future<Either<Failure, Apartment>> createApartment({required String unitNumber, required String ownerName, String? phone, int? residentsCount, String? notes});
  Future<Either<Failure, Apartment>> updateApartment({required String id, required String unitNumber, required String ownerName, String? phone, int? residentsCount, String? notes});
  Future<Either<Failure, void>> deactivateApartment(String id);
}
