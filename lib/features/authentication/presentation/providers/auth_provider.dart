import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/supabase_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_state.dart';

final Provider<AuthRemoteDataSource> authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) => AuthRemoteDataSourceImpl(SupabaseService.client));
final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider)));
final Provider<LoginUseCase> loginUseCaseProvider = Provider<LoginUseCase>((ref) => LoginUseCase(ref.watch(authRepositoryProvider)));
final Provider<LogoutUseCase> logoutUseCaseProvider = Provider<LogoutUseCase>((ref) => LogoutUseCase(ref.watch(authRepositoryProvider)));
final Provider<GetCurrentUserUseCase> getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) => GetCurrentUserUseCase(ref.watch(authRepositoryProvider)));

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    final sub = SupabaseService.auth.onAuthStateChange.listen((_) => _restoreSession());
    ref.onDispose(sub.cancel);
    Future.microtask(_restoreSession);
    return const AuthInitial();
  }

  GetCurrentUserUseCase get _getCurrentUser => ref.read(getCurrentUserUseCaseProvider);
  LoginUseCase get _login => ref.read(loginUseCaseProvider);
  LogoutUseCase get _logout => ref.read(logoutUseCaseProvider);

  Future<void> _restoreSession() async {
    final Either<Failure, AppUser?> result = await _getCurrentUser();
    state = result.fold((failure) => AuthUnauthenticated(errorMessage: failure.message), (user) => _stateForUser(user));
  }

  Future<bool> login({required String phone, required String password}) async {
    state = const AuthLoading();
    final Either<Failure, AppUser> result = await _login(phone: phone, password: password);
    return result.fold(
      (failure) {
        state = AuthUnauthenticated(errorMessage: failure.message);
        return false;
      },
      (user) {
        state = AuthAuthenticated(userId: user.id, fullName: user.fullName, role: user.role, apartmentId: user.apartmentId);
        return true;
      },
    );
  }

  Future<void> logout() async {
    await _logout();
    state = const AuthUnauthenticated();
  }

  AuthState _stateForUser(AppUser? user) {
    if (user == null) return const AuthUnauthenticated();
    return AuthAuthenticated(userId: user.id, fullName: user.fullName, role: user.role, apartmentId: user.apartmentId);
  }
}

final NotifierProvider<AuthNotifier, AuthState> authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

final Provider<bool?> isAuthenticatedProvider = Provider<bool?>((ref) {
  final AuthState state = ref.watch(authProvider);
  return switch (state) {
    AuthInitial() || AuthLoading() => null,
    AuthAuthenticated() => true,
    AuthUnauthenticated() => false,
  };
});
