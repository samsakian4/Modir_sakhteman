import 'package:equatable/equatable.dart';

import '../../../../shared/enums/user_role.dart';

class AppUser extends Equatable {
  const AppUser({required this.id, required this.fullName, required this.phone, required this.role, this.apartmentId});
  final String id;
  final String fullName;
  final String phone;
  final UserRole role;
  final String? apartmentId;
  bool get isAdmin => role.isAdmin;
  bool get isResident => role.isResident;
  @override
  List<Object?> get props => [id, fullName, phone, role, apartmentId];
}
