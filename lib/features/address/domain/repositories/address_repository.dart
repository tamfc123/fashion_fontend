import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/address_entity.dart';

abstract class AddressRepository {
  Future<Either<Failure, void>> saveAddress(AddressEntity address);
}
