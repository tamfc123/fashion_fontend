import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<void> saveCart(List<CartItemModel> cart);
  Future<List<CartItemModel>> getCart();
  Future<void> clearCart();
}

const cachedCart = 'CACHED_CART';

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final SharedPreferences sharedPreferences;

  CartLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveCart(List<CartItemModel> cart) {
    if (cart.isEmpty) {
      return sharedPreferences.remove(cachedCart);
    }
    final List<Map<String, dynamic>> cartMap = cart
        .map((item) => item.toJson())
        .toList();
    final String cartJson = json.encode(cartMap);
    return sharedPreferences.setString(cachedCart, cartJson);
  }

  @override
  Future<List<CartItemModel>> getCart() {
    final jsonString = sharedPreferences.getString(cachedCart);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      final List<CartItemModel> cart = jsonList
          .map((item) => CartItemModel.fromJson(item))
          .toList();
      return Future.value(cart);
    } else {
      return Future.value([]);
    }
  }

  @override
  Future<void> clearCart() {
    return sharedPreferences.remove(cachedCart);
  }
}
