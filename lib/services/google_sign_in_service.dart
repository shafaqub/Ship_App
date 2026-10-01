import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static Future<void>? _initialization;
  static String? _lastClientId;
  static String? _lastServerClientId;

  static Future<void> initialize({
    String? clientId,
    String? serverClientId,
  }) {
    final targetClientId = clientId ?? '';
    final targetServerClientId = serverClientId ?? '';

    if (_initialization != null &&
        _lastClientId == targetClientId &&
        _lastServerClientId == targetServerClientId) {
      return _initialization!;
    }

    _lastClientId = targetClientId;
    _lastServerClientId = targetServerClientId;
    _initialization = GoogleSignIn.instance.initialize(
      clientId: targetClientId.isEmpty ? null : targetClientId,
      serverClientId: targetServerClientId.isEmpty ? null : targetServerClientId,
    );
    return _initialization!;
  }

  static Future<void> reset() async {
    _initialization = null;
    _lastClientId = null;
    _lastServerClientId = null;
  }

  static Future<void> signOut() async {
    if (_initialization != null) {
      await _initialization;
    }
    await GoogleSignIn.instance.signOut();
  }
}
