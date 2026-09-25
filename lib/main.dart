import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ShipApp());
}

class ShipApp extends StatelessWidget {
  final AuthService? authService;

  const ShipApp({
    super.key,
    this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InterviewMe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: LoginScreen(authService: authService),
    );
  }
}
