import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ShipApp());
}

class ShipApp extends StatelessWidget {
  final AuthService? authService;
  final bool showSplash;

  const ShipApp({
    super.key,
    this.authService,
    this.showSplash = true,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InterviewMe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
        home: showSplash
          ? SplashScreen(nextScreen: LoginScreen(authService: authService))
          : LoginScreen(authService: authService),
    );
  }
}