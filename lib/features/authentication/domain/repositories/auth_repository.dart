import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AppUser>> login({required String phone, required String password});
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, AppUser?>> getCurrentUser();
}
