import '../../domain/entities/apartment.dart';

class ApartmentModel extends Apartment {
  const ApartmentModel({required super.id, required super.unitNumber, required super.ownerName, super.phone, super.residentsCount, super.notes, required super.isActive, required super.createdAt});

  factory ApartmentModel.fromJson(Map<String, dynamic> json) {
    return ApartmentModel(
      id: json['id'] as String,
      unitNumber: json['unit_number'] as String,
      ownerName: json['owner_name'] as String,
      phone: json['phone'] as String?,
      residentsCount: json['residents_count'] as int?,
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
