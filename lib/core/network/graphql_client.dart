import 'package:graphql_flutter/graphql_flutter.dart';
import 'token_provider.dart';

class GraphQLConfig {
  static const String endpoint = 'http://localhost:5005/graphql';

  static GraphQLClient getClient(TokenProvider tokenProvider) {
    final HttpLink httpLink = HttpLink(
      endpoint,
      defaultHeaders: {
        'ngrok-skip-browser-warning': 'true', // Dòng này cực kỳ quan trọng
      },
    );
    final AuthLink authLink = AuthLink(
      getToken: () async {
        final token = await tokenProvider.getToken();
        return token != null ? 'Bearer $token' : null;
      },
    );
    final Link link = authLink.concat(httpLink);

    return GraphQLClient(cache: GraphQLCache(), link: link);
  }
}
