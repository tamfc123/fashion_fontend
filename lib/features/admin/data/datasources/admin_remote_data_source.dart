import 'dart:convert';
import 'dart:io';
import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/token_provider.dart';
import '../models/product_input_model.dart';

abstract class AdminRemoteDataSource {
  Future<List<String>> uploadImages(List<File> files);
  Future<String> createProduct(
    ProductInputModel product, {
    List<String>? imageUrls,
  });
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final GraphQLClient client;
  final TokenProvider tokenProvider;

  AdminRemoteDataSourceImpl({
    required this.client,
    required this.tokenProvider,
  });

  @override
  Future<List<String>> uploadImages(List<File> files) async {
    if (files.isEmpty) return [];

    final token = await tokenProvider.getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:5005/api/upload'),
    );

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    for (var file in files) {
      request.files.add(await http.MultipartFile.fromPath('images', file.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data['urls']);
    } else {
      throw ServerException(
        message:
            'Failed to upload images: ${response.statusCode} - ${response.body}',
      );
    }
  }

  @override
  Future<String> createProduct(
    ProductInputModel product, {
    List<String>? imageUrls,
  }) async {
    const String createProductMutation = r'''
      mutation CreateProduct($input: CreateProductInput!) {
        createProduct(input: $input) {
          id
        }
      }
    ''';

    final options = MutationOptions(
      document: gql(createProductMutation),
      variables: {'input': product.toJson(imageUrls: imageUrls)},
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      throw ServerException(message: result.exception.toString());
    }

    if (result.data != null && result.data!['createProduct'] != null) {
      return result.data!['createProduct']['id'] as String;
    } else {
      throw ServerException(message: 'Invalid response from server');
    }
  }
}
