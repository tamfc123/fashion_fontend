import 'package:equatable/equatable.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object> get props => [];
}

class CheckoutEvent extends OrderEvent {
  final String shippingAddress;
  final String phone;
  final String paymentMethod;

  const CheckoutEvent({
    required this.shippingAddress,
    required this.phone,
    required this.paymentMethod,
  });

  @override
  List<Object> get props => [shippingAddress, phone, paymentMethod];
}

class GetOrdersEvent extends OrderEvent {
  const GetOrdersEvent();
}

class ConfirmVnpayEvent extends OrderEvent {
  final String returnUrl;

  const ConfirmVnpayEvent({required this.returnUrl});

  @override
  List<Object> get props => [returnUrl];
}
