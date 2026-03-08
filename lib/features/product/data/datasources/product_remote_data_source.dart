import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int limit = 10,
    String? category,
    String? search,
  });

  Future<ProductModel> getProductDetails(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final GraphQLClient client;

  ProductRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int limit = 10,
    String? category,
    String? search,
  }) async {
    const String getProductsQuery = r'''
      query GetProducts($pagination: PaginationInput, $filter: ProductFilterInput) {
        getProducts(pagination: $pagination, filter: $filter) {
          data {
            id
            name
            description
            category
            images
            variants {
              id
              color
              size
              price
              stock
            }
          }
          totalItems
          totalPages
          currentPage
        }
      }
    ''';

    final Map<String, dynamic> pagination = {'page': page, 'limit': limit};

    final Map<String, dynamic> filter = {};
    if (category != null && category.isNotEmpty) {
      filter['category'] = category;
    }
    if (search != null && search.isNotEmpty) {
      filter['search'] = search;
    }

    final options = QueryOptions(
      document: gql(getProductsQuery),
      variables: {
        'pagination': pagination,
        if (filter.isNotEmpty) 'filter': filter,
      },
      fetchPolicy: FetchPolicy.networkOnly, // Always fetch fresh feed
    );

    final result = await client.query(options);

    if (result.hasException) {
      throw ServerException(message: result.exception.toString());
    }

    if (result.data != null && result.data!['getProducts'] != null) {
      final dataList = result.data!['getProducts']['data'] as List;
      return dataList
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw ServerException(message: 'Invalid response from server');
    }
  }

  @override
  Future<ProductModel> getProductDetails(String id) async {
    const String getProductQuery = r'''
      query GetProductById($id: ID!) {
        getProductById(id: $id) {
          id
          name
          description
          category
          images
          variants {
            id
            color
            size
            price
            stock
          }
        }
      }
    ''';

    final options = QueryOptions(
      document: gql(getProductQuery),
      variables: {'id': id},
      fetchPolicy: FetchPolicy.networkOnly, // Get fresh details
    );

    final result = await client.query(options);

    if (result.hasException) {
      throw ServerException(message: result.exception.toString());
    }

    if (result.data != null && result.data!['getProductById'] != null) {
      return ProductModel.fromJson(
        result.data!['getProductById'] as Map<String, dynamic>,
      );
    } else {
      throw ServerException(message: 'Product not found');
    }
  }
}
