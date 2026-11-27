import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/goal.dart';
import '../repositories/goal_repository.dart';

class CreateGoalUseCase {
  const CreateGoalUseCase(this._repository);
  final GoalRepository _repository;
  Future<Either<Failure, Goal>> call({required String title, String? description, required double targetAmount, double currentAmount = 0, DateTime? startDate, DateTime? endDate}) {
    return _repository.createGoal(title: title, description: description, targetAmount: targetAmount, currentAmount: currentAmount, startDate: startDate, endDate: endDate);
  }
}
