import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  static const _baseUrl = 'https://cityvoice-api.onrender.com/api/v1';
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  final _storage = const FlutterSecureStorage();

  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  Future<String?> getValidAccessToken() async {
    String? token = await _storage.read(key: _accessKey);
    if (token == null || JwtDecoder.isExpired(token)) {
      await _refreshAccessToken();
      token = await _storage.read(key: _accessKey);
    }
    return token;
  }

  Future<void> _refreshAccessToken() async {
    final refresh = await _storage.read(key: _refreshKey);
    if (refresh == null || JwtDecoder.isExpired(refresh)) {
      throw Exception('Refresh token expired');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/token/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refresh}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: _accessKey, value: data['access']);
    } else {
      throw Exception('Failed to refresh access token');
    }
  }

  Future<bool> isLoggedIn() async {
    final refresh = await _storage.read(key: _refreshKey);
    return refresh != null && !JwtDecoder.isExpired(refresh);
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<http.Response> authorizedGet(String endpoint) async {
    final token = await getValidAccessToken();
    return http.get(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<http.Response> authorizedPost(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await getValidAccessToken();
    return http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  Future<String?> getUsername() async {
    final token = await getValidAccessToken();
    if (token != null) {
      final decoded = JwtDecoder.decode(token);
      return "${decoded['first_name']} ${decoded['last_name']}";
    }
    return null;
  }

  Future<bool> isStaff() async {
    final token = await getValidAccessToken();
    if (token == null) return false;
    final decoded = JwtDecoder.decode(token);
    return decoded['is_staff'] == true;
  }
}
