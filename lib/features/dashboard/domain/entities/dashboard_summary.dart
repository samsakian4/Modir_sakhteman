import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  const DashboardSummary({required this.currentBalance, required this.totalIncome, required this.totalExpenses, required this.paidUnits, required this.unpaidUnits, required this.totalActiveApartments, required this.activeGoals});
  final double currentBalance;
  final double totalIncome;
  final double totalExpenses;
  final int paidUnits;
  final int unpaidUnits;
  final int totalActiveApartments;
  final int activeGoals;
  @override
  List<Object?> get props => [currentBalance, totalIncome, totalExpenses, paidUnits, unpaidUnits, totalActiveApartments, activeGoals];
}
