import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/enums/expense_category.dart';
import '../../../../shared/models/expense.dart';
import '../repositories/expense_repository.dart';

class CreateExpenseUseCase {
  const CreateExpenseUseCase(this._repository);
  final ExpenseRepository _repository;
  Future<Either<Failure, Expense>> call({required String title, required ExpenseCategory category, required double amount, required DateTime expenseDate, String? description}) {
    return _repository.createExpense(title: title, category: category, amount: amount, expenseDate: expenseDate, description: description);
  }
}
