import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_input_entity.dart';

abstract class AdminProductRepository {
  /// Returns the ID of the newly created product
  Future<Either<Failure, String>> createProduct(ProductInputEntity product);
}
