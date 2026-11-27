import 'package:equatable/equatable.dart';

class ChargePayment extends Equatable {
  const ChargePayment({
    required this.id, required this.apartmentId, required this.amount, required this.paymentDate,
    required this.month, required this.year, this.description, required this.isVoid, required this.createdAt,
  });

  final String id;
  final String apartmentId;
  final double amount;
  final DateTime paymentDate;
  final int month;
  final int year;
  final String? description;
  final bool isVoid;
  final DateTime createdAt;

  factory ChargePayment.fromJson(Map<String, dynamic> json) {
    return ChargePayment(
      id: json['id'] as String,
      apartmentId: json['apartment_id'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['payment_date'] as String),
      month: json['month'] as int,
      year: json['year'] as int,
      description: json['description'] as String?,
      isVoid: json['is_void'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, apartmentId, amount, paymentDate, month, year, description, isVoid, createdAt];
}
