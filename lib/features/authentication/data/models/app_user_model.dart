import '../../../../shared/enums/user_role.dart';
import '../../domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({required super.id, required super.fullName, required super.phone, required super.role, super.apartmentId});

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: UserRole.fromDbValue(json['role'] as String? ?? 'resident'),
      apartmentId: json['apartment_id'] as String?,
    );
  }
}
