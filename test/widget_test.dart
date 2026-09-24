import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ship_app/main.dart';

void main() {
  testWidgets('Splash screen shows InterviewMe branding', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final richTextWidgets = tester.widgetList<RichText>(find.byType(RichText));
    expect(richTextWidgets, isNotEmpty);
    expect(
      richTextWidgets.first.text.toPlainText(),
      contains('InterviewMe'),
    );
  });
}
