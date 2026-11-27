import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../shared/enums/goal_status.dart';
import '../../../../shared/models/goal.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';
import '../providers/goal_providers.dart';

class GoalDetailPage extends ConsumerWidget {
  const GoalDetailPage({super.key, required this.goalId});
  final String goalId;

  Future<void> _changeStatus(BuildContext context, WidgetRef ref, Goal goal, GoalStatus newStatus) async {
    String? finalNotes;
    if (newStatus == GoalStatus.completed) {
      final TextEditingController controller = TextEditingController();
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تکمیل هدف'),
          content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'یادداشت پایانی (اختیاری)'), maxLines: 3),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('انصراف')), FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('ثبت به‌عنوان انجام‌شده'))],
        ),
      );
      if (confirmed != true) return;
      finalNotes = controller.text.trim().isEmpty ? null : controller.text.trim();
    }
    final result = await ref.read(changeGoalStatusUseCaseProvider)(id: goal.id, status: newStatus, finalNotes: finalNotes);
    if (!context.mounted) return;
    result.fold((failure) => AppSnackbar.error(context, failure.message), (_) {
      ref.read(goalListProvider.notifier).refresh();
      AppSnackbar.success(context, 'وضعیت هدف به‌روزرسانی شد.');
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Goal> goalAsync = ref.watch(goalDetailProvider(goalId));
    final AuthState authState = ref.watch(authProvider);
    final bool isAdmin = authState is AuthAuthenticated && authState.role.isAdmin;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('جزئیات هدف'),
        actions: [
          if (isAdmin)
            goalAsync.whenOrNull(data: (goal) => IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => context.push(AppRoutes.goalEdit, extra: goal))) ?? const SizedBox.shrink(),
        ],
      ),
      body: goalAsync.when(
        loading: () => const SkeletonList(count: 4),
        error: (error, _) => ErrorView(failure: error is Failure ? error : UnknownFailure(error.toString()), onRetry: () => ref.invalidate(goalDetailProvider(goalId))),
        data: (goal) {
          final double progress = goal.progressPercent / 100;
          return ListView(
            padding: const EdgeInsets.all(AppDimensions.spaceM),
            children: [
              Row(children: [
                Expanded(child: Text(goal.title, style: Theme.of(context).textTheme.headlineSmall)),
                Chip(label: Text(goal.status.label, style: TextStyle(color: goal.status.color, fontWeight: FontWeight.w600)), backgroundColor: goal.status.color.withValues(alpha: 0.12), side: BorderSide.none),
              ]),
              if (goal.description != null && goal.description!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spaceS),
                Text(goal.description!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
              ],
              const SizedBox(height: AppDimensions.spaceL),
              ClipRRect(borderRadius: BorderRadius.circular(AppDimensions.radiusFull), child: LinearProgressIndicator(value: progress, minHeight: 12, backgroundColor: scheme.surfaceContainerHighest, valueColor: AlwaysStoppedAnimation<Color>(goal.status.color))),
              const SizedBox(height: AppDimensions.spaceS),
              Text('${CurrencyFormatter.toPersianDigits(goal.progressPercent.toStringAsFixed(0))}٪ پیشرفت', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppDimensions.spaceM),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spaceM),
                  child: Column(children: [
                    _InfoRow(label: 'مبلغ موردنیاز', value: CurrencyFormatter.formatWithUnit(goal.targetAmount)),
                    const Divider(),
                    _InfoRow(label: 'مبلغ تأمین‌شده', value: CurrencyFormatter.formatWithUnit(goal.currentAmount)),
                    const Divider(),
                    _InfoRow(label: 'مانده تا هدف', value: CurrencyFormatter.formatWithUnit((goal.targetAmount - goal.currentAmount).clamp(0, goal.targetAmount))),
                    if (goal.startDate != null) ...[const Divider(), _InfoRow(label: 'تاریخ شروع', value: DateFormatter.formatFull(goal.startDate!))],
                    if (goal.endDate != null) ...[const Divider(), _InfoRow(label: 'مهلت پایان', value: DateFormatter.formatFull(goal.endDate!))],
                  ]),
                ),
              ),
              if (goal.finalNotes != null && goal.finalNotes!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spaceM),
                Card(
                  color: scheme.primaryContainer.withValues(alpha: 0.3),
                  child: Padding(padding: const EdgeInsets.all(AppDimensions.spaceM), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('یادداشت پایانی', style: Theme.of(context).textTheme.labelMedium), const SizedBox(height: AppDimensions.spaceXXS), Text(goal.finalNotes!)])),
                ),
              ],
              if (isAdmin && goal.status != GoalStatus.completed) ...[
                const SizedBox(height: AppDimensions.spaceL),
                Text('تغییر وضعیت', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppDimensions.spaceS),
                Wrap(
                  spacing: AppDimensions.spaceS,
                  runSpacing: AppDimensions.spaceXS,
                  children: [for (final GoalStatus status in GoalStatus.values) if (status != goal.status) OutlinedButton(onPressed: () => _changeStatus(context, ref, goal, status), child: Text(status.label))],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
