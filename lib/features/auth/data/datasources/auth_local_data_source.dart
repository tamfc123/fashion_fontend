import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/token_provider.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource implements TokenProvider {
  Future<void> cacheToken(String token);
  Future<void> cacheUser(UserModel user);
  Future<UserModel> getCachedUser();
  Future<void> clearCache();
}

const cachedUserKey = 'CACHED_USER';
const tokenKey = 'AUTH_TOKEN';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  @override
  Future<String?> getToken() async {
    return sharedPreferences.getString(tokenKey);
  }

  @override
  Future<void> cacheToken(String token) async {
    await sharedPreferences.setString(tokenKey, token);
  }

  @override
  Future<UserModel> getCachedUser() {
    final jsonString = sharedPreferences.getString(cachedUserKey);
    if (jsonString != null) {
      return Future.value(UserModel.fromJson(json.decode(jsonString)));
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheUser(UserModel user) {
    return sharedPreferences.setString(
      cachedUserKey,
      json.encode(user.toJson()),
    );
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(tokenKey);
    await sharedPreferences.remove(cachedUserKey);
  }
}
