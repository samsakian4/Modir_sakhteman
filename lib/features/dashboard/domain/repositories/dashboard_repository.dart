import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/activity_item.dart';
import '../entities/dashboard_summary.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardSummary>> getSummary();
  Future<Either<Failure, List<ActivityItem>>> getRecentActivity({int limit = 5});
}
