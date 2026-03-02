import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();

  @override
  List<Object> get props => [];
}

class ServerFailure extends Failure {
  final String message;

  const ServerFailure({this.message = 'Server Error'});

  @override
  List<Object> get props => [message];
}

class AuthFailure extends Failure {
  final String message;

  const AuthFailure({this.message = 'Authentication Error'});

  @override
  List<Object> get props => [message];
}

class NetworkFailure extends Failure {
  final String message;

  const NetworkFailure({this.message = 'No Internet Connection'});

  @override
  List<Object> get props => [message];
}

class CacheFailure extends Failure {
  final String message;

  const CacheFailure({this.message = 'Cache Error'});

  @override
  List<Object> get props => [message];
}
