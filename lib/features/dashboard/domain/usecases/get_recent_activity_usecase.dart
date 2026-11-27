import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/activity_item.dart';
import '../repositories/dashboard_repository.dart';

class GetRecentActivityUseCase {
  const GetRecentActivityUseCase(this._repository);
  final DashboardRepository _repository;
  Future<Either<Failure, List<ActivityItem>>> call({int limit = 5}) => _repository.getRecentActivity(limit: limit);
}
