import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../shared/enums/expense_category.dart';
import '../../../../shared/enums/user_role.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';
import '../../data/services/report_export_service.dart';
import '../../domain/entities/monthly_report.dart';
import '../providers/report_providers.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});
  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  bool _isExporting = false;

  Future<void> _export(Future<void> Function(MonthlyReport) action, MonthlyReport report) async {
    setState(() => _isExporting = true);
    try {
      await action(report);
    } catch (e) {
      if (mounted) AppSnackbar.error(context, 'خروجی گرفتن با خطا مواجه شد. دوباره تلاش کنید.');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ({int year, int month}) period = ref.watch(selectedReportPeriodProvider);
    final AsyncValue<MonthlyReport> reportAsync = ref.watch(monthlyReportProvider);
    final AuthState authState = ref.watch(authProvider);
    final bool isAdmin = authState is AuthAuthenticated && authState.role == UserRole.admin;
    final String periodLabel = '${DateFormatter.jalaliMonthName(period.month)} ${CurrencyFormatter.toPersianDigits(period.year.toString())}';

    return Scaffold(
      appBar: AppBar(title: const Text('گزارش مالی')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(monthlyReportProvider),
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.spaceM),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.chevron_right_rounded), onPressed: () => ref.read(selectedReportPeriodProvider.notifier).goToPreviousMonth()),
                Text(periodLabel, style: Theme.of(context).textTheme.titleMedium),
                IconButton(icon: const Icon(Icons.chevron_left_rounded), onPressed: () => ref.read(selectedReportPeriodProvider.notifier).goToNextMonth()),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceS),
            reportAsync.when(
              loading: () => const SkeletonList(count: 4),
              error: (error, _) => ErrorView(failure: error is Failure ? error : UnknownFailure(error.toString()), onRetry: () => ref.invalidate(monthlyReportProvider)),
              data: (report) => _ReportBody(report: report),
            ),
            if (isAdmin)
              reportAsync.whenOrNull(
                data: (report) => Padding(
                  padding: const EdgeInsets.only(top: AppDimensions.spaceL),
                  child: Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isExporting ? null : () => _export(ReportExportService.exportPdf, report),
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('خروجی PDF'),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceS),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isExporting ? null : () => _export(ReportExportService.exportExcel, report),
                        icon: const Icon(Icons.table_chart_outlined),
                        label: const Text('خروجی اکسل'),
                      ),
                    ),
                  ]),
                ),
              ) ??
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.report});
  final MonthlyReport report;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isNegative = report.netBalance < 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: isNegative ? scheme.errorContainer : scheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceL),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('مانده خالص این ماه', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: isNegative ? scheme.onErrorContainer : scheme.onPrimaryContainer)),
              const SizedBox(height: AppDimensions.spaceS),
              Text(CurrencyFormatter.formatWithUnit(report.netBalance), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: isNegative ? scheme.onErrorContainer : scheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
            ]),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceM),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppDimensions.spaceS,
          mainAxisSpacing: AppDimensions.spaceS,
          childAspectRatio: 1.5,
          children: [
            _SummaryTile(icon: Icons.arrow_downward_rounded, label: 'مجموع دریافتی', value: CurrencyFormatter.formatWithUnit(report.totalIncome), color: scheme.primary),
            _SummaryTile(icon: Icons.arrow_upward_rounded, label: 'مجموع هزینه‌ها', value: CurrencyFormatter.formatWithUnit(report.totalExpenses), color: scheme.error),
            _SummaryTile(icon: Icons.check_circle_outline, label: 'واحدهای پرداخت‌کرده', value: '${CurrencyFormatter.toPersianDigits(report.paidUnitsCount.toString())} از ${CurrencyFormatter.toPersianDigits(report.totalActiveApartments.toString())}', color: scheme.primary),
            _SummaryTile(icon: Icons.warning_amber_rounded, label: 'واحدهای بدهکار', value: CurrencyFormatter.toPersianDigits(report.unpaidUnitsCount.toString()), color: scheme.error),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceL),
        Text('ریز هزینه‌ها به تفکیک دسته‌بندی', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppDimensions.spaceS),
        if (report.categoryBreakdown.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceM), child: Text('در این ماه هزینه‌ای ثبت نشده است.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)))
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceXS),
              child: Column(children: [for (final CategoryBreakdown item in report.categoryBreakdown) _CategoryRow(item: item, total: report.totalExpenses)]),
            ),
          ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.icon, required this.label, required this.value, required this.color});
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceM),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: AppDimensions.spaceS),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ]),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.item, required this.total});
  final CategoryBreakdown item;
  final double total;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final double ratio = total <= 0 ? 0 : (item.amount / total).clamp(0, 1);
    return ListTile(
      leading: Icon(item.category.icon, color: scheme.error),
      title: Text(item.category.label),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: ClipRRect(borderRadius: BorderRadius.circular(AppDimensions.radiusFull), child: LinearProgressIndicator(value: ratio, minHeight: 6, backgroundColor: scheme.surfaceContainerHighest, valueColor: AlwaysStoppedAnimation<Color>(scheme.error))),
      ),
      trailing: Text(CurrencyFormatter.formatWithUnit(item.amount), style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}
