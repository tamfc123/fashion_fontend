import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class CheckoutParams extends Equatable {
  final String shippingAddress;
  final String phone;
  final String paymentMethod;

  const CheckoutParams({
    required this.shippingAddress,
    required this.phone,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [shippingAddress, phone, paymentMethod];
}

class CheckoutUseCase implements UseCase<OrderEntity, CheckoutParams> {
  final OrderRepository repository;

  CheckoutUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(CheckoutParams params) async {
    return await repository.checkout(
      shippingAddress: params.shippingAddress,
      phone: params.phone,
      paymentMethod: params.paymentMethod,
    );
  }
}
