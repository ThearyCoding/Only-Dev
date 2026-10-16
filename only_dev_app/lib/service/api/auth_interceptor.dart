import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  static const String tokenKey = 'jwt_access_token';
  static const String refreshTokenKey = 'jwt_refresh_token';

  final SharedPreferences _prefs;

  AuthInterceptor(this._prefs);

  String? get token => _prefs.getString(tokenKey);
  String? get refreshToken => _prefs.getString(refreshTokenKey);

  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    await _prefs.setString(tokenKey, accessToken);
    if (refreshToken != null) {
      await _prefs.setString(refreshTokenKey, refreshToken);
    }
  }

  Future<void> clearTokens() async {
    await _prefs.remove(tokenKey);
    await _prefs.remove(refreshTokenKey);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final currentToken = token;
    if (currentToken != null && currentToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $currentToken';
    }
    return super.onRequest(options, handler);
  }
}

