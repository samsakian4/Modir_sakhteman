import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardSummaryUseCase {
  const GetDashboardSummaryUseCase(this._repository);
  final DashboardRepository _repository;
  Future<Either<Failure, DashboardSummary>> call() => _repository.getSummary();
}
