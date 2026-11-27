import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/services/realtime_sync_provider.dart';
import 'router.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  static const List<_NavItem> _items = [
    _NavItem(route: AppRoutes.dashboard, label: 'داشبورد', icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard_rounded),
    _NavItem(route: AppRoutes.transactions, label: 'تراکنش‌ها', icon: Icons.receipt_long_outlined, selectedIcon: Icons.receipt_long_rounded),
    _NavItem(route: AppRoutes.goals, label: 'اهداف', icon: Icons.flag_outlined, selectedIcon: Icons.flag_rounded),
    _NavItem(route: AppRoutes.apartments, label: 'واحدها', icon: Icons.apartment_outlined, selectedIcon: Icons.apartment_rounded),
    _NavItem(route: AppRoutes.reports, label: 'گزارش', icon: Icons.bar_chart_outlined, selectedIcon: Icons.bar_chart_rounded),
  ];

  int _indexForLocation(String location) {
    final int index = _items.indexWhere((item) => location.startsWith(item.route));
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(realtimeSyncProvider);
    final String location = GoRouterState.of(context).matchedLocation;
    final int currentIndex = _indexForLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          if (index == currentIndex) return;
          context.go(_items[index].route);
        },
        destinations: [for (final item in _items) NavigationDestination(icon: Icon(item.icon), selectedIcon: Icon(item.selectedIcon), label: item.label)],
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.route, required this.label, required this.icon, required this.selectedIcon});
  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
