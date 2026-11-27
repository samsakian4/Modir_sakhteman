import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/activity_item.dart';

class RecentActivityTile extends StatelessWidget {
  const RecentActivityTile({super.key, required this.item});
  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isPayment = item.type == ActivityType.payment;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceS),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: isPayment ? scheme.primaryContainer : scheme.errorContainer, child: Icon(isPayment ? Icons.payments_outlined : Icons.receipt_long_outlined, color: isPayment ? scheme.onPrimaryContainer : scheme.onErrorContainer, size: 20)),
        title: Text(item.title),
        subtitle: Text(DateFormatter.relativeFromNow(item.occurredAt)),
        trailing: Text(CurrencyFormatter.formatWithUnit(item.amount), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isPayment ? scheme.primary : scheme.error, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
