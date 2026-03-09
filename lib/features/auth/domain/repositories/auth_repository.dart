import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_response.dart';
import '../entities/user.dart';
import '../usecases/login.dart';
import '../usecases/register.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> login(LoginParams params);
  Future<Either<Failure, AuthResponse>> register(RegisterParams params);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, User>> updateProfile({
    required String name,
    String? phone,
    String? street,
    String? district,
    String? city,
  });
}
