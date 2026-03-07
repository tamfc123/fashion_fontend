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
      // Map Entity -> Model for GraphQL Data Source
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

      final productId = await remoteDataSource.createProduct(productModel);
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
