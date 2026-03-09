import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const RegisterEvent({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

class LogoutEvent extends AuthEvent {}

class GetCurrentUserEvent extends AuthEvent {}

class UpdateProfileEvent extends AuthEvent {
  final String name;
  final String? phone;
  final String? street;
  final String? district;
  final String? city;

  const UpdateProfileEvent({
    required this.name,
    this.phone,
    this.street,
    this.district,
    this.city,
  });

  @override
  List<Object?> get props => [name, phone, street, district, city];
}
