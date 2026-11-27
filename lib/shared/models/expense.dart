import 'package:equatable/equatable.dart';

import '../enums/expense_category.dart';

class Expense extends Equatable {
  const Expense({
    required this.id, required this.title, required this.category, required this.amount,
    required this.expenseDate, this.description, required this.isVoid, required this.createdAt,
  });

  final String id;
  final String title;
  final ExpenseCategory category;
  final double amount;
  final DateTime expenseDate;
  final String? description;
  final bool isVoid;
  final DateTime createdAt;

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      title: json['title'] as String,
      category: ExpenseCategory.fromDbValue(json['category'] as String),
      amount: (json['amount'] as num).toDouble(),
      expenseDate: DateTime.parse(json['expense_date'] as String),
      description: json['description'] as String?,
      isVoid: json['is_void'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, title, category, amount, expenseDate, description, isVoid, createdAt];
}
