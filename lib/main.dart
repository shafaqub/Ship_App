import 'package:flutter/material.dart';
import 'login_page.dart';

import 'services/revenuecat_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await RevenueCatService.initialize();

  runApp(const InterviewMeApp());
}

class InterviewMeApp extends StatelessWidget {
  const InterviewMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'InterviewMe',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF020B1A),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5E7CFF)),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}
