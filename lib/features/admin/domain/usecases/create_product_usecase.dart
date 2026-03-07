import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/product_input_entity.dart';
import '../repositories/admin_product_repository.dart';

class CreateProductUseCase implements UseCase<String, CreateProductParams> {
  final AdminProductRepository repository;

  CreateProductUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(CreateProductParams params) async {
    // 1. Validate image constraints (Max 5 images to prevent payload issues)
    if (params.product.imageFiles != null &&
        params.product.imageFiles!.length > 5) {
      return const Left(
        ServerFailure(message: 'Maximum 5 images allowed per product'),
      );
    }

    // 2. Validate that the product has at least one variant
    if (params.product.variants.isEmpty) {
      return const Left(
        ServerFailure(message: 'Product must have at least one variant'),
      );
    }

    // 2. Validate price and stock constraints based directly on the Backend limits
    for (var variant in params.product.variants) {
      if (variant.price < 0) {
        return const Left(
          ServerFailure(message: 'Price must be greater than or equal to 0'),
        );
      }
      if (variant.stock < 0) {
        return const Left(
          ServerFailure(message: 'Stock must be greater than or equal to 0'),
        );
      }
    }

    // If validations pass, hand over to the Repository
    return await repository.createProduct(params.product);
  }
}

class CreateProductParams {
  final ProductInputEntity product;

  const CreateProductParams({required this.product});
}
