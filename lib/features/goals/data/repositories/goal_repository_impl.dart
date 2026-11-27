import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/enums/goal_status.dart';
import '../../../../shared/models/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_remote_datasource.dart';

class GoalRepositoryImpl implements GoalRepository {
  const GoalRepositoryImpl(this._remote);
  final GoalRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Goal>>> getGoals() async {
    try {
      return Right(await _remote.getGoals());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Goal>> createGoal({required String title, String? description, required double targetAmount, double currentAmount = 0, DateTime? startDate, DateTime? endDate}) async {
    try {
      final Goal result = await _remote.createGoal({
        'title': title,
        'description': description,
        'target_amount': targetAmount,
        'current_amount': currentAmount,
        'status': GoalStatus.collecting.dbValue,
        'start_date': startDate?.toIso8601String().split('T').first,
        'end_date': endDate?.toIso8601String().split('T').first,
      });
      return Right(result);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Goal>> updateGoal({required String id, required String title, String? description, required double targetAmount, required double currentAmount, DateTime? startDate, DateTime? endDate}) async {
    try {
      final Goal result = await _remote.updateGoal(id, {
        'title': title,
        'description': description,
        'target_amount': targetAmount,
        'current_amount': currentAmount,
        'start_date': startDate?.toIso8601String().split('T').first,
        'end_date': endDate?.toIso8601String().split('T').first,
      });
      return Right(result);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Goal>> changeStatus({required String id, required GoalStatus status, String? finalNotes}) async {
    try {
      final Map<String, dynamic> data = {'status': status.dbValue};
      if (finalNotes != null) data['final_notes'] = finalNotes;
      final Goal result = await _remote.changeStatus(id, data);
      return Right(result);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
