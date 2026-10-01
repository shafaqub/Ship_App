import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ship_app/screens/home_screen.dart';
import 'package:ship_app/theme/app_theme.dart';

Future<void> _pumpHome(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.theme,
      home: const HomeScreen(
        userName: 'Morgan Lee',
        userEmail: 'morgan@example.com',
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openDrawer(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
}

Future<void> _openDrawerItem(WidgetTester tester, String label) async {
  await _openDrawer(tester);
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('drawer keeps supported destinations and removes old items', (
    tester,
  ) async {
    await _pumpHome(tester);
    await _openDrawer(tester);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Prep Journey'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    expect(find.text('AI Practice Room'), findsNothing);
    expect(find.text('Feedback & Results'), findsNothing);
  });

  testWidgets('Profile shows account data and saves editable details', (
    tester,
  ) async {
    await _pumpHome(tester);
    await _openDrawerItem(tester, 'Profile');

    expect(find.text('Morgan Lee'), findsWidgets);
    expect(find.text('morgan@example.com'), findsWidgets);
    expect(find.text('Account overview'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('profile-edit-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('profile-name-input')),
      'Morgan Ellis',
    );
    await tester.enterText(
      find.byKey(const ValueKey('profile-career-input')),
      'Web Developer',
    );
    await tester.enterText(
      find.byKey(const ValueKey('profile-skills-input')),
      'Dart, Flutter, JavaScript',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('profile-save-button')),
    );
    await tester.tap(find.byKey(const ValueKey('profile-save-button')));
    await tester.pumpAndSettle();

    expect(find.text('Morgan Ellis'), findsWidgets);
    expect(find.text('Profile saved for this session.'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Good morning, Morgan Ellis'), findsOneWidget);
  });

  testWidgets('Settings shows supported states and links to Profile', (
    tester,
  ) async {
    await _pumpHome(tester);
    await _openDrawerItem(tester, 'Settings');

    expect(find.text('Dark theme'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Unavailable'), findsOneWidget);
    expect(find.text('Account security'), findsOneWidget);
    await tester.tap(find.text('Profile information'));
    await tester.pumpAndSettle();
    expect(find.text('morgan@example.com'), findsWidgets);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Graphics Designer practice saves an answer and returns', (
    tester,
  ) async {
    await _pumpHome(tester);
    await _openDrawerItem(tester, 'Prep Journey');

    expect(find.text('Graphics Designer'), findsWidgets);
    expect(find.text('Web Developer'), findsWidgets);
    await tester.tap(find.text('Graphics Designer'));
    await tester.pumpAndSettle();
    expect(find.text('Graphics Designer'), findsWidgets);
    expect(
      find.text(
        'Explain how you use contrast, hierarchy, and alignment in a design.',
      ),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const ValueKey('practice-answer-0')),
      'I use contrast to establish hierarchy and alignment to create order.',
    );
    await tester.tap(find.byKey(const ValueKey('practice-save-0')));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Web Developer'), findsWidgets);
  });

  testWidgets('Web Developer practice opens relevant questions', (
    tester,
  ) async {
    await _pumpHome(tester);
    await _openDrawerItem(tester, 'Prep Journey');
    await tester.tap(find.text('Web Developer'));
    await tester.pumpAndSettle();

    expect(find.text('Web Developer'), findsWidgets);
    expect(
      find.text(
        'What makes HTML semantic, and why does semantic markup matter?',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('practice-answer-0')), findsOneWidget);
  });

  testWidgets('Home closes the drawer without changing screens', (
    tester,
  ) async {
    await _pumpHome(tester);
    await _openDrawerItem(tester, 'Home');

    expect(find.text('Good morning, Morgan Lee'), findsOneWidget);
    expect(find.text('Logout'), findsNothing);
  });

  testWidgets('Logout returns to the login screen', (tester) async {
    await _pumpHome(tester);
    await _openDrawer(tester);
    await tester.tap(find.text('Logout'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.text('Prepare for interviews\nwith AI confidence.'),
      findsOneWidget,
    );
  });
}
