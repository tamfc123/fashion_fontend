import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_products.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;

  ProductBloc({required this.getProductsUseCase}) : super(ProductInitial()) {
    on<GetProductsEvent>(_onGetProducts);
  }

  Future<void> _onGetProducts(
    GetProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    // Only show loading state if it is not a silent background refresh
    if (!event.isRefresh) {
      emit(ProductLoading());
    }

    final result = await getProductsUseCase(
      GetProductsParams(
        page: event.page,
        limit: event.limit,
        category: event.category,
        search: event.search,
      ),
    );

    result.fold(
      (failure) => emit(ProductError(message: _mapFailureToMessage(failure))),
      (products) => emit(ProductLoaded(products: products)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return failure.message;
    if (failure is AuthFailure) return failure.message;
    if (failure is CacheFailure) return failure.message;
    return 'Unexpected Error';
  }
}
