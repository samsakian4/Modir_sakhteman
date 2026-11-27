import 'package:equatable/equatable.dart';

class Apartment extends Equatable {
  const Apartment({required this.id, required this.unitNumber, required this.ownerName, this.phone, this.residentsCount, this.notes, required this.isActive, required this.createdAt});
  final String id;
  final String unitNumber;
  final String ownerName;
  final String? phone;
  final int? residentsCount;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  @override
  List<Object?> get props => [id, unitNumber, ownerName, phone, residentsCount, notes, isActive, createdAt];
}
