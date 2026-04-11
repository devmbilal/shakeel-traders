import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class ApiService {
  static String? _baseUrl;

  static Future<String> get baseUrl async {
    if (_baseUrl != null) return _baseUrl!;
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString(AppConstants.keyServerIp) ?? '';
    final port =
        prefs.getInt(AppConstants.keyServerPort) ?? AppConstants.defaultPort;
    _baseUrl = 'http://$ip:$port';
    return _baseUrl!;
  }

  static void clearCache() => _baseUrl = null;

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyJwt);
  }

  static Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  /// Converts raw exceptions into user-friendly messages
  static String friendlyError(Object e) {
    final msg = e.toString();
    if (e is SocketException ||
        msg.contains('SocketException') ||
        msg.contains('Connection refused')) {
      return 'Cannot reach server. Check your Wi-Fi and server IP.';
    }
    if (msg.contains('TimeoutException') || msg.contains('timed out')) {
      return 'Server took too long to respond. Try again.';
    }
    if (msg.contains('401') || msg.contains('Token expired')) {
      return 'Session expired. Please log out and log in again.';
    }
    if (msg.contains('403')) {
      return 'Access denied. Your account may be deactivated.';
    }
    if (msg.contains('500') || msg.contains('Server error')) {
      return 'Server error. Please contact your administrator.';
    }
    if (msg.contains('FormatException') ||
        msg.contains('unexpected character')) {
      return 'Server returned an unexpected response. Check server is running.';
    }
    // Strip "Exception: " prefix for cleaner display
    return msg.replaceFirst('Exception: ', '');
  }

  /// Test connection — returns true if server responds
  static Future<bool> testConnection(String ip, int port) async {
    try {
      final url =
          Uri.parse('http://$ip:$port${AppConstants.apiTestConnection}');
      final res = await http.get(url).timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Login — returns {token, user} or throws
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final base = await baseUrl;
    final res = await http
        .post(
          Uri.parse('$base${AppConstants.apiLogin}'),
          headers: _headers(null),
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(const Duration(seconds: 10));

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return body;
    throw Exception(body['error'] ?? 'Login failed');
  }

  /// GET request with JWT
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final base = await baseUrl;
    final token = await _getToken();
    final res = await http
        .get(
          Uri.parse('$base$endpoint'),
          headers: _headers(token),
        )
        .timeout(const Duration(seconds: 30));

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    // Try to extract server error message
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? 'Request failed (${res.statusCode})');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Request failed (${res.statusCode})');
    }
  }

  /// POST request with JWT
  static Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    final base = await baseUrl;
    final token = await _getToken();
    final res = await http
        .post(
          Uri.parse('$base$endpoint'),
          headers: _headers(token),
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 30));

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? 'Request failed (${res.statusCode})');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Request failed (${res.statusCode})');
    }
  }
}
