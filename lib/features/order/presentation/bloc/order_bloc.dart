import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/usecase.dart';
import '../../domain/usecases/checkout_usecase.dart';
import '../../domain/usecases/confirm_vnpay_usecase.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final CheckoutUseCase checkoutUseCase;
  final GetOrdersUseCase getOrdersUseCase;
  final ConfirmVnpayUseCase confirmVnpayUseCase;

  OrderBloc({
    required this.checkoutUseCase,
    required this.getOrdersUseCase,
    required this.confirmVnpayUseCase,
  }) : super(const OrderInitial()) {
    on<CheckoutEvent>(_onCheckout);
    on<GetOrdersEvent>(_onGetOrders);
    on<ConfirmVnpayEvent>(_onConfirmVnpay);
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

  Future<void> _onConfirmVnpay(
    ConfirmVnpayEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(const OrderLoading());

    final result = await confirmVnpayUseCase(
      ConfirmVnpayParams(returnUrl: event.returnUrl),
    );

    result.fold(
      (failure) =>
          emit(VnpayConfirmFailure(message: _mapFailureToMessage(failure))),
      (_) => emit(const VnpayConfirmSuccess()),
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
