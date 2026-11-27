import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/apartment_summary.dart';

class ApartmentListCard extends StatelessWidget {
  const ApartmentListCard({super.key, required this.summary, required this.onTap});
  final ApartmentSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isPaid = summary.isPaidThisMonth;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceS),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceM),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: scheme.primaryContainer,
                child: Text(CurrencyFormatter.toPersianDigits(summary.apartment.unitNumber), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: AppDimensions.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('واحد ${CurrencyFormatter.toPersianDigits(summary.apartment.unitNumber)}', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(summary.apartment.ownerName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.spaceS),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StatusChip(isPaid: isPaid),
                  if (summary.hasDebt) ...[
                    const SizedBox(height: 4),
                    Text(CurrencyFormatter.formatWithUnit(summary.debt), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.error, fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isPaid});
  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color bg = isPaid ? scheme.primaryContainer : scheme.errorContainer;
    final Color fg = isPaid ? scheme.onPrimaryContainer : scheme.onErrorContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
      child: Text(isPaid ? 'پرداخت‌شده' : 'پرداخت‌نشده', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg, fontWeight: FontWeight.w600)),
    );
  }
}
