import 'package:flutter/material.dart';

import '../../core/constants/app_dimensions.dart';

class ScaffoldPlaceholderPage extends StatelessWidget {
  const ScaffoldPlaceholderPage({super.key, required this.title, required this.icon, this.stageNote, this.actions});
  final String title;
  final IconData icon;
  final String? stageNote;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceXL),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 56, color: scheme.primary),
            const SizedBox(height: AppDimensions.spaceM),
            Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            if (stageNote != null) ...[
              const SizedBox(height: AppDimensions.spaceS),
              Text(stageNote!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant), textAlign: TextAlign.center),
            ],
          ]),
        ),
      ),
    );
  }
}
