import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/goal.dart';
import '../repositories/goal_repository.dart';

class UpdateGoalUseCase {
  const UpdateGoalUseCase(this._repository);
  final GoalRepository _repository;
  Future<Either<Failure, Goal>> call({required String id, required String title, String? description, required double targetAmount, required double currentAmount, DateTime? startDate, DateTime? endDate}) {
    return _repository.updateGoal(id: id, title: title, description: description, targetAmount: targetAmount, currentAmount: currentAmount, startDate: startDate, endDate: endDate);
  }
}
