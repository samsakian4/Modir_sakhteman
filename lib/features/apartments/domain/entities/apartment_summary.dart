import 'package:equatable/equatable.dart';

import 'apartment.dart';

class ApartmentSummary extends Equatable {
  const ApartmentSummary({required this.apartment, required this.isPaidThisMonth, this.lastPaymentDate, this.lastPaymentAmount, required this.debt});
  final Apartment apartment;
  final bool isPaidThisMonth;
  final DateTime? lastPaymentDate;
  final double? lastPaymentAmount;
  final double debt;
  bool get hasDebt => debt > 0;
  @override
  List<Object?> get props => [apartment, isPaidThisMonth, lastPaymentDate, lastPaymentAmount, debt];
}
