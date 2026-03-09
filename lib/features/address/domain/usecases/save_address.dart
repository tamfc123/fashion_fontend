import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/address_entity.dart';
import '../repositories/address_repository.dart';

class SaveAddressUseCase implements UseCase<void, AddressEntity> {
  final AddressRepository repository;

  SaveAddressUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddressEntity params) async {
    return await repository.saveAddress(params);
  }
}
