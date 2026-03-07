import 'package:equatable/equatable.dart';

class VariantInputEntity extends Equatable {
  final String? color;
  final String? size;
  final double price;
  final int stock;

  const VariantInputEntity({
    this.color,
    this.size,
    required this.price,
    required this.stock,
  });

  @override
  List<Object?> get props => [color, size, price, stock];
}
