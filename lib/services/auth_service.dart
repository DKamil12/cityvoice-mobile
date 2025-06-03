import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

/// Сервис для работы с аутентификацией и хранением токенов
class AuthService {
  static const _baseUrl = 'https://cityvoice-api.onrender.com/api/v1';
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  // Безопасное хранилище для токенов
  final _storage = const FlutterSecureStorage();

  /// Сохраняет access и refresh токены в безопасном хранилище
  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  /// Возвращает действительный access-токен (автоматически обновляет, если устарел)
  Future<String?> getValidAccessToken() async {
    String? token = await _storage.read(key: _accessKey);
    if (token == null || JwtDecoder.isExpired(token)) {
      // Если access токен устарел или отсутствует — обновляем
      await _refreshAccessToken();
      token = await _storage.read(key: _accessKey);
    }
    return token;
  }

  /// Обновляет access-токен с помощью refresh-токена
  Future<void> _refreshAccessToken() async {
    final refresh = await _storage.read(key: _refreshKey);
    if (refresh == null || JwtDecoder.isExpired(refresh)) {
      // Если refresh устарел — сессия считается завершённой
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

  /// Проверяет, авторизован ли пользователь (по refresh-токену)
  Future<bool> isLoggedIn() async {
    final refresh = await _storage.read(key: _refreshKey);
    return refresh != null && !JwtDecoder.isExpired(refresh);
  }

  /// Удаляет все сохранённые токены (выход из системы)
  Future<void> logout() async {
    await _storage.deleteAll();
  }

  /// Выполняет GET-запрос с авторизацией
  Future<http.Response> authorizedGet(String endpoint) async {
    final token = await getValidAccessToken();
    return http.get(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  /// Выполняет POST-запрос с авторизацией
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

  /// Получить access-токен (без проверки срока действия)
  Future<String?> getAccessToken() => _storage.read(key: _accessKey);

  /// Получить refresh-токен (без проверки срока действия)
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  /// Получить полное имя пользователя (first_name + last_name) из access-токена
  Future<String?> getUsername() async {
    final token = await getValidAccessToken();
    if (token != null) {
      final decoded = JwtDecoder.decode(token);
      return "${decoded['first_name']} ${decoded['last_name']}";
    }
    return null;
  }

  /// Проверить, является ли пользователь сотрудником (is_staff)
  Future<bool> isStaff() async {
    final token = await getValidAccessToken();
    if (token == null) return false;
    final decoded = JwtDecoder.decode(token);
    return decoded['is_staff'] == true;
  }
}
