import 'package:dartz/dartz.dart';
import 'package:fashion_ecommerce_app/core/utils/usecase.dart';

import '../../../../core/error/failures.dart';
import '../repositories/cart_repository.dart';

class UpdateCartItemUseCase implements UseCase<void, UpdateCartItemParams> {
  final CartRepository repository;

  UpdateCartItemUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateCartItemParams params) async {
    return await repository.updateCartItem(
      productId: params.productId,
      size: params.size,
      color: params.color,
      quantity: params.quantity,
    );
  }
}

class UpdateCartItemParams {
  final String productId;
  final String size;
  final String color;
  final int quantity;

  UpdateCartItemParams({
    required this.productId,
    required this.size,
    required this.color,
    required this.quantity,
  });
}
