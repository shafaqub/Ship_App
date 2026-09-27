import 'package:flutter/material.dart';

import 'screens/overall_results_screen.dart';
import 'theme/app_theme.dart';
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
      theme: AppTheme.darkTheme,
      home: const OverallResultsScreen(),
    );
  }
}
