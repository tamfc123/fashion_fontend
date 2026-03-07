import 'package:equatable/equatable.dart';

import '../../domain/entities/product_input_entity.dart';

abstract class AddProductEvent extends Equatable {
  const AddProductEvent();

  @override
  List<Object?> get props => [];
}

class AddProductSubmitted extends AddProductEvent {
  final ProductInputEntity product;

  const AddProductSubmitted(this.product);

  @override
  List<Object?> get props => [product];
}
