import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/enums/goal_status.dart';
import '../../../../shared/models/goal.dart';

abstract class GoalRepository {
  Future<Either<Failure, List<Goal>>> getGoals();
  Future<Either<Failure, Goal>> createGoal({required String title, String? description, required double targetAmount, double currentAmount, DateTime? startDate, DateTime? endDate});
  Future<Either<Failure, Goal>> updateGoal({required String id, required String title, String? description, required double targetAmount, required double currentAmount, DateTime? startDate, DateTime? endDate});
  Future<Either<Failure, Goal>> changeStatus({required String id, required GoalStatus status, String? finalNotes});
}
