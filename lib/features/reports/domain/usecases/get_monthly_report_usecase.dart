import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/monthly_report.dart';
import '../repositories/report_repository.dart';

class GetMonthlyReportUseCase {
  const GetMonthlyReportUseCase(this._repository);
  final ReportRepository _repository;
  Future<Either<Failure, MonthlyReport>> call({required int jalaliYear, required int jalaliMonth}) {
    return _repository.getMonthlyReport(jalaliYear: jalaliYear, jalaliMonth: jalaliMonth);
  }
}
