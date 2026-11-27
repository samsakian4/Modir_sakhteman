import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../domain/entities/activity_item.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/balance_card.dart';
import '../widgets/recent_activity_tile.dart';
import '../widgets/stat_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DashboardSummary> summaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('داشبورد'), actions: [IconButton(icon: const Icon(Icons.logout_rounded), tooltip: 'خروج', onPressed: () => ref.read(authProvider.notifier).logout())]),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardSummaryProvider);
          ref.invalidate(recentActivityProvider);
        },
        child: summaryAsync.when(
          loading: () => const SkeletonList(count: 5),
          error: (error, _) => ErrorView(failure: error is Failure ? error : UnknownFailure(error.toString()), onRetry: () => ref.invalidate(dashboardSummaryProvider)),
          data: (summary) => _DashboardBody(summary: summary),
        ),
      ),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.summary});
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final AsyncValue<List<ActivityItem>> activityAsync = ref.watch(recentActivityProvider);

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spaceM),
      children: [
        BalanceCard(balance: summary.currentBalance),
        const SizedBox(height: AppDimensions.spaceM),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppDimensions.spaceS,
          mainAxisSpacing: AppDimensions.spaceS,
          childAspectRatio: 1.5,
          children: [
            StatCard(icon: Icons.arrow_downward_rounded, label: 'مجموع شارژهای دریافتی', value: CurrencyFormatter.formatWithUnit(summary.totalIncome), color: scheme.primary),
            StatCard(icon: Icons.arrow_upward_rounded, label: 'مجموع هزینه‌ها', value: CurrencyFormatter.formatWithUnit(summary.totalExpenses), color: scheme.error),
            StatCard(icon: Icons.check_circle_outline, label: 'واحدهای پرداخت‌کرده', value: '${CurrencyFormatter.toPersianDigits(summary.paidUnits.toString())} از ${CurrencyFormatter.toPersianDigits(summary.totalActiveApartments.toString())}', color: scheme.primary),
            StatCard(icon: Icons.warning_amber_rounded, label: 'واحدهای بدهکار', value: CurrencyFormatter.toPersianDigits(summary.unpaidUnits.toString()), color: scheme.error),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceM),
        Card(child: ListTile(leading: Icon(Icons.flag_outlined, color: scheme.tertiary), title: const Text('اهداف فعال'), trailing: Text(CurrencyFormatter.toPersianDigits(summary.activeGoals.toString()), style: Theme.of(context).textTheme.titleMedium))),
        const SizedBox(height: AppDimensions.spaceL),
        Text('آخرین فعالیت‌ها', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppDimensions.spaceS),
        activityAsync.when(
          loading: () => const SkeletonList(count: 3),
          error: (_, __) => const SizedBox.shrink(),
          data: (items) {
            if (items.isEmpty) return Padding(padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceM), child: Text('هنوز فعالیتی ثبت نشده است.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)));
            return Column(children: [for (final ActivityItem item in items) RecentActivityTile(item: item)]);
          },
        ),
      ],
    );
  }
}
