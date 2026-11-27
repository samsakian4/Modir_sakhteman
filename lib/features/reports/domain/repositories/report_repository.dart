import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/monthly_report.dart';

abstract class ReportRepository {
  Future<Either<Failure, MonthlyReport>> getMonthlyReport({required int jalaliYear, required int jalaliMonth});
}
