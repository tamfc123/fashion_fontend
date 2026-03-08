import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    int page = 1,
    int limit = 10,
    String? category,
    String? search,
  });

  Future<Either<Failure, ProductEntity>> getProductDetails(String id);
}
