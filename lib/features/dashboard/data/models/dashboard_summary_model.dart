import '../../domain/entities/dashboard_summary.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({required super.currentBalance, required super.totalIncome, required super.totalExpenses, required super.paidUnits, required super.unpaidUnits, required super.totalActiveApartments, required super.activeGoals});

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      currentBalance: (json['current_balance'] as num).toDouble(),
      totalIncome: (json['total_income'] as num).toDouble(),
      totalExpenses: (json['total_expenses'] as num).toDouble(),
      paidUnits: (json['paid_units'] as num).toInt(),
      unpaidUnits: (json['unpaid_units'] as num).toInt(),
      totalActiveApartments: (json['total_active_apartments'] as num).toInt(),
      activeGoals: (json['active_goals'] as num).toInt(),
    );
  }
}
