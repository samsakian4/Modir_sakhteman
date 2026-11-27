import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/apartments/presentation/providers/apartment_providers.dart';
import '../../features/dashboard/presentation/providers/dashboard_providers.dart';
import '../../features/expenses/presentation/providers/expense_providers.dart';
import '../../features/goals/presentation/providers/goal_providers.dart';
import '../../features/payments/presentation/providers/payment_providers.dart';
import '../../features/reports/presentation/providers/report_providers.dart';
import '../constants/supabase_constants.dart';
import 'supabase_service.dart';

/// Listens to table changes and invalidates the affected providers so every
/// screen stays current without manual refresh. Watch it once from the app shell.
final Provider<void> realtimeSyncProvider = Provider<void>((ref) {
  Timer? debounce;

  void refreshAll() {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 600), () {
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(recentActivityProvider);
      ref.invalidate(paymentListProvider);
      ref.invalidate(expenseListProvider);
      ref.invalidate(apartmentListProvider);
      ref.invalidate(goalListProvider);
      ref.invalidate(monthlyReportProvider);
    });
  }

  final RealtimeChannel channel = SupabaseService.client.channel('public-changes');
  for (final String table in [SupabaseTables.chargePayments, SupabaseTables.expenses, SupabaseTables.goals, SupabaseTables.apartments]) {
    channel.onPostgresChanges(event: PostgresChangeEvent.all, schema: 'public', table: table, callback: (_) => refreshAll());
  }
  channel.subscribe();

  ref.onDispose(() {
    debounce?.cancel();
    SupabaseService.client.removeChannel(channel);
  });
});
