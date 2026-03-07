import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../models/product_input_model.dart';

abstract class AdminRemoteDataSource {
  /// Calls the createProduct GraphQL mutation.
  /// Throws a [ServerException] for all error codes.
  Future<String> createProduct(ProductInputModel product);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final GraphQLClient client;

  AdminRemoteDataSourceImpl({required this.client});

  @override
  Future<String> createProduct(ProductInputModel product) async {
    const String createProductMutation = r'''
      mutation CreateProduct($input: ProductInput!, $files: [Upload!]) {
        createProduct(input: $input, files: $files) {
          id
        }
      }
    ''';

    List<http.MultipartFile> multipartFiles = [];
    if (product.imageFiles != null && product.imageFiles!.isNotEmpty) {
      for (var file in product.imageFiles!) {
        final multipartFile = await http.MultipartFile.fromPath(
          '', // Field name is handled under the hood by graphql_flutter
          file.path,
        );
        multipartFiles.add(multipartFile);
      }
    }

    final options = MutationOptions(
      document: gql(createProductMutation),
      variables: {
        'input': product.toJson(),
        if (multipartFiles.isNotEmpty) 'files': multipartFiles,
      },
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      throw ServerException(message: result.exception.toString());
    }

    if (result.data != null && result.data!['createProduct'] != null) {
      // Assuming the backend returns the newly created product ID
      return result.data!['createProduct']['id'] as String;
    } else {
      throw ServerException(message: 'Invalid response from server');
    }
  }
}
