import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/order.dart';

abstract class OrderRepository {
  Future<Either<Failure, OrderEntity>> checkout({
    required String shippingAddress,
    required String phone,
    required String paymentMethod,
  });

  Future<Either<Failure, List<OrderEntity>>> getOrders();

  Future<Either<Failure, void>> confirmVnpayReturn(String returnUrl);
}
