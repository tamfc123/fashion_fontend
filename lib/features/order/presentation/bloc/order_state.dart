import 'package:equatable/equatable.dart';

import '../../domain/entities/order.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object> get props => [];
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class CheckoutSuccess extends OrderState {
  final OrderEntity order;

  const CheckoutSuccess({required this.order});

  @override
  List<Object> get props => [order];
}

class OrderError extends OrderState {
  final String message;

  const OrderError({required this.message});

  @override
  List<Object> get props => [message];
}

class OrderHistoryLoaded extends OrderState {
  final List<OrderEntity> orders;

  const OrderHistoryLoaded({required this.orders});

  @override
  List<Object> get props => [orders];
}

class VnpayConfirmSuccess extends OrderState {
  const VnpayConfirmSuccess();
}

class VnpayConfirmFailure extends OrderState {
  final String message;

  const VnpayConfirmFailure({required this.message});

  @override
  List<Object> get props => [message];
}
