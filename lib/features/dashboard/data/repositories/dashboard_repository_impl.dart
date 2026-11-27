import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/activity_item.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._remote);
  final DashboardRemoteDataSource _remote;

  @override
  Future<Either<Failure, DashboardSummary>> getSummary() async {
    try {
      return Right(await _remote.getSummary());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<ActivityItem>>> getRecentActivity({int limit = 5}) async {
    try {
      return Right(await _remote.getRecentActivity(limit: limit));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
