import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_product_details.dart';
import 'product_detail_event.dart';
import 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final GetProductDetailsUseCase getProductDetailsUseCase;

  ProductDetailBloc({required this.getProductDetailsUseCase})
    : super(ProductDetailInitial()) {
    on<GetProductDetailEvent>(_onGetProductDetail);
    on<SelectVariantEvent>(_onSelectVariant);
  }

  Future<void> _onGetProductDetail(
    GetProductDetailEvent event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(ProductDetailLoading());

    final result = await getProductDetailsUseCase(event.productId);

    result.fold(
      (failure) =>
          emit(ProductDetailError(message: _mapFailureToMessage(failure))),
      (product) {
        // Auto-select the first variant if available
        final defaultVariant = product.variants.isNotEmpty
            ? product.variants.first
            : null;
        emit(
          ProductDetailLoaded(
            product: product,
            selectedVariant: defaultVariant,
          ),
        );
      },
    );
  }

  void _onSelectVariant(
    SelectVariantEvent event,
    Emitter<ProductDetailState> emit,
  ) {
    if (state is ProductDetailLoaded) {
      final currentState = state as ProductDetailLoaded;
      emit(currentState.copyWith(selectedVariant: event.variant));
    }
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return failure.message;
    if (failure is AuthFailure) return failure.message;
    if (failure is CacheFailure) return failure.message;
    return 'Unexpected Error';
  }
}
