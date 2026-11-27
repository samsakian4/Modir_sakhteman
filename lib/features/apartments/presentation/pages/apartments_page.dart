import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';
import '../../domain/entities/apartment_summary.dart';
import '../providers/apartment_providers.dart';
import '../widgets/apartment_list_card.dart';

class ApartmentsPage extends ConsumerWidget {
  const ApartmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ApartmentSummary>> summariesAsync = ref.watch(apartmentListProvider);
    final AuthState authState = ref.watch(authProvider);
    final bool isAdmin = authState is AuthAuthenticated && authState.role.isAdmin;

    return Scaffold(
      appBar: AppBar(title: const Text('واحدها')),
      floatingActionButton: isAdmin ? FloatingActionButton(onPressed: () => context.push(AppRoutes.apartmentNew), child: const Icon(Icons.add_rounded)) : null,
      body: RefreshIndicator(
        onRefresh: () => ref.read(apartmentListProvider.notifier).refresh(),
        child: summariesAsync.when(
          loading: () => const SkeletonList(count: 6),
          error: (error, _) => ErrorView(failure: error is Failure ? error : UnknownFailure(error.toString()), onRetry: () => ref.read(apartmentListProvider.notifier).refresh()),
          data: (summaries) {
            if (summaries.isEmpty) return const EmptyState(icon: Icons.apartment_outlined, message: 'هنوز هیچ واحدی ثبت نشده است.');
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: summaries.length,
              itemBuilder: (context, index) {
                final ApartmentSummary summary = summaries[index];
                return ApartmentListCard(summary: summary, onTap: () => context.push(AppRoutes.apartmentDetailPath(summary.apartment.id)));
              },
            );
          },
        ),
      ),
    );
  }
}
