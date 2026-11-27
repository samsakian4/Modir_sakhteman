import 'package:equatable/equatable.dart';

enum ActivityType { payment, expense }

class ActivityItem extends Equatable {
  const ActivityItem({required this.type, required this.title, required this.amount, required this.occurredAt});
  final ActivityType type;
  final String title;
  final double amount;
  final DateTime occurredAt;
  @override
  List<Object?> get props => [type, title, amount, occurredAt];
}
