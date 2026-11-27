import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.balance});
  final double balance;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isNegative = balance < 0;
    final Color fg = isNegative ? scheme.onErrorContainer : scheme.onPrimaryContainer;

    return Card(
      color: isNegative ? scheme.errorContainer : scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(Icons.account_balance_wallet_outlined, color: fg), const SizedBox(width: AppDimensions.spaceS), Text('موجودی فعلی صندوق', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: fg))]),
            const SizedBox(height: AppDimensions.spaceS),
            Text(CurrencyFormatter.formatWithUnit(balance), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: fg, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
