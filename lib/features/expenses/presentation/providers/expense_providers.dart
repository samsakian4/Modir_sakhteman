import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/expense.dart';
import '../../data/datasources/expense_remote_datasource.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/usecases/create_expense_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import '../../domain/usecases/update_expense_usecase.dart';
import '../../domain/usecases/void_expense_usecase.dart';

final Provider<ExpenseRemoteDataSource> expenseRemoteDataSourceProvider = Provider<ExpenseRemoteDataSource>((ref) => ExpenseRemoteDataSourceImpl(SupabaseService.client));
final Provider<ExpenseRepository> expenseRepositoryProvider = Provider<ExpenseRepository>((ref) => ExpenseRepositoryImpl(ref.watch(expenseRemoteDataSourceProvider)));
final Provider<GetExpensesUseCase> getExpensesUseCaseProvider = Provider((ref) => GetExpensesUseCase(ref.watch(expenseRepositoryProvider)));
final Provider<CreateExpenseUseCase> createExpenseUseCaseProvider = Provider((ref) => CreateExpenseUseCase(ref.watch(expenseRepositoryProvider)));
final Provider<UpdateExpenseUseCase> updateExpenseUseCaseProvider = Provider((ref) => UpdateExpenseUseCase(ref.watch(expenseRepositoryProvider)));
final Provider<VoidExpenseUseCase> voidExpenseUseCaseProvider = Provider((ref) => VoidExpenseUseCase(ref.watch(expenseRepositoryProvider)));

class ExpenseListNotifier extends AsyncNotifier<List<Expense>> {
  @override
  Future<List<Expense>> build() => _fetch();

  Future<List<Expense>> _fetch() async {
    final Either<Failure, List<Expense>> result = await ref.read(getExpensesUseCaseProvider)();
    return result.fold((failure) => throw failure, (list) => list);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}

final AsyncNotifierProvider<ExpenseListNotifier, List<Expense>> expenseListProvider = AsyncNotifierProvider(ExpenseListNotifier.new);
