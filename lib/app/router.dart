import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/apartments/presentation/pages/apartment_detail_page.dart';
import '../features/apartments/presentation/pages/apartment_form_page.dart';
import '../features/apartments/presentation/pages/apartments_page.dart';
import '../features/authentication/presentation/pages/login_page.dart';
import '../features/authentication/presentation/providers/auth_provider.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/expenses/presentation/pages/expense_form_page.dart';
import '../features/goals/presentation/pages/goal_detail_page.dart';
import '../features/goals/presentation/pages/goal_form_page.dart';
import '../features/goals/presentation/pages/goals_page.dart';
import '../features/payments/presentation/pages/payment_form_page.dart';
import '../features/payments/presentation/pages/transactions_page.dart';
import '../features/reports/presentation/pages/reports_page.dart';
import '../shared/models/charge_payment.dart';
import '../shared/models/expense.dart';
import '../shared/models/goal.dart';
import 'app_shell.dart';

abstract class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String transactions = '/transactions';
  static const String goals = '/goals';
  static const String apartments = '/apartments';
  static const String reports = '/reports';

  static const String apartmentNew = '/apartments/new';
  static String apartmentDetailPath(String id) => '/apartments/$id';
  static String apartmentEditPath(String id) => '/apartments/$id/edit';

  static String paymentNewPath(String apartmentId) => '/payments/new/$apartmentId';
  static const String paymentEdit = '/payments/edit';

  static const String expenseNew = '/expenses/new';
  static const String expenseEdit = '/expenses/edit';

  static const String goalNew = '/goals/new';
  static const String goalEdit = '/goals/edit';
  static String goalDetailPath(String id) => '/goals/$id';
}

/// Bridges Riverpod auth-state changes into a [Listenable] so GoRouter can
/// re-evaluate its redirect logic whenever the signed-in state changes.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen<bool?>(isAuthenticatedProvider, (previous, next) {
      if (previous != next) notifyListeners();
    });
  }
}

final Provider<GoRouter> goRouterProvider = Provider<GoRouter>((ref) {
  final _AuthRefreshNotifier refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final bool? isAuthenticated = ref.read(isAuthenticatedProvider);
      final bool isLoggingIn = state.matchedLocation == AppRoutes.login;

      if (isAuthenticated == null) return null;
      if (!isAuthenticated) return isLoggingIn ? null : AppRoutes.login;
      if (isLoggingIn) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.dashboard, builder: (context, state) => const DashboardPage()),
          GoRoute(path: AppRoutes.transactions, builder: (context, state) => const TransactionsPage()),
          GoRoute(path: AppRoutes.goals, builder: (context, state) => const GoalsPage()),
          GoRoute(path: AppRoutes.apartments, builder: (context, state) => const ApartmentsPage()),
          GoRoute(path: AppRoutes.reports, builder: (context, state) => const ReportsPage()),
        ],
      ),
      GoRoute(path: AppRoutes.apartmentNew, builder: (context, state) => const ApartmentFormPage()),
      GoRoute(path: '/apartments/:id', builder: (context, state) => ApartmentDetailPage(apartmentId: state.pathParameters['id']!)),
      GoRoute(path: '/apartments/:id/edit', builder: (context, state) => ApartmentFormPage(apartmentId: state.pathParameters['id'])),
      GoRoute(path: '/payments/new/:apartmentId', builder: (context, state) => PaymentFormPage(apartmentIdForNew: state.pathParameters['apartmentId'])),
      GoRoute(path: AppRoutes.paymentEdit, builder: (context, state) => PaymentFormPage(existingPayment: state.extra as ChargePayment?)),
      GoRoute(path: AppRoutes.expenseNew, builder: (context, state) => const ExpenseFormPage()),
      GoRoute(path: AppRoutes.expenseEdit, builder: (context, state) => ExpenseFormPage(existingExpense: state.extra as Expense?)),
      GoRoute(path: AppRoutes.goalNew, builder: (context, state) => const GoalFormPage()),
      GoRoute(path: AppRoutes.goalEdit, builder: (context, state) => GoalFormPage(existingGoal: state.extra as Goal?)),
      GoRoute(path: '/goals/:id', builder: (context, state) => GoalDetailPage(goalId: state.pathParameters['id']!)),
    ],
  );
});
