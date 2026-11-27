import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/supabase_service.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/activity_item.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/get_dashboard_summary_usecase.dart';
import '../../domain/usecases/get_recent_activity_usecase.dart';

final Provider<DashboardRemoteDataSource> dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) => DashboardRemoteDataSourceImpl(SupabaseService.client));
final Provider<DashboardRepository> dashboardRepositoryProvider = Provider<DashboardRepository>((ref) => DashboardRepositoryImpl(ref.watch(dashboardRemoteDataSourceProvider)));
final Provider<GetDashboardSummaryUseCase> getDashboardSummaryUseCaseProvider = Provider((ref) => GetDashboardSummaryUseCase(ref.watch(dashboardRepositoryProvider)));
final Provider<GetRecentActivityUseCase> getRecentActivityUseCaseProvider = Provider((ref) => GetRecentActivityUseCase(ref.watch(dashboardRepositoryProvider)));

final FutureProvider<DashboardSummary> dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final result = await ref.read(getDashboardSummaryUseCaseProvider)();
  return result.fold((failure) => throw failure, (summary) => summary);
});

final FutureProvider<List<ActivityItem>> recentActivityProvider = FutureProvider<List<ActivityItem>>((ref) async {
  final result = await ref.read(getRecentActivityUseCaseProvider)();
  return result.fold((failure) => throw failure, (items) => items);
});
