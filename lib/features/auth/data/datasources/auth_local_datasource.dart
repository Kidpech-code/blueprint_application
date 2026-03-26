import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/auth_models.dart';

abstract class AuthLocalDataSource {
  Future<AuthTokenModel?> getStoredToken();
  Future<void> storeToken(AuthTokenModel token);
  Future<void> clearAuthData();
  Future<UserModel?> getStoredUser();
  Future<void> storeUser(UserModel user);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  AuthLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<AuthTokenModel?> getStoredToken() async {
    try {
      final tokenJson = sharedPreferences.getString(_tokenKey);
      if (tokenJson != null) {
        final tokenMap = json.decode(tokenJson) as Map<String, dynamic>;
        return AuthTokenModel.fromJson(tokenMap);
      }
      return null;
    } catch (e) {
      // If there's an error parsing the token, clear it
      await sharedPreferences.remove(_tokenKey);
      return null;
    }
  }

  @override
  Future<void> storeToken(AuthTokenModel token) async {
    final tokenJson = json.encode(token.toJson());
    await sharedPreferences.setString(_tokenKey, tokenJson);
  }

  @override
  Future<UserModel?> getStoredUser() async {
    try {
      final userJson = sharedPreferences.getString(_userKey);
      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }
      return null;
    } catch (e) {
      // If there's an error parsing the user, clear it
      await sharedPreferences.remove(_userKey);
      return null;
    }
  }

  @override
  Future<void> storeUser(UserModel user) async {
    final userJson = json.encode(user.toJson());
    await sharedPreferences.setString(_userKey, userJson);
  }

  @override
  Future<void> clearAuthData() async {
    await Future.wait([
      sharedPreferences.remove(_tokenKey),
      sharedPreferences.remove(_userKey),
    ]);
  }
}
