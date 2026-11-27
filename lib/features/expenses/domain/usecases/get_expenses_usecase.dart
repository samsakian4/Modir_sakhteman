import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/enums/expense_category.dart';
import '../../../../shared/models/expense.dart';
import '../repositories/expense_repository.dart';

class GetExpensesUseCase {
  const GetExpensesUseCase(this._repository);
  final ExpenseRepository _repository;
  Future<Either<Failure, List<Expense>>> call({ExpenseCategory? category, int? jalaliYear, int? jalaliMonth}) {
    return _repository.getExpenses(category: category, jalaliYear: jalaliYear, jalaliMonth: jalaliMonth);
  }
}
