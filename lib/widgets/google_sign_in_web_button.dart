import 'package:flutter/widgets.dart';

import 'google_sign_in_web_button_stub.dart'
    if (dart.library.js_interop) 'google_sign_in_web_button_impl.dart' as platform;

Widget buildGoogleSignInWebButton({
  required String clientId,
  required Future<void> Function(String idToken) onIdToken,
  required ValueChanged<Object> onError,
}) {
  return platform.buildGoogleSignInWebButton(
    clientId: clientId,
    onIdToken: onIdToken,
    onError: onError,
  );
}
