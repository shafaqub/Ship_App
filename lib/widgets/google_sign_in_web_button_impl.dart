import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart';

import '../services/google_sign_in_service.dart';

class _GoogleSignInWebButton extends StatefulWidget {
  final String clientId;
  final Future<void> Function(String idToken) onIdToken;
  final ValueChanged<Object> onError;

  const _GoogleSignInWebButton({
    required this.clientId,
    required this.onIdToken,
    required this.onError,
  });

  @override
  State<_GoogleSignInWebButton> createState() => _GoogleSignInWebButtonState();
}

class _GoogleSignInWebButtonState extends State<_GoogleSignInWebButton> {
  late final Future<void> _initialization;
  late final StreamSubscription<GoogleSignInAuthenticationEvent> _subscription;
  bool _reportedInitializationError = false;

  @override
  void initState() {
    super.initState();
    _subscription = GoogleSignIn.instance.authenticationEvents.listen(
      _handleAuthenticationEvent,
      onError: widget.onError,
    );
    _initialization = GoogleSignInService.initialize(clientId: widget.clientId);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) {
    if (event is! GoogleSignInAuthenticationEventSignIn) return;
    final idToken = event.user.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      widget.onError(StateError('Google did not return an ID token'));
      return;
    }
    widget.onIdToken(idToken).catchError(widget.onError);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FutureBuilder<void>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            if (!_reportedInitializationError) {
              _reportedInitializationError = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) widget.onError(snapshot.error!);
              });
            }
            return const SizedBox.shrink();
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          return renderButton(
            configuration: GSIButtonConfiguration(
              theme: GSIButtonTheme.outline,
              size: GSIButtonSize.large,
              text: GSIButtonText.continueWith,
              shape: GSIButtonShape.rectangular,
              minimumWidth: 250,
            ),
          );
        },
      ),
    );
  }
}

Widget buildGoogleSignInWebButton({
  required String clientId,
  required Future<void> Function(String idToken) onIdToken,
  required ValueChanged<Object> onError,
}) {
  return _GoogleSignInWebButton(
    clientId: clientId,
    onIdToken: onIdToken,
    onError: onError,
  );
}
