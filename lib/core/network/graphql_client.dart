import 'package:graphql_flutter/graphql_flutter.dart';
import 'token_provider.dart';

class GraphQLConfig {
  static const String endpoint = 'https://your-graphql-endpoint.com/graphql';

  static GraphQLClient getClient(TokenProvider tokenProvider) {
    final HttpLink httpLink = HttpLink(endpoint);
    final AuthLink authLink = AuthLink(
      getToken: () async {
        final token = await tokenProvider.getToken();
        return token != null ? 'Bearer $token' : null;
      },
    );
    final Link link = authLink.concat(httpLink);

    return GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );
  }
}
