import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class GetProductsEvent extends ProductEvent {
  final int page;
  final int limit;
  final String? category;
  final String? search;
  final bool isRefresh;

  const GetProductsEvent({
    this.page = 1,
    this.limit = 10,
    this.category,
    this.search,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [page, limit, category, search, isRefresh];
}
