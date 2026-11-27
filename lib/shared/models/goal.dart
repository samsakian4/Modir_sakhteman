import 'package:equatable/equatable.dart';

import '../enums/goal_status.dart';

class Goal extends Equatable {
  const Goal({
    required this.id,
    required this.title,
    this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.status,
    this.startDate,
    this.endDate,
    this.finalNotes,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String? description;
  final double targetAmount;
  final double currentAmount;
  final GoalStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? finalNotes;
  final DateTime createdAt;

  double get progressPercent {
    if (targetAmount <= 0) return 0;
    final double pct = (currentAmount / targetAmount) * 100;
    return pct.clamp(0, 100);
  }

  bool get isCompleted => status == GoalStatus.completed;

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      targetAmount: (json['target_amount'] as num).toDouble(),
      currentAmount: (json['current_amount'] as num?)?.toDouble() ?? 0,
      status: GoalStatus.fromDbValue(json['status'] as String),
      startDate: json['start_date'] == null ? null : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null ? null : DateTime.parse(json['end_date'] as String),
      finalNotes: json['final_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, title, description, targetAmount, currentAmount, status, startDate, endDate, finalNotes, createdAt];
}
