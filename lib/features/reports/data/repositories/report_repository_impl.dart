import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/monthly_report.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  const ReportRepositoryImpl(this._remote);
  final ReportRemoteDataSource _remote;

  @override
  Future<Either<Failure, MonthlyReport>> getMonthlyReport({required int jalaliYear, required int jalaliMonth}) async {
    try {
      return Right(await _remote.getMonthlyReport(jalaliYear: jalaliYear, jalaliMonth: jalaliMonth));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
