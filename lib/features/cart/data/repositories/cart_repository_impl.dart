import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';
import '../datasources/cart_remote_data_source.dart';
import '../models/cart_item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;
  final CartLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final SharedPreferences sharedPreferences;

  CartRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.sharedPreferences,
  });

  @override
  Future<Either<Failure, void>> addToCart(CartItemEntity item) async {
    try {
      final String? token = sharedPreferences.getString('TOKEN');
      final CartItemModel itemModel = CartItemModel.fromEntity(item);

      if (token != null && token.isNotEmpty) {
        // User is logged in, sync to server
        if (await networkInfo.isConnected) {
          try {
            await remoteDataSource.addToCart(itemModel);
            return const Right(null);
          } catch (e) {
            return Left(ServerFailure(message: e.toString()));
          }
        } else {
          return const Left(NetworkFailure(message: 'No internet connection'));
        }
      } else {
        // User is NOT logged in, save to local storage
        final List<CartItemModel> currentCart = await localDataSource.getCart();

        // Check if item already exists, if so, increase quantity
        final existingIndex = currentCart.indexWhere(
          (element) =>
              element.productId == item.productId &&
              element.size == item.size &&
              element.color == item.color,
        );

        if (existingIndex >= 0) {
          final existingItem = currentCart[existingIndex];
          currentCart[existingIndex] = CartItemModel(
            productId: existingItem.productId,
            name: existingItem.name,
            price: existingItem.price,
            imageUrl: existingItem.imageUrl,
            color: existingItem.color,
            size: existingItem.size,
            quantity: existingItem.quantity + item.quantity,
          );
        } else {
          currentCart.add(itemModel);
        }

        await localDataSource.saveCart(currentCart);
        return const Right(null);
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CartItemEntity>>> getCartItems() async {
    try {
      final String? token = sharedPreferences.getString('TOKEN');
      if (token != null && token.isNotEmpty) {
        if (await networkInfo.isConnected) {
          final List<CartItemModel> models = await remoteDataSource.getCart();
          return Right(models.map((e) => e.toEntity()).toList());
        } else {
          return const Left(NetworkFailure(message: 'No internet connection'));
        }
      } else {
        final List<CartItemModel> models = await localDataSource.getCart();
        return Right(models.map((e) => e.toEntity()).toList());
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart({
    required String productId,
    required String size,
    required String color,
  }) async {
    try {
      final String? token = sharedPreferences.getString('TOKEN');
      if (token != null && token.isNotEmpty) {
        if (await networkInfo.isConnected) {
          await remoteDataSource.removeFromCart(productId, size, color);
          return const Right(null);
        } else {
          return const Left(NetworkFailure(message: 'No internet connection'));
        }
      } else {
        final List<CartItemModel> currentCart = await localDataSource.getCart();
        currentCart.removeWhere(
          (item) =>
              item.productId == productId &&
              item.size == size &&
              item.color == color,
        );
        await localDataSource.saveCart(currentCart);
        return const Right(null);
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCartItem({
    required String productId,
    required String size,
    required String color,
    required int quantity,
  }) async {
    try {
      final String? token = sharedPreferences.getString('TOKEN');
      if (token != null && token.isNotEmpty) {
        if (await networkInfo.isConnected) {
          await remoteDataSource.updateCartItem(
            productId,
            size,
            color,
            quantity,
          );
          return const Right(null);
        } else {
          return const Left(NetworkFailure(message: 'No internet connection'));
        }
      } else {
        final List<CartItemModel> currentCart = await localDataSource.getCart();
        final index = currentCart.indexWhere(
          (item) =>
              item.productId == productId &&
              item.size == size &&
              item.color == color,
        );

        if (index >= 0) {
          final existingItem = currentCart[index];
          currentCart[index] = CartItemModel(
            productId: existingItem.productId,
            name: existingItem.name,
            price: existingItem.price,
            imageUrl: existingItem.imageUrl,
            color: existingItem.color,
            size: existingItem.size,
            quantity: quantity,
          );
          await localDataSource.saveCart(currentCart);
        }
        return const Right(null);
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
