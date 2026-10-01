import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AiInterviewScreen extends StatelessWidget {
  const AiInterviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Interview')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Practice Room',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Prepare for an interview with focused prompts and clear, structured answers.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const _PracticeInfoCard(
                    icon: Icons.question_answer_outlined,
                    title: 'Practice common questions',
                    description:
                        'Start with an introduction, role-specific questions, and examples from your experience.',
                  ),
                  const SizedBox(height: 12),
                  const _PracticeInfoCard(
                    icon: Icons.record_voice_over_outlined,
                    title: 'Structure your answers',
                    description:
                        'For behavioral questions, explain the situation, your actions, and the outcome.',
                  ),
                  const SizedBox(height: 12),
                  const _PracticeInfoCard(
                    icon: Icons.lightbulb_outline_rounded,
                    title: 'Practice tip',
                    description:
                        'Use specific examples and keep each response focused on your contribution.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PracticeInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PracticeInfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.accentCyan),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
