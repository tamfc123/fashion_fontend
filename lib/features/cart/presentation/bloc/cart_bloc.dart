import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fashion_ecommerce_app/core/utils/usecase.dart';
import '../../data/datasources/cart_local_data_source.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/get_cart_items_usecase.dart';
import '../../domain/usecases/update_cart_item_usecase.dart';
import '../../domain/usecases/remove_from_cart_usecase.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final AddToCartUseCase addToCartUseCase;
  final GetCartItemsUseCase getCartItemsUseCase;
  final UpdateCartItemUseCase updateCartItemUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final CartLocalDataSource cartLocalDataSource;

  CartBloc({
    required this.addToCartUseCase,
    required this.getCartItemsUseCase,
    required this.updateCartItemUseCase,
    required this.removeFromCartUseCase,
    required this.cartLocalDataSource,
  }) : super(const CartInitial()) {
    on<AddToCartEvent>(_onAddToCart);
    on<GetCartEvent>(_onGetCart);
    on<UpdateCartItemQuantityEvent>(_onUpdateQuantity);
    on<RemoveCartItemEvent>(_onRemoveItem);
    on<ClearCartEvent>(_onClearCart);
  }

  Future<void> _onAddToCart(
    AddToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    final result = await addToCartUseCase(AddToCartParams(item: event.item));

    result.fold(
      (failure) => emit(
        CartError(
          failure.message,
          itemCount: state.itemCount,
          items: state.items,
        ),
      ),
      (_) {
        // After adding, we trigger a refresh to get the latest list and count
        add(const GetCartEvent());
      },
    );
  }

  Future<void> _onGetCart(GetCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoading(itemCount: state.itemCount, items: state.items));

    final result = await getCartItemsUseCase(NoParams());

    result.fold(
      (failure) => emit(
        CartError(
          failure.message,
          itemCount: state.itemCount,
          items: state.items,
        ),
      ),
      (items) => emit(CartSuccess(itemCount: items.length, items: items)),
    );
  }

  Future<void> _onUpdateQuantity(
    UpdateCartItemQuantityEvent event,
    Emitter<CartState> emit,
  ) async {
    // No full loading state for smooth UI if possible, or just local update first
    final result = await updateCartItemUseCase(
      UpdateCartItemParams(
        productId: event.productId,
        size: event.size,
        color: event.color,
        quantity: event.quantity,
      ),
    );

    result.fold(
      (failure) => emit(
        CartError(
          failure.message,
          itemCount: state.itemCount,
          items: state.items,
        ),
      ),
      (_) => add(const GetCartEvent()),
    );
  }

  Future<void> _onRemoveItem(
    RemoveCartItemEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading(itemCount: state.itemCount, items: state.items));

    final result = await removeFromCartUseCase(
      RemoveFromCartParams(
        productId: event.productId,
        size: event.size,
        color: event.color,
      ),
    );

    result.fold(
      (failure) => emit(
        CartError(
          failure.message,
          itemCount: state.itemCount,
          items: state.items,
        ),
      ),
      (_) => add(const GetCartEvent()),
    );
  }

  Future<void> _onClearCart(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) async {
    await cartLocalDataSource.clearCart();
    emit(const CartInitial());
  }
}
