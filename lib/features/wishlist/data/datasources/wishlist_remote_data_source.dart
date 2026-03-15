import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import '../../../../core/error/exceptions.dart';
import '../../../product/data/models/product_model.dart';

abstract class WishlistRemoteDataSource {
  Future<List<ProductModel>> getWishlist();
  Future<List<String>> toggleWishlist(String productId);
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final GraphQLClient client;

  WishlistRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ProductModel>> getWishlist() async {
    const String getWishlistQuery = r'''
      query GetWishlist {
        getWishlist {
          id
          name
          description
          category
          images
          variants {
            id
            size
            color
            price
            stock
          }
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(getWishlistQuery),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw ServerException(
        message: (result.exception?.graphqlErrors.isNotEmpty ?? false)
            ? result.exception!.graphqlErrors.first.message
            : 'Failed to fetch wishlist',
      );
    }

    if (result.data?['getWishlist'] != null) {
      final List<dynamic> jsonList = result.data!['getWishlist'];
      return jsonList.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  @override
  Future<List<String>> toggleWishlist(String productId) async {
    const String toggleWishlistMutation = r'''
      mutation ToggleWishlist($productId: ID!) {
        toggleWishlist(productId: $productId)
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(toggleWishlistMutation),
      variables: {
        'productId': productId,
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw ServerException(
        message: (result.exception?.graphqlErrors.isNotEmpty ?? false)
            ? result.exception!.graphqlErrors.first.message
            : 'Failed to toggle wishlist',
      );
    }

    if (result.data?['toggleWishlist'] != null) {
      final List<dynamic> jsonList = result.data!['toggleWishlist'];
      return jsonList.map((e) => e.toString()).toList();
    } else {
      throw ServerException(message: 'Failed to parse toggle wishlist response');
    }
  }
}
