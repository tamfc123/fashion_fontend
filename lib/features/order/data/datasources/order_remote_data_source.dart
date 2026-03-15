import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import '../../../../core/error/exceptions.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> checkout({
    required String shippingAddress,
    required String phone,
    required String paymentMethod,
  });

  Future<List<OrderModel>> getOrders();
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final GraphQLClient client;

  OrderRemoteDataSourceImpl({required this.client});

  @override
  Future<OrderModel> checkout({
    required String shippingAddress,
    required String phone,
    required String paymentMethod,
  }) async {
    const String checkoutMutation = r'''
      mutation Checkout($input: CheckoutInput!) {
        checkout(input: $input) {
          id
          userId
          shippingAddress
          phone
          items {
            productId
            variantId
            productName
            size
            color
            quantity
            priceAtPurchase
          }
          totalAmount
          status
          paymentMethod
          paymentStatus
          paymentUrl
          createdAt
          updatedAt
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(checkoutMutation),
      variables: {
        'input': {
          'shippingAddress': shippingAddress,
          'phone': phone,
          'paymentMethod': paymentMethod,
        },
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw ServerException(
        message: (result.exception?.graphqlErrors.isNotEmpty ?? false)
            ? result.exception!.graphqlErrors.first.message
            : 'Failed to checkout',
      );
    }

    if (result.data?['checkout'] != null) {
      return OrderModel.fromJson(result.data!['checkout']);
    } else {
      throw ServerException(message: 'Failed to parse order checkout data');
    }
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    const String getOrdersQuery = r'''
      query GetOrders {
        getOrders {
          id
          userId
          shippingAddress
          phone
          items {
            productId
            variantId
            productName
            size
            color
            quantity
            priceAtPurchase
          }
          totalAmount
          status
          paymentMethod
          paymentStatus
          paymentUrl
          createdAt
          updatedAt
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(getOrdersQuery),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw ServerException(
        message: (result.exception?.graphqlErrors.isNotEmpty ?? false)
            ? result.exception!.graphqlErrors.first.message
            : 'Failed to fetch orders',
      );
    }

    if (result.data?['getOrders'] != null) {
      final List<dynamic> ordersJson = result.data!['getOrders'];
      return ordersJson.map((json) => OrderModel.fromJson(json)).toList();
    } else {
      return [];
    }
  }
}
