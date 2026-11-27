import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/expense_repository.dart';

class VoidExpenseUseCase {
  const VoidExpenseUseCase(this._repository);
  final ExpenseRepository _repository;
  Future<Either<Failure, void>> call(String id) => _repository.voidExpense(id);
}
