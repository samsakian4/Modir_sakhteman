import 'package:equatable/equatable.dart';

import '../../../../shared/enums/expense_category.dart';

class CategoryBreakdown extends Equatable {
  const CategoryBreakdown({required this.category, required this.amount});
  final ExpenseCategory category;
  final double amount;
  @override
  List<Object?> get props => [category, amount];
}

class MonthlyReport extends Equatable {
  const MonthlyReport({
    required this.jalaliYear,
    required this.jalaliMonth,
    required this.totalIncome,
    required this.totalExpenses,
    required this.paidUnitsCount,
    required this.unpaidUnitsCount,
    required this.totalActiveApartments,
    required this.categoryBreakdown,
  });

  final int jalaliYear;
  final int jalaliMonth;
  final double totalIncome;
  final double totalExpenses;
  final int paidUnitsCount;
  final int unpaidUnitsCount;
  final int totalActiveApartments;
  final List<CategoryBreakdown> categoryBreakdown;

  double get netBalance => totalIncome - totalExpenses;

  @override
  List<Object?> get props => [jalaliYear, jalaliMonth, totalIncome, totalExpenses, paidUnitsCount, unpaidUnitsCount, totalActiveApartments, categoryBreakdown];
}
