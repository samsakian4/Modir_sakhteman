import 'package:equatable/equatable.dart';

import '../../../../shared/enums/user_role.dart';

sealed class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  const AuthLoading();
  @override
  List<Object?> get props => [];
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.userId, required this.fullName, required this.role, this.apartmentId});
  final String userId;
  final String fullName;
  final UserRole role;
  final String? apartmentId;
  @override
  List<Object?> get props => [userId, fullName, role, apartmentId];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.errorMessage});
  final String? errorMessage;
  @override
  List<Object?> get props => [errorMessage];
}
