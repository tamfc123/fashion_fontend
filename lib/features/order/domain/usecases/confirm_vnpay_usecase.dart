import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/order_repository.dart';

class ConfirmVnpayUseCase implements UseCase<void, ConfirmVnpayParams> {
  final OrderRepository repository;

  ConfirmVnpayUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ConfirmVnpayParams params) {
    return repository.confirmVnpayReturn(params.returnUrl);
  }
}

class ConfirmVnpayParams extends Equatable {
  final String returnUrl;

  const ConfirmVnpayParams({required this.returnUrl});

  @override
  List<Object> get props => [returnUrl];
}
