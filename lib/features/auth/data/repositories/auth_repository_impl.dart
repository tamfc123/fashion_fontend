import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/register.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final NetworkInfo networkInfo;
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.networkInfo,
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AuthResponse>> login(LoginParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteAuth = await remoteDataSource.login(
          params.email,
          params.password,
        );
        await localDataSource.cacheToken(remoteAuth.token);
        await localDataSource.cacheUser(remoteAuth.user as UserModel);
        return Right(remoteAuth);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> register(RegisterParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteAuth = await remoteDataSource.register(
          params.email,
          params.password,
          params.name,
        );
        await localDataSource.cacheToken(remoteAuth.token);
        await localDataSource.cacheUser(remoteAuth.user as UserModel);
        return Right(remoteAuth);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final token = await localDataSource.getToken();
      if (token != null) {
        if (await networkInfo.isConnected) {
          try {
            final remoteUser = await remoteDataSource.getMe();
            await localDataSource.cacheUser(remoteUser);
            return Right(remoteUser);
          } on ServerException catch (e) {
            // If token is invalid or server down, fallback to cache or log out.
            // Usually we'd check if e.message is 'Unauthorized'. For safety, we fallback to cache on network blips:
            try {
              final localUser = await localDataSource.getCachedUser();
              return Right(localUser);
            } catch (_) {
              return Left(ServerFailure(message: e.message));
            }
          }
        } else {
          final localUser = await localDataSource.getCachedUser();
          return Right(localUser);
        }
      } else {
        return const Left(AuthFailure(message: 'No token found in cache'));
      }
    } on CacheException {
      return const Left(AuthFailure(message: 'Cache error or data missing'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    required String name,
    String? phone,
    String? street,
    String? district,
    String? city,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedUser = await remoteDataSource.updateProfile(
          name: name,
          phone: phone,
          street: street,
          district: district,
          city: city,
        );
        await localDataSource.cacheUser(updatedUser);
        return Right(updatedUser);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
