import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);
  final AuthRepository _repository;
  Future<Either<Failure, AppUser?>> call() => _repository.getCurrentUser();
}
