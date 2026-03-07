import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_product_usecase.dart';
import 'add_product_event.dart';
import 'add_product_state.dart';

class AddProductBloc extends Bloc<AddProductEvent, AddProductState> {
  final CreateProductUseCase createProductUseCase;

  AddProductBloc({required this.createProductUseCase})
    : super(AddProductInitial()) {
    on<AddProductSubmitted>(_onAddProductSubmitted);
  }

  Future<void> _onAddProductSubmitted(
    AddProductSubmitted event,
    Emitter<AddProductState> emit,
  ) async {
    emit(AddProductLoading());

    final failureOrSuccess = await createProductUseCase(
      CreateProductParams(product: event.product),
    );

    failureOrSuccess.fold((failure) {
      // Retrieve internal failure message if available
      String message = 'Unexpected error occurred.';
      try {
        message = (failure as dynamic).message as String;
      } catch (_) {}
      emit(AddProductError(message: message));
    }, (productId) => emit(AddProductSuccess(productId: productId)));
  }
}
