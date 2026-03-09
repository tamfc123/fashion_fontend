import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/error/failures.dart';
import '../models/cart_item_model.dart';

abstract class CartRemoteDataSource {
  Future<void> addToCart(CartItemModel item);
  Future<List<CartItemModel>> getCart();
  Future<void> updateCartItem(
    String productId,
    String variantId,
    String size,
    String color,
    int quantity,
  );
  Future<void> removeFromCart(
    String productId,
    String variantId,
    String size,
    String color,
  );
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final GraphQLClient client;

  CartRemoteDataSourceImpl({required this.client});

  @override
  Future<void> addToCart(CartItemModel item) async {
    const String mutation = r'''
      mutation AddToCart($input: AddToCartInput!) {
        addToCart(input: $input) {
          id
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'input': {
          'productId': item.productId,
          'variantId': item.variantId,
          'quantity': item.quantity,
        },
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw ServerFailure(
        message: result.exception?.graphqlErrors.isNotEmpty == true
            ? result.exception!.graphqlErrors.first.message
            : 'Failed to add to cart on server',
      );
    }
  }

  @override
  Future<List<CartItemModel>> getCart() async {
    const String query = r'''
      query GetMyCart {
        getMyCart {
          id
          items {
            productId
            variantId
            quantity
            product {
              id
              name
              images
            }
            variant {
              id
              color
              size
              price
            }
          }
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(query),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw ServerFailure(message: 'Failed to fetch cart from server');
    }

    final List<dynamic> itemsData = result.data?['getMyCart']?['items'] ?? [];
    return itemsData.map((item) {
      final product = item['product'];
      final variant = item['variant'];
      return CartItemModel(
        productId: item['productId'],
        variantId: item['variantId'],
        name: product['name'],
        price: (variant['price'] as num).toDouble(),
        imageUrl: (product['images'] as List).isNotEmpty
            ? product['images'][0]
            : '',
        color: variant['color'] ?? '',
        size: variant['size'] ?? '',
        quantity: item['quantity'] ?? 1,
      );
    }).toList();
  }

  @override
  Future<void> updateCartItem(
    String productId,
    String variantId,
    String size,
    String color,
    int quantity,
  ) async {
    const String mutation = r'''
      mutation UpdateCartItemQuantity($input: UpdateCartItemInput!) {
        updateCartItemQuantity(input: $input) {
          id
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'input': {
          'productId': productId,
          'variantId': variantId,
          'quantity': quantity,
        },
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw ServerFailure(message: 'Failed to update cart item');
    }
  }

  @override
  Future<void> removeFromCart(
    String productId,
    String variantId,
    String size,
    String color,
  ) async {
    const String mutation = r'''
      mutation RemoveFromCart($productId: ID!, $variantId: ID!) {
        removeFromCart(productId: $productId, variantId: $variantId) {
          id
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {'productId': productId, 'variantId': variantId},
    );
    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw ServerFailure(message: 'Failed to remove item from cart');
    }
  }
}
