import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product_input_entity.dart';
import '../../domain/repositories/admin_product_repository.dart';
import '../datasources/admin_remote_data_source.dart';
import '../models/product_input_model.dart';
import '../models/variant_input_model.dart';

class AdminProductRepositoryImpl implements AdminProductRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> createProduct(
    ProductInputEntity productEntity,
  ) async {
    try {
      // 1. Upload Images to REST API
      List<String> imageUrls = [];
      if (productEntity.imageFiles != null &&
          productEntity.imageFiles!.isNotEmpty) {
        imageUrls = await remoteDataSource.uploadImages(
          productEntity.imageFiles!,
        );
      }

      // 2. Map Entity -> Model for GraphQL Data Source
      final productModel = ProductInputModel(
        name: productEntity.name,
        description: productEntity.description,
        category: productEntity.category,
        imageFiles: productEntity.imageFiles,
        variants: productEntity.variants
            .map(
              (v) => VariantInputModel(
                color: v.color,
                size: v.size,
                price: v.price,
                stock: v.stock,
              ),
            )
            .toList(),
      );

      // 3. Execute GraphQL Mutation linking the stored Image URLs
      final productId = await remoteDataSource.createProduct(
        productModel,
        imageUrls: imageUrls,
      );

      return Right(productId);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Unexpected error occurred: ${e.toString()}'),
      );
    }
  }
}
