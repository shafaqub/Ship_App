import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PerformanceBar extends StatelessWidget {
  final String title;
  final int score;

  const PerformanceBar({super.key, required this.title, required this.score});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$score%',
                style: const TextStyle(
                  color: AppTheme.lightBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 6,
              backgroundColor: AppTheme.background,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.lightBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
