import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/models/expense.dart';

class ExpenseListTile extends StatelessWidget {
  const ExpenseListTile({super.key, required this.expense, this.onTap, this.onEdit, this.onVoid});
  final Expense expense;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onVoid;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool showAdminMenu = !expense.isVoid && (onEdit != null || onVoid != null);

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceS),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(backgroundColor: expense.isVoid ? scheme.surfaceContainerHighest : scheme.errorContainer, child: Icon(expense.category.icon, color: expense.isVoid ? scheme.onSurfaceVariant : scheme.onErrorContainer, size: 20)),
        title: Text(expense.title, style: expense.isVoid ? const TextStyle(decoration: TextDecoration.lineThrough) : null),
        subtitle: Text('${expense.category.label} · ${DateFormatter.formatShort(expense.expenseDate)}'),
        trailing: expense.isVoid
            ? Chip(label: const Text('باطل‌شده'), backgroundColor: scheme.errorContainer)
            : showAdminMenu
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                Text(CurrencyFormatter.formatWithUnit(expense.amount), style: Theme.of(context).textTheme.titleSmall?.copyWith(color: scheme.error, fontWeight: FontWeight.w600)),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit?.call();
                    if (value == 'void') onVoid?.call();
                  },
                  itemBuilder: (context) => [if (onEdit != null) const PopupMenuItem(value: 'edit', child: Text('ویرایش')), if (onVoid != null) const PopupMenuItem(value: 'void', child: Text('باطل کردن'))],
                ),
              ])
            : Text(CurrencyFormatter.formatWithUnit(expense.amount), style: Theme.of(context).textTheme.titleSmall?.copyWith(color: scheme.error, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
