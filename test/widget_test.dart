import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ship_app/main.dart';
import 'package:ship_app/services/auth_service.dart';
import 'package:ship_app/splash_screen.dart';

class FakeAuthService extends AuthService {
  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    if ((email == 'alex@example.com' || email == 'test@example.com') &&
        (password == 'password' || password == 'password123')) {
      return const AuthResult(
        success: true,
        message: 'Login successful',
        user: {'name': 'Alex', 'email': 'alex@example.com'},
      );
    }
    return const AuthResult(
      success: false,
      message: 'Invalid email or password',
    );
  }

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (email == 'existing@example.com') {
      return const AuthResult(
        success: false,
        message: 'An account with this email already exists',
      );
    }
    return const AuthResult(
      success: true,
      message: 'Verification code sent',
      devCode: '123456',
    );
  }

  @override
  Future<AuthResult> verifyEmail({
    required String email,
    required String code,
  }) async {
    if (code == '123456') {
      return const AuthResult(
        success: true,
        message: 'Email verified successfully',
        user: {'name': 'Alex', 'email': 'alex@example.com'},
      );
    }
    return const AuthResult(
      success: false,
      message: 'Invalid verification code',
    );
  }
}

void main() {
  final fakeAuthService = FakeAuthService();

  testWidgets('splash screen opens the login page', (tester) async {
    await tester.pumpWidget(const ShipApp());

    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('login page renders its form', (tester) async {
    await tester.pumpWidget(ShipApp(authService: fakeAuthService, showSplash: false));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byKey(const Key('emailField')), findsOneWidget);
    expect(find.byKey(const Key('passwordField')), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('login validation prevents an empty submission', (tester) async {
    await tester.pumpWidget(ShipApp(authService: fakeAuthService, showSplash: false));

    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.text('Enter your email address'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    expect(find.text('Good morning, Alex'), findsNothing);
  });

  testWidgets('invalid credentials displays error message', (tester) async {
    await tester.pumpWidget(ShipApp(authService: fakeAuthService, showSplash: false));

    await tester.enterText(find.byKey(const Key('emailField')), 'wrong@example.com');
    await tester.enterText(find.byKey(const Key('passwordField')), 'wrongpass');
    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Invalid email or password'), findsWidgets);
    expect(find.text('Good morning, Alex'), findsNothing);
  });

  testWidgets('sign up flow switches mode, submits registration and verifies code', (tester) async {
    await tester.pumpWidget(ShipApp(authService: fakeAuthService, showSplash: false));

    await tester.ensureVisible(find.text('Sign Up'));
    await tester.tap(find.text('Sign Up'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Create an Account'), findsOneWidget);
    expect(find.byKey(const Key('nameField')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('nameField')), 'Alex Johnson');
    await tester.enterText(find.byKey(const Key('emailField')), 'newuser@example.com');
    await tester.enterText(find.byKey(const Key('passwordField')), 'password123');
    await tester.enterText(find.byKey(const Key('confirmPasswordField')), 'password123');

    await tester.ensureVisible(find.text('Send Verification Code'));
    await tester.tap(find.text('Send Verification Code'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Verify Email'), findsOneWidget);
    expect(find.byKey(const Key('verificationCodeField')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('verificationCodeField')), '123456');
    await tester.ensureVisible(find.text('Verify & Continue'));
    await tester.tap(find.text('Verify & Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Good morning, Alex'), findsOneWidget);
  });

  testWidgets('valid login navigates to the home dashboard', (tester) async {
    await tester.pumpWidget(ShipApp(authService: fakeAuthService, showSplash: false));

    await tester.enterText(find.byKey(const Key('emailField')), 'alex@example.com');
    await tester.enterText(find.byKey(const Key('passwordField')), 'password');
    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Good morning, Alex'), findsOneWidget);
    expect(find.text('Start Live AI Interview'), findsOneWidget);
    expect(find.text('Upload CV'), findsOneWidget);
  });

  testWidgets('home drawer opens and exposes navigation placeholders', (tester) async {
    await tester.pumpWidget(ShipApp(authService: fakeAuthService, showSplash: false));
    await tester.enterText(find.byKey(const Key('emailField')), 'alex@example.com');
    await tester.enterText(find.byKey(const Key('passwordField')), 'password');
    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Prep Journey'), findsOneWidget);
    expect(find.text('AI Practice Room'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('logout returns to the login page', (tester) async {
    await tester.pumpWidget(ShipApp(authService: fakeAuthService, showSplash: false));
    await tester.enterText(find.byKey(const Key('emailField')), 'alex@example.com');
    await tester.enterText(find.byKey(const Key('passwordField')), 'password');
    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Logout'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Good morning, Alex'), findsNothing);
  });
}
