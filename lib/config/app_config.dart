import 'package:flutter/foundation.dart';

class AppConfig {
  static const String _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');
  static const String _defaultGoogleClientId =
      '873876898844-6a4hvkd7gku5j1rhvi7lusrncajhiuap.apps.googleusercontent.com';
  static const String googleClientId =
      String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: _defaultGoogleClientId);
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: _defaultGoogleClientId,
  );

  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) return _apiBaseUrlOverride;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api/auth';
    }
    return 'http://localhost:5000/api/auth';
  }
}
