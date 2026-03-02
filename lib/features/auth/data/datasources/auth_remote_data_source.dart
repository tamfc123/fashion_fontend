import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;

import '../../../../core/error/exceptions.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);
  Future<AuthResponseModel> register(
    String email,
    String password,
    String name,
  );
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final GraphQLClient client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    const String loginMutation = r'''
      mutation Login($email: String!, $password: String!) {
        login(email: $email, password: $password) {
          token
          user {
            id
            email
            name
          }
        }
      }
    ''';

    final options = MutationOptions(
      document: gql(loginMutation),
      variables: {'email': email, 'password': password},
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      throw ServerException(message: result.exception.toString());
    }

    if (result.data != null && result.data!['login'] != null) {
      return AuthResponseModel.fromJson(result.data!['login']);
    } else {
      throw ServerException(message: 'Invalid response from server');
    }
  }

  @override
  Future<AuthResponseModel> register(
    String email,
    String password,
    String name,
  ) async {
    const String registerMutation = r'''
      mutation Register($email: String!, $password: String!, $name: String!) {
        register(email: $email, password: $password, name: $name) {
          token
          user {
            id
            email
            name
          }
        }
      }
    ''';

    final options = MutationOptions(
      document: gql(registerMutation),
      variables: {'email': email, 'password': password, 'name': name},
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      throw ServerException(message: result.exception.toString());
    }

    if (result.data != null && result.data!['register'] != null) {
      return AuthResponseModel.fromJson(result.data!['register']);
    } else {
      throw ServerException(message: 'Invalid response from server');
    }
  }
}
