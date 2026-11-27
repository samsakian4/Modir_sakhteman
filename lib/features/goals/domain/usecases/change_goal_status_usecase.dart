import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/enums/goal_status.dart';
import '../../../../shared/models/goal.dart';
import '../repositories/goal_repository.dart';

class ChangeGoalStatusUseCase {
  const ChangeGoalStatusUseCase(this._repository);
  final GoalRepository _repository;
  Future<Either<Failure, Goal>> call({required String id, required GoalStatus status, String? finalNotes}) {
    return _repository.changeStatus(id: id, status: status, finalNotes: finalNotes);
  }
}
