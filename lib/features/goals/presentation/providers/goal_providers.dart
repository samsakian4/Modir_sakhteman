import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/goal.dart';
import '../../data/datasources/goal_remote_datasource.dart';
import '../../data/repositories/goal_repository_impl.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../domain/usecases/change_goal_status_usecase.dart';
import '../../domain/usecases/create_goal_usecase.dart';
import '../../domain/usecases/get_goals_usecase.dart';
import '../../domain/usecases/update_goal_usecase.dart';

final Provider<GoalRemoteDataSource> goalRemoteDataSourceProvider = Provider<GoalRemoteDataSource>((ref) => GoalRemoteDataSourceImpl(SupabaseService.client));
final Provider<GoalRepository> goalRepositoryProvider = Provider<GoalRepository>((ref) => GoalRepositoryImpl(ref.watch(goalRemoteDataSourceProvider)));
final Provider<GetGoalsUseCase> getGoalsUseCaseProvider = Provider((ref) => GetGoalsUseCase(ref.watch(goalRepositoryProvider)));
final Provider<CreateGoalUseCase> createGoalUseCaseProvider = Provider((ref) => CreateGoalUseCase(ref.watch(goalRepositoryProvider)));
final Provider<UpdateGoalUseCase> updateGoalUseCaseProvider = Provider((ref) => UpdateGoalUseCase(ref.watch(goalRepositoryProvider)));
final Provider<ChangeGoalStatusUseCase> changeGoalStatusUseCaseProvider = Provider((ref) => ChangeGoalStatusUseCase(ref.watch(goalRepositoryProvider)));

class GoalListNotifier extends AsyncNotifier<List<Goal>> {
  @override
  Future<List<Goal>> build() => _fetch();

  Future<List<Goal>> _fetch() async {
    final Either<Failure, List<Goal>> result = await ref.read(getGoalsUseCaseProvider)();
    return result.fold((failure) => throw failure, (list) => list);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}

final AsyncNotifierProvider<GoalListNotifier, List<Goal>> goalListProvider = AsyncNotifierProvider(GoalListNotifier.new);

final FutureProviderFamily<Goal, String> goalDetailProvider = FutureProvider.family<Goal, String>((ref, id) async {
  final List<Goal> goals = await ref.watch(goalListProvider.future);
  return goals.firstWhere((g) => g.id == id, orElse: () => throw const ServerFailure('هدف موردنظر یافت نشد.'));
});
