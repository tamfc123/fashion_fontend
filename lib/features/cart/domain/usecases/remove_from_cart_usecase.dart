import 'package:dartz/dartz.dart';
import 'package:fashion_ecommerce_app/core/utils/usecase.dart';

import '../../../../core/error/failures.dart';
import '../repositories/cart_repository.dart';

class RemoveFromCartUseCase implements UseCase<void, RemoveFromCartParams> {
  final CartRepository repository;

  RemoveFromCartUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveFromCartParams params) async {
    return await repository.removeFromCart(
      productId: params.productId,
      size: params.size,
      color: params.color,
    );
  }
}

class RemoveFromCartParams {
  final String productId;
  final String size;
  final String color;

  RemoveFromCartParams({
    required this.productId,
    required this.size,
    required this.color,
  });
}
