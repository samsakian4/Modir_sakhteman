import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/datasources/report_remote_datasource.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/entities/monthly_report.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/usecases/get_monthly_report_usecase.dart';

final Provider<ReportRemoteDataSource> reportRemoteDataSourceProvider = Provider<ReportRemoteDataSource>((ref) => ReportRemoteDataSourceImpl(SupabaseService.client));
final Provider<ReportRepository> reportRepositoryProvider = Provider<ReportRepository>((ref) => ReportRepositoryImpl(ref.watch(reportRemoteDataSourceProvider)));
final Provider<GetMonthlyReportUseCase> getMonthlyReportUseCaseProvider = Provider((ref) => GetMonthlyReportUseCase(ref.watch(reportRepositoryProvider)));

class SelectedReportPeriodNotifier extends Notifier<({int year, int month})> {
  @override
  ({int year, int month}) build() => DateFormatter.currentJalaliYearMonth();

  void goToPreviousMonth() {
    final int year = state.month == 1 ? state.year - 1 : state.year;
    final int month = state.month == 1 ? 12 : state.month - 1;
    state = (year: year, month: month);
  }

  void goToNextMonth() {
    final int year = state.month == 12 ? state.year + 1 : state.year;
    final int month = state.month == 12 ? 1 : state.month + 1;
    state = (year: year, month: month);
  }
}

final NotifierProvider<SelectedReportPeriodNotifier, ({int year, int month})> selectedReportPeriodProvider = NotifierProvider(SelectedReportPeriodNotifier.new);

final FutureProvider<MonthlyReport> monthlyReportProvider = FutureProvider<MonthlyReport>((ref) async {
  final ({int year, int month}) period = ref.watch(selectedReportPeriodProvider);
  final result = await ref.read(getMonthlyReportUseCaseProvider)(jalaliYear: period.year, jalaliMonth: period.month);
  return result.fold((failure) => throw failure, (report) => report);
});
