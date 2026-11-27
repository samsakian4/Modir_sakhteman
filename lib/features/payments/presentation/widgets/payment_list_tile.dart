import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/models/charge_payment.dart';

class PaymentListTile extends StatelessWidget {
  const PaymentListTile({super.key, required this.payment, this.onTap, this.onEdit, this.onVoid});
  final ChargePayment payment;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onVoid;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool showAdminMenu = !payment.isVoid && (onEdit != null || onVoid != null);

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceS),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(backgroundColor: payment.isVoid ? scheme.surfaceContainerHighest : scheme.primaryContainer, child: Icon(Icons.payments_outlined, color: payment.isVoid ? scheme.onSurfaceVariant : scheme.onPrimaryContainer, size: 20)),
        title: Text(CurrencyFormatter.formatWithUnit(payment.amount), style: payment.isVoid ? const TextStyle(decoration: TextDecoration.lineThrough) : Theme.of(context).textTheme.titleSmall),
        subtitle: Text('${DateFormatter.jalaliMonthName(payment.month)} ${CurrencyFormatter.toPersianDigits(payment.year.toString())} · ${DateFormatter.formatShort(payment.paymentDate)}'),
        trailing: payment.isVoid
            ? Chip(label: const Text('باطل‌شده'), backgroundColor: scheme.errorContainer)
            : showAdminMenu
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit?.call();
                  if (value == 'void') onVoid?.call();
                },
                itemBuilder: (context) => [if (onEdit != null) const PopupMenuItem(value: 'edit', child: Text('ویرایش')), if (onVoid != null) const PopupMenuItem(value: 'void', child: Text('باطل کردن'))],
              )
            : null,
      ),
    );
  }
}
