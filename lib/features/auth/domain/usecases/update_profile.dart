import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileUseCase implements UseCase<User, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      name: params.name,
      phone: params.phone,
      street: params.street,
      district: params.district,
      city: params.city,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String name;
  final String? phone;
  final String? street;
  final String? district;
  final String? city;

  const UpdateProfileParams({
    required this.name,
    this.phone,
    this.street,
    this.district,
    this.city,
  });

  @override
  List<Object?> get props => [name, phone, street, district, city];
}
