import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? phone;
  final String? street;
  final String? district;
  final String? city;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.street,
    this.district,
    this.city,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    role,
    phone,
    street,
    district,
    city,
    createdAt,
    updatedAt,
  ];
}
