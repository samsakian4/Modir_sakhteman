import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../shared/models/goal.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';
import '../providers/goal_providers.dart';
import '../widgets/goal_card.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Goal>> goalsAsync = ref.watch(goalListProvider);
    final AuthState authState = ref.watch(authProvider);
    final bool isAdmin = authState is AuthAuthenticated && authState.role.isAdmin;

    return Scaffold(
      appBar: AppBar(title: const Text('اهداف ساختمان')),
      floatingActionButton: isAdmin ? FloatingActionButton(onPressed: () => context.push(AppRoutes.goalNew), child: const Icon(Icons.add_rounded)) : null,
      body: RefreshIndicator(
        onRefresh: () => ref.read(goalListProvider.notifier).refresh(),
        child: goalsAsync.when(
          loading: () => const SkeletonList(count: 4),
          error: (error, _) => ErrorView(failure: error is Failure ? error : UnknownFailure(error.toString()), onRetry: () => ref.read(goalListProvider.notifier).refresh()),
          data: (goals) {
            if (goals.isEmpty) return const EmptyState(icon: Icons.flag_outlined, message: 'هنوز هیچ هدفی برای ساختمان تعریف نشده است.');
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final Goal goal = goals[index];
                return GoalCard(goal: goal, onTap: () => context.push(AppRoutes.goalDetailPath(goal.id)));
              },
            );
          },
        ),
      ),
    );
  }
}
