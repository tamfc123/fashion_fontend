import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/usecase.dart';
import '../../domain/usecases/checkout_usecase.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final CheckoutUseCase checkoutUseCase;
  final GetOrdersUseCase getOrdersUseCase;

  OrderBloc({
    required this.checkoutUseCase,
    required this.getOrdersUseCase,
  }) : super(const OrderInitial()) {
    on<CheckoutEvent>(_onCheckout);
    on<GetOrdersEvent>(_onGetOrders);
  }

  Future<void> _onCheckout(
    CheckoutEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(const OrderLoading());

    final failureOrOrder = await checkoutUseCase(
      CheckoutParams(
        shippingAddress: event.shippingAddress,
        phone: event.phone,
        paymentMethod: event.paymentMethod,
      ),
    );

    failureOrOrder.fold(
      (failure) => emit(OrderError(message: _mapFailureToMessage(failure))),
      (order) => emit(CheckoutSuccess(order: order)),
    );
  }

  Future<void> _onGetOrders(
    GetOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(const OrderLoading());

    final failureOrOrders = await getOrdersUseCase(NoParams());

    failureOrOrders.fold(
      (failure) => emit(OrderError(message: _mapFailureToMessage(failure))),
      (orders) => emit(OrderHistoryLoaded(orders: orders)),
    );
  }

  String _mapFailureToMessage(dynamic failure) {
    try {
      return failure.message as String;
    } catch (e) {
      return 'Unexpected error occurred.';
    }
  }
}
