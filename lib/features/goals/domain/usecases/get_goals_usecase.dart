import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/goal.dart';
import '../repositories/goal_repository.dart';

class GetGoalsUseCase {
  const GetGoalsUseCase(this._repository);
  final GoalRepository _repository;
  Future<Either<Failure, List<Goal>>> call() => _repository.getGoals();
}
