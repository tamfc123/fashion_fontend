class AddressEntity {
  final String phone;
  final String street;
  final String district;
  final String city;

  const AddressEntity({
    required this.phone,
    required this.street,
    required this.district,
    required this.city,
  });

  /// Formatted string sent to backend CheckoutInput.shippingAddress
  String get shippingAddress => '$street, $district, $city';

  AddressEntity copyWith({
    String? phone,
    String? street,
    String? district,
    String? city,
  }) {
    return AddressEntity(
      phone: phone ?? this.phone,
      street: street ?? this.street,
      district: district ?? this.district,
      city: city ?? this.city,
    );
  }
}
