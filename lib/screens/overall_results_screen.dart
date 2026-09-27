import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/score_card.dart';
import '../widgets/performance_bar.dart';
import '../widgets/stat_card.dart';
import '../widgets/section_card.dart';
import 'question_analysis_screen.dart';

class OverallResultsScreen extends StatelessWidget {
  const OverallResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        title: const Text(
          'Interview Results',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppTheme.purple.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: AppTheme.lightBlue,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 9),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Interview Performance',
                              style: TextStyle(
                                color: AppTheme.primaryText,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Your AI-generated interview analysis.',
                              style: TextStyle(
                                color: AppTheme.secondaryText,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // OVERALL SCORE
                  const ScoreCard(score: 82),

                  const SizedBox(height: 14),

                  // PERFORMANCE BREAKDOWN
                  const SectionCard(
                    padding: EdgeInsets.fromLTRB(15, 14, 15, 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(
                          icon: Icons.analytics_outlined,
                          title: 'Performance Breakdown',
                        ),
                        SizedBox(height: 13),
                        PerformanceBar(title: 'Communication', score: 86),
                        PerformanceBar(title: 'Content & Relevance', score: 82),
                        PerformanceBar(title: 'Confidence', score: 78),
                        PerformanceBar(title: 'Clarity', score: 84),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // AI SUMMARY
                  const SectionCard(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(
                          icon: Icons.auto_awesome,
                          title: 'AI Summary',
                          purpleIcon: true,
                        ),
                        SizedBox(height: 9),
                        Text(
                          'You demonstrated strong communication skills and generally relevant answers throughout the interview. Your responses showed confidence, but some answers could be more structured and concise. Focusing on clear examples and organizing your responses using a structured approach can help you perform even better.',
                          style: TextStyle(
                            color: AppTheme.secondaryText,
                            fontSize: 12.5,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // STRENGTHS
                  const SectionCard(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(
                          icon: Icons.verified_outlined,
                          title: 'Your Strengths',
                        ),
                        SizedBox(height: 11),
                        _StrengthItem(
                          text: 'Clear and confident communication',
                        ),
                        _StrengthItem(
                          text: 'Relevant answers to most questions',
                        ),
                        _StrengthItem(
                          text: 'Good engagement with follow-up questions',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // INTERVIEW STATS
                  const _SectionHeader(
                    icon: Icons.insights_outlined,
                    title: 'Interview Stats',
                  ),

                  const SizedBox(height: 9),

                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 9,
                      runSpacing: 9,
                      children: const [
                        SizedBox(
                          width: 290,
                          child: StatCard(
                            icon: Icons.question_answer_outlined,
                            value: '8',
                            label: 'Questions Answered',
                          ),
                        ),
                        SizedBox(
                          width: 290,
                          child: StatCard(
                            icon: Icons.timer_outlined,
                            value: '1:12',
                            label: 'Average Answer Time',
                          ),
                        ),
                        SizedBox(
                          width: 290,
                          child: StatCard(
                            icon: Icons.schedule_outlined,
                            value: '10:24',
                            label: 'Interview Duration',
                          ),
                        ),
                        SizedBox(
                          width: 290,
                          child: StatCard(
                            icon: Icons.forum_outlined,
                            value: '3',
                            label: 'Follow-up Questions',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ACTIONS
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Retry Interview will be connected later.',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 17),
                          label: const Text(
                            'Retry',
                            style: TextStyle(fontSize: 12.5),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.lightBlue,
                            side: const BorderSide(color: AppTheme.lightBlue),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const QuestionAnalysisScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.analytics_rounded, size: 17),
                          label: const Text(
                            'Detailed Feedback',
                            style: TextStyle(fontSize: 12.5),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool purpleIcon;

  const _SectionHeader({
    required this.icon,
    required this.title,
    this.purpleIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: purpleIcon ? AppTheme.purple : AppTheme.lightBlue,
          size: 19,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.primaryText,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _StrengthItem extends StatelessWidget {
  final String text;

  const _StrengthItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppTheme.lightBlue,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.secondaryText,
                fontSize: 12.5,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
