import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/enums/expense_category.dart';
import '../../../../shared/models/expense.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, List<Expense>>> getExpenses({ExpenseCategory? category, int? jalaliYear, int? jalaliMonth});
  Future<Either<Failure, Expense>> createExpense({required String title, required ExpenseCategory category, required double amount, required DateTime expenseDate, String? description});
  Future<Either<Failure, Expense>> updateExpense({required String id, required String title, required ExpenseCategory category, required double amount, required DateTime expenseDate, String? description});
  Future<Either<Failure, void>> voidExpense(String id);
}
