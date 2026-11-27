import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/enums/expense_category.dart';
import '../../../../shared/models/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_remote_datasource.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  const ExpenseRepositoryImpl(this._remote);
  final ExpenseRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Expense>>> getExpenses({ExpenseCategory? category, int? jalaliYear, int? jalaliMonth}) async {
    try {
      return Right(await _remote.getExpenses(category: category?.dbValue, jalaliYear: jalaliYear, jalaliMonth: jalaliMonth));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Expense>> createExpense({required String title, required ExpenseCategory category, required double amount, required DateTime expenseDate, String? description}) async {
    try {
      final Expense result = await _remote.createExpense({'title': title, 'category': category.dbValue, 'amount': amount, 'expense_date': expenseDate.toIso8601String().split('T').first, 'description': description});
      return Right(result);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Expense>> updateExpense({required String id, required String title, required ExpenseCategory category, required double amount, required DateTime expenseDate, String? description}) async {
    try {
      final Expense result = await _remote.updateExpense(id, {'title': title, 'category': category.dbValue, 'amount': amount, 'expense_date': expenseDate.toIso8601String().split('T').first, 'description': description});
      return Right(result);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> voidExpense(String id) async {
    try {
      await _remote.voidExpense(id);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
