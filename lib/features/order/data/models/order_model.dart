import '../../domain/entities/order.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.userId,
    super.shippingAddress,
    super.phone,
    required super.items,
    required super.totalAmount,
    required super.status,
    required super.paymentMethod,
    required super.paymentStatus,
    super.paymentUrl,
    required super.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['userId'],
      shippingAddress: json['shippingAddress'],
      phone: json['phone'],
      items: (json['items'] as List)
          .map((i) => OrderItemModel.fromJson(i))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      paymentUrl: json['paymentUrl'],
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    final str = dateValue.toString();
    if (str.length > 10 && !str.contains('-')) {
      final ms = int.tryParse(str);
      if (ms != null) {
        return DateTime.fromMillisecondsSinceEpoch(ms);
      }
    }
    return DateTime.parse(str);
  }
}

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.productId,
    required super.variantId,
    required super.productName,
    required super.size,
    required super.color,
    required super.quantity,
    required super.priceAtPurchase,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId'],
      variantId: json['variantId'],
      productName: json['productName'],
      size: json['size'],
      color: json['color'],
      quantity: json['quantity'] as int,
      priceAtPurchase: (json['priceAtPurchase'] as num).toDouble(),
    );
  }
}
