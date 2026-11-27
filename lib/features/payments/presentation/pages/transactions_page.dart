import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../shared/models/charge_payment.dart';
import '../../../../shared/models/expense.dart';
import '../../../apartments/presentation/providers/apartment_providers.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../../expenses/presentation/widgets/expense_attachments_sheet.dart';
import '../../../expenses/presentation/widgets/expense_list_tile.dart';
import '../providers/payment_providers.dart';
import '../widgets/payment_list_tile.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});
  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _confirmVoidPayment(ChargePayment payment) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('باطل کردن پرداخت'),
        content: const Text('این پرداخت باطل شود؟'),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('انصراف')), FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('باطل کن'))],
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = await ref.read(voidPaymentUseCaseProvider)(payment.id);
    if (!mounted) return;
    result.fold((failure) => AppSnackbar.error(context, failure.message), (_) {
      ref.read(paymentListProvider.notifier).refresh();
      ref.read(apartmentListProvider.notifier).refresh();
      AppSnackbar.success(context, 'پرداخت باطل شد.');
    });
  }

  Future<void> _confirmVoidExpense(Expense expense) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('باطل کردن هزینه'),
        content: const Text('این هزینه باطل شود؟'),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('انصراف')), FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('باطل کن'))],
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = await ref.read(voidExpenseUseCaseProvider)(expense.id);
    if (!mounted) return;
    result.fold((failure) => AppSnackbar.error(context, failure.message), (_) {
      ref.read(expenseListProvider.notifier).refresh();
      AppSnackbar.success(context, 'هزینه باطل شد.');
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthState authState = ref.watch(authProvider);
    final bool isAdmin = authState is AuthAuthenticated && authState.role.isAdmin;
    final AsyncValue<List<ChargePayment>> paymentsAsync = ref.watch(paymentListProvider);
    final AsyncValue<List<Expense>> expensesAsync = ref.watch(expenseListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تراکنش‌ها'), bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'پرداخت‌ها'), Tab(text: 'هزینه‌ها')])),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                if (_tabController.index == 0) {
                  context.push(AppRoutes.apartments);
                } else {
                  context.push(AppRoutes.expenseNew);
                }
              },
              child: Icon(_tabController.index == 0 ? Icons.apartment_outlined : Icons.add_rounded),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
            onRefresh: () => ref.read(paymentListProvider.notifier).refresh(),
            child: paymentsAsync.when(
              loading: () => const SkeletonList(count: 6),
              error: (error, _) => ErrorView(failure: error is Failure ? error : UnknownFailure(error.toString()), onRetry: () => ref.read(paymentListProvider.notifier).refresh()),
              data: (payments) {
                if (payments.isEmpty) return const EmptyState(icon: Icons.payments_outlined, message: 'هنوز هیچ پرداختی ثبت نشده است.');
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final ChargePayment payment = payments[index];
                    return PaymentListTile(payment: payment, onEdit: isAdmin ? () => context.push(AppRoutes.paymentEdit, extra: payment) : null, onVoid: isAdmin ? () => _confirmVoidPayment(payment) : null);
                  },
                );
              },
            ),
          ),
          RefreshIndicator(
            onRefresh: () => ref.read(expenseListProvider.notifier).refresh(),
            child: expensesAsync.when(
              loading: () => const SkeletonList(count: 6),
              error: (error, _) => ErrorView(failure: error is Failure ? error : UnknownFailure(error.toString()), onRetry: () => ref.read(expenseListProvider.notifier).refresh()),
              data: (expenses) {
                if (expenses.isEmpty) return const EmptyState(icon: Icons.receipt_long_outlined, message: 'هنوز هیچ هزینه‌ای ثبت نشده است.');
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final Expense expense = expenses[index];
                    return ExpenseListTile(expense: expense, onTap: () => showExpenseAttachments(context, expense.id), onEdit: isAdmin ? () => context.push(AppRoutes.expenseEdit, extra: expense) : null, onVoid: isAdmin ? () => _confirmVoidExpense(expense) : null);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
