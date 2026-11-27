import 'package:flutter/material.dart';

import '../errors/failures.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.failure, this.onRetry});
  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline, size: 56, color: scheme.error),
          const SizedBox(height: 16),
          Text(failure.message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('تلاش مجدد')),
          ],
        ]),
      ),
    );
  }
}
