import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../shared/models/charge_payment.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';
import '../../../payments/presentation/providers/payment_providers.dart';
import '../../domain/entities/apartment.dart';
import '../providers/apartment_providers.dart';

class ApartmentDetailPage extends ConsumerWidget {
  const ApartmentDetailPage({super.key, required this.apartmentId});
  final String apartmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Apartment> apartmentAsync = ref.watch(apartmentDetailProvider(apartmentId));
    final AuthState authState = ref.watch(authProvider);
    final bool isAdmin = authState is AuthAuthenticated && authState.role.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('جزئیات واحد'),
        actions: [if (isAdmin) IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => context.push(AppRoutes.apartmentEditPath(apartmentId)))],
      ),
      body: apartmentAsync.when(
        loading: () => const SkeletonList(count: 4),
        error: (error, _) => ErrorView(failure: error is Failure ? error : UnknownFailure(error.toString()), onRetry: () => ref.invalidate(apartmentDetailProvider(apartmentId))),
        data: (apartment) => _ApartmentDetailBody(apartment: apartment, isAdmin: isAdmin),
      ),
    );
  }
}

class _ApartmentDetailBody extends ConsumerWidget {
  const _ApartmentDetailBody({required this.apartment, required this.isAdmin});
  final Apartment apartment;
  final bool isAdmin;

  Future<void> _confirmVoidPayment(BuildContext context, WidgetRef ref, ChargePayment payment) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('باطل کردن پرداخت'),
        content: Text('پرداخت ${CurrencyFormatter.formatWithUnit(payment.amount)} باطل شود؟'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('باطل کن')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final result = await ref.read(voidPaymentUseCaseProvider)(payment.id);
    if (!context.mounted) return;
    result.fold((failure) => AppSnackbar.error(context, failure.message), (_) {
      ref.read(apartmentListProvider.notifier).refresh();
      ref.invalidate(apartmentPaymentHistoryProvider(apartment.id));
      ref.invalidate(apartmentDebtProvider(apartment.id));
      AppSnackbar.success(context, 'پرداخت باطل شد.');
    });
  }

  Future<void> _confirmDeactivate(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('غیرفعال کردن واحد'),
        content: Text('واحد ${apartment.unitNumber} غیرفعال شود؟'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('غیرفعال کن')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final result = await ref.read(deactivateApartmentUseCaseProvider)(apartment.id);
    if (!context.mounted) return;
    result.fold((failure) => AppSnackbar.error(context, failure.message), (_) {
      ref.read(apartmentListProvider.notifier).refresh();
      AppSnackbar.success(context, 'واحد غیرفعال شد.');
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final AsyncValue<double> debtAsync = ref.watch(apartmentDebtProvider(apartment.id));
    final AsyncValue<List<ChargePayment>> historyAsync = ref.watch(apartmentPaymentHistoryProvider(apartment.id));

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spaceM),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('واحد ${CurrencyFormatter.toPersianDigits(apartment.unitNumber)}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppDimensions.spaceS),
                _InfoRow(icon: Icons.person_outline, label: apartment.ownerName),
                if (apartment.phone != null && apartment.phone!.isNotEmpty) _InfoRow(icon: Icons.phone_outlined, label: CurrencyFormatter.toPersianDigits(apartment.phone!)),
                if (apartment.residentsCount != null) _InfoRow(icon: Icons.people_outline, label: '${CurrencyFormatter.toPersianDigits(apartment.residentsCount.toString())} نفر ساکن'),
                if (!apartment.isActive)
                  Padding(padding: const EdgeInsets.only(top: AppDimensions.spaceS), child: Chip(label: const Text('غیرفعال'), backgroundColor: scheme.errorContainer)),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceM),
        debtAsync.when(
          loading: () => const SkeletonBox(height: 64),
          error: (_, __) => const SizedBox.shrink(),
          data: (debt) => Card(
            color: debt > 0 ? scheme.errorContainer : scheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceM),
              child: Row(children: [
                Icon(debt > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline, color: debt > 0 ? scheme.onErrorContainer : scheme.onPrimaryContainer),
                const SizedBox(width: AppDimensions.spaceS),
                Text(debt > 0 ? 'بدهی: ${CurrencyFormatter.formatWithUnit(debt)}' : 'بدون بدهی', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: debt > 0 ? scheme.onErrorContainer : scheme.onPrimaryContainer)),
              ]),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceL),
        Text('سوابق پرداخت', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppDimensions.spaceS),
        historyAsync.when(
          loading: () => const SkeletonList(count: 3),
          error: (error, _) => ErrorView(failure: error is Failure ? error : UnknownFailure(error.toString())),
          data: (payments) {
            if (payments.isEmpty) return const EmptyState(icon: Icons.receipt_long_outlined, message: 'هنوز پرداختی برای این واحد ثبت نشده است.');
            return Column(children: [
              for (final ChargePayment payment in payments)
                Card(
                  margin: const EdgeInsets.only(bottom: AppDimensions.spaceS),
                  child: ListTile(
                    leading: Icon(Icons.payments_outlined, color: payment.isVoid ? scheme.onSurfaceVariant : scheme.primary),
                    title: Text(CurrencyFormatter.formatWithUnit(payment.amount), style: payment.isVoid ? const TextStyle(decoration: TextDecoration.lineThrough) : null),
                    subtitle: Text('${DateFormatter.jalaliMonthName(payment.month)} ${CurrencyFormatter.toPersianDigits(payment.year.toString())} · ${DateFormatter.formatShort(payment.paymentDate)}'),
                    trailing: payment.isVoid
                        ? Chip(label: const Text('باطل‌شده'), backgroundColor: scheme.errorContainer)
                        : isAdmin
                        ? PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                context.push(AppRoutes.paymentEdit, extra: payment);
                              } else if (value == 'void') {
                                _confirmVoidPayment(context, ref, payment);
                              }
                            },
                            itemBuilder: (context) => const [PopupMenuItem(value: 'edit', child: Text('ویرایش')), PopupMenuItem(value: 'void', child: Text('باطل کردن'))],
                          )
                        : null,
                  ),
                ),
            ]);
          },
        ),
        const SizedBox(height: AppDimensions.spaceL),
        if (isAdmin)
          FilledButton.icon(
            onPressed: () => context.push(AppRoutes.paymentNewPath(apartment.id)),
            icon: const Icon(Icons.add_card_outlined),
            label: const Text('ثبت پرداخت برای این واحد'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(AppDimensions.minTouchTarget)),
          ),
        const SizedBox(height: AppDimensions.spaceS),
        if (isAdmin && apartment.isActive)
          OutlinedButton.icon(
            onPressed: () => _confirmDeactivate(context, ref),
            icon: Icon(Icons.block_outlined, color: scheme.error),
            label: Text('غیرفعال کردن واحد', style: TextStyle(color: scheme.error)),
            style: OutlinedButton.styleFrom(side: BorderSide(color: scheme.error), minimumSize: const Size.fromHeight(AppDimensions.minTouchTarget)),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.spaceXS),
      child: Row(children: [Icon(icon, size: 18, color: scheme.onSurfaceVariant), const SizedBox(width: AppDimensions.spaceS), Text(label, style: Theme.of(context).textTheme.bodyMedium)]),
    );
  }
}
