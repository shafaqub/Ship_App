import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class AuthResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? user;
  final String? devCode;

  const AuthResult({
    required this.success,
    required this.message,
    this.user,
    this.devCode,
  });
}

class AuthService {
  final http.Client _client;
  final String _baseUrl;

  AuthService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/login');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && (data['success'] == true)) {
        return AuthResult(
          success: true,
          message: data['message'] as String? ?? 'Login successful',
          user: data['user'] as Map<String, dynamic>?,
        );
      } else {
        return AuthResult(
          success: false,
          message: data['message'] as String? ?? 'Invalid email or password',
        );
      }
    } catch (e) {
      return const AuthResult(
        success: false,
        message: 'Unable to connect to authentication server. Ensure backend is running.',
      );
    }
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/register');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;

      if ((response.statusCode == 200 || response.statusCode == 201) && (data['success'] == true)) {
        return AuthResult(
          success: true,
          message: data['message'] as String? ?? 'Verification code sent',
        );
      } else {
        return AuthResult(
          success: false,
          message: data['message'] as String? ?? 'Registration failed',
        );
      }
    } catch (e) {
      return const AuthResult(
        success: false,
        message: 'Unable to connect to registration server.',
      );
    }
  }

  Future<AuthResult> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/verify-email');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'code': code.trim(),
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && (data['success'] == true)) {
        return AuthResult(
          success: true,
          message: data['message'] as String? ?? 'Email verified successfully',
          user: data['user'] as Map<String, dynamic>?,
        );
      } else {
        return AuthResult(
          success: false,
          message: data['message'] as String? ?? 'Invalid verification code',
        );
      }
    } catch (e) {
      return const AuthResult(
        success: false,
        message: 'Unable to connect to verification server.',
      );
    }
  }
}
