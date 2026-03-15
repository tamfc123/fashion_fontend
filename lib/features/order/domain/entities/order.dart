import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {
  final String id;
  final String userId;
  final String? shippingAddress;
  final String? phone;
  final List<OrderItemEntity> items;
  final double totalAmount;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final String? paymentUrl;
  final DateTime createdAt;

  const OrderEntity({
    required this.id,
    required this.userId,
    this.shippingAddress,
    this.phone,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    this.paymentUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    shippingAddress,
    phone,
    items,
    totalAmount,
    status,
    paymentMethod,
    paymentStatus,
    paymentUrl,
    createdAt,
  ];
}

class OrderItemEntity extends Equatable {
  final String productId;
  final String variantId;
  final String productName;
  final String size;
  final String color;
  final int quantity;
  final double priceAtPurchase;

  const OrderItemEntity({
    required this.productId,
    required this.variantId,
    required this.productName,
    required this.size,
    required this.color,
    required this.quantity,
    required this.priceAtPurchase,
  });

  @override
  List<Object?> get props => [
    productId,
    variantId,
    productName,
    size,
    color,
    quantity,
    priceAtPurchase,
  ];
}
