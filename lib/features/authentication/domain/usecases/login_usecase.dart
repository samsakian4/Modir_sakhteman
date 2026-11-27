import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);
  final AuthRepository _repository;
  Future<Either<Failure, AppUser>> call({required String phone, required String password}) => _repository.login(phone: phone, password: password);
}
