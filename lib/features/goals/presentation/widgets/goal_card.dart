import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/models/goal.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.goal, this.onTap});
  final Goal goal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final double progress = goal.progressPercent / 100;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceS),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(goal.title, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: AppDimensions.spaceS),
                  Chip(
                    label: Text(goal.status.label, style: TextStyle(color: goal.status.color, fontSize: 11, fontWeight: FontWeight.w600)),
                    backgroundColor: goal.status.color.withValues(alpha: 0.12),
                    visualDensity: VisualDensity.compact,
                    side: BorderSide.none,
                  ),
                ],
              ),
              if (goal.description != null && goal.description!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spaceXXS),
                Text(goal.description!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: AppDimensions.spaceM),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: scheme.surfaceContainerHighest, valueColor: AlwaysStoppedAnimation<Color>(goal.status.color)),
              ),
              const SizedBox(height: AppDimensions.spaceXS),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${CurrencyFormatter.toPersianDigits(goal.progressPercent.toStringAsFixed(0))}٪ تأمین‌شده', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
                  Text('${CurrencyFormatter.formatWithUnit(goal.currentAmount)} از ${CurrencyFormatter.formatWithUnit(goal.targetAmount)}', style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
              if (goal.endDate != null) ...[
                const SizedBox(height: AppDimensions.spaceXXS),
                Row(children: [
                  Icon(Icons.event_outlined, size: AppDimensions.iconS, color: scheme.onSurfaceVariant),
                  const SizedBox(width: AppDimensions.spaceXXS),
                  Text('مهلت: ${DateFormatter.formatShort(goal.endDate!)}', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
