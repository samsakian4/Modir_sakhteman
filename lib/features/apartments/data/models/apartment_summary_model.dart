import '../../domain/entities/apartment_summary.dart';
import 'apartment_model.dart';

class ApartmentSummaryModel extends ApartmentSummary {
  const ApartmentSummaryModel({required super.apartment, required super.isPaidThisMonth, super.lastPaymentDate, super.lastPaymentAmount, required super.debt});

  factory ApartmentSummaryModel.fromJson(Map<String, dynamic> json) {
    return ApartmentSummaryModel(
      apartment: ApartmentModel.fromJson(json),
      isPaidThisMonth: json['is_paid_this_month'] as bool? ?? false,
      lastPaymentDate: json['last_payment_date'] == null ? null : DateTime.parse(json['last_payment_date'] as String),
      lastPaymentAmount: json['last_payment_amount'] == null ? null : (json['last_payment_amount'] as num).toDouble(),
      debt: (json['debt'] as num?)?.toDouble() ?? 0,
    );
  }
}
