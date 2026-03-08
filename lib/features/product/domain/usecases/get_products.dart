import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fashion_ecommerce_app/core/utils/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase
    implements UseCase<List<ProductEntity>, GetProductsParams> {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(GetProductsParams params) {
    return repository.getProducts(
      page: params.page,
      limit: params.limit,
      category: params.category,
      search: params.search,
    );
  }
}

class GetProductsParams extends Equatable {
  final int page;
  final int limit;
  final String? category;
  final String? search;

  const GetProductsParams({
    this.page = 1,
    this.limit = 10,
    this.category,
    this.search,
  });

  @override
  List<Object?> get props => [page, limit, category, search];
}
