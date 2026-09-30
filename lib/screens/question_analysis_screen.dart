import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/revenuecat_service.dart';

class QuestionAnalysisScreen extends StatefulWidget {
  const QuestionAnalysisScreen({super.key});

  @override
  State<QuestionAnalysisScreen> createState() => _QuestionAnalysisScreenState();
}

class _QuestionAnalysisScreenState extends State<QuestionAnalysisScreen> {
  bool isPremium = false;

  static const List<_QuestionFeedback> _questions = [
    _QuestionFeedback(
      number: 1,
      question: 'Tell me about yourself.',
      answer:
          'I am currently studying computer science and I enjoy working on software projects. I have also participated in different university activities and technology competitions.',
      score: 84,
      strengths: [
        'Clear introduction',
        'Relevant academic background',
        'Good confidence',
      ],
      improvements: [
        'Could be more concise',
        'Mention specific technical experience',
      ],
    ),
    _QuestionFeedback(
      number: 2,
      question: 'Why did you choose computer science?',
      answer:
          'I chose computer science because I enjoy solving problems and building things with technology. I like the fact that there are always new things to learn.',
      score: 88,
      strengths: ['Clear motivation', 'Relevant reasoning', 'Natural delivery'],
      improvements: [
        'Add a specific personal example',
        'Connect your motivation to your career goals',
      ],
    ),
    _QuestionFeedback(
      number: 3,
      question: 'Tell me about a challenging project you worked on.',
      answer:
          'One challenging project involved working with a team to develop an application. We had to divide the work, solve technical issues, and make sure everything worked together before the deadline.',
      score: 81,
      strengths: [
        'Demonstrated teamwork',
        'Identified a real challenge',
        'Showed problem-solving ability',
      ],
      improvements: [
        'Explain your specific contribution',
        'Describe the final result more clearly',
      ],
    ),
    _QuestionFeedback(
      number: 4,
      question: 'How do you handle pressure and deadlines?',
      answer:
          'I usually break the work into smaller tasks and prioritize what needs to be completed first. This helps me stay organized when I have multiple deadlines.',
      score: 79,
      strengths: ['Practical approach', 'Good organization strategy'],
      improvements: [
        'Give a real example',
        'Explain how you handled an unexpected problem',
      ],
    ),
    _QuestionFeedback(
      number: 5,
      question: 'What is one of your biggest strengths?',
      answer:
          'One of my strengths is that I am willing to help others and work collaboratively. I also try to take responsibility when I am given a task.',
      score: 86,
      strengths: ['Good self-awareness', 'Team-oriented response'],
      improvements: [
        'Support the claim with an example',
        'Avoid general statements',
      ],
    ),
    _QuestionFeedback(
      number: 6,
      question: 'What is one weakness you are working on?',
      answer:
          'Sometimes I spend too much time trying to make something perfect. I have been working on managing my time better and focusing on completing important tasks efficiently.',
      score: 83,
      strengths: [
        'Honest response',
        'Shows self-awareness',
        'Includes an improvement strategy',
      ],
      improvements: [
        'Give a specific example',
        'Explain the progress you have made',
      ],
    ),
    _QuestionFeedback(
      number: 7,
      question: 'Where do you see yourself in five years?',
      answer:
          'I hope to be working in the technology industry, developing useful products and continuing to improve my technical and leadership skills.',
      score: 80,
      strengths: ['Clear career direction', 'Shows willingness to grow'],
      improvements: [
        'Mention a specific area of technology',
        'Connect your goals to your current experience',
      ],
    ),
    _QuestionFeedback(
      number: 8,
      question: 'Why should we select you?',
      answer:
          'I believe I can contribute through my technical skills, willingness to learn, and ability to work with others. I am also comfortable taking responsibility and learning from feedback.',
      score: 85,
      strengths: [
        'Confident response',
        'Relevant qualities',
        'Positive attitude',
      ],
      improvements: [
        'Use specific achievements',
        'Make the answer more memorable',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
  }

  Future<void> _checkPremiumStatus() async {
    try {
      final premium = await RevenueCatService.isPremium();

      if (!mounted) return;

      setState(() {
        isPremium = premium;
      });
    } catch (_) {
      // Keep free mode if the entitlement check fails.
    }
  }

  Future<void> _handlePurchase(BuildContext dialogContext) async {
    Navigator.pop(dialogContext);

    try {
      final customerInfo = await RevenueCatService.purchasePremium();

      if (!mounted) return;

      bool premium = false;

      if (customerInfo != null) {
        premium = customerInfo.entitlements.active.containsKey(
          RevenueCatService.entitlementId,
        );
      }

      if (!premium) {
        premium = await RevenueCatService.isPremium();
      }

      if (!mounted) return;

      setState(() {
        isPremium = premium;
      });

      if (premium) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Premium unlocked successfully!')),
        );
      }
    } catch (_) {
      // Do not show an error SnackBar during the demo.
    }
  }

  void _showPremiumDialog() async {
    try {
      final offerings = await RevenueCatService.getOfferings();
      final offering = offerings.current;
      final package = offering?.monthly;

      if (!mounted) return;

      if (package == null) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: AppTheme.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Premium Unavailable',
                style: TextStyle(color: AppTheme.primaryText, fontSize: 17),
              ),
              content: const Text(
                'The premium subscription is currently unavailable.',
                style: TextStyle(
                  color: AppTheme.secondaryText,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: AppTheme.lightBlue),
                  ),
                ),
              ],
            );
          },
        );

        return;
      }

      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: AppTheme.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.workspace_premium_rounded,
                  color: AppTheme.lightBlue,
                  size: 22,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Unlock Full Analysis',
                    style: TextStyle(
                      color: AppTheme.primaryText,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Get complete AI-powered feedback for your interview.',
                  style: TextStyle(
                    color: AppTheme.secondaryText,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Premium includes:',
                  style: TextStyle(
                    color: AppTheme.primaryText,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  '• Questions 4–8\n'
                  '• Complete improvement report',
                  style: TextStyle(
                    color: AppTheme.secondaryText,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  package.storeProduct.priceString,
                  style: const TextStyle(
                    color: AppTheme.lightBlue,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  ' per month',
                  style: TextStyle(color: AppTheme.secondaryText, fontSize: 11),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'Maybe Later',
                  style: TextStyle(color: AppTheme.secondaryText),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _handlePurchase(dialogContext);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Subscribe',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          );
        },
      );
    } catch (_) {
      // Do not show an error SnackBar during the demo.
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleQuestions = isPremium
        ? _questions
        : _questions.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        title: const Text(
          'Detailed Feedback',
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
                          Icons.analytics_outlined,
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
                              'Question Analysis',
                              style: TextStyle(
                                color: AppTheme.primaryText,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Review your performance on each question.',
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
                  for (final feedback in visibleQuestions) ...[
                    _QuestionCard(feedback: feedback),
                    const SizedBox(height: 12),
                  ],
                  if (!isPremium) ...[
                    const _PremiumLock(),
                    const SizedBox(height: 14),
                  ],
                  if (isPremium) ...[
                    const _OverallImprovement(),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final _QuestionFeedback feedback;

  const _QuestionCard({required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.purple.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'QUESTION ${feedback.number}',
                  style: const TextStyle(
                    color: AppTheme.lightBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              _ScoreBadge(score: feedback.score),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            feedback.question,
            style: const TextStyle(
              color: AppTheme.primaryText,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 11),
          const _SectionLabel(
            icon: Icons.record_voice_over_outlined,
            title: 'Your Answer',
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '"${feedback.answer}"',
              style: const TextStyle(
                color: AppTheme.secondaryText,
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 11),
          const _SectionLabel(
            icon: Icons.check_circle_outline_rounded,
            title: 'What You Did Well',
          ),
          const SizedBox(height: 6),
          for (final item in feedback.strengths)
            _BulletItem(icon: Icons.check_rounded, text: item),
          const SizedBox(height: 7),
          const _SectionLabel(
            icon: Icons.trending_up_rounded,
            title: 'Needs Improvement',
          ),
          const SizedBox(height: 6),
          for (final item in feedback.improvements)
            _BulletItem(icon: Icons.arrow_forward_rounded, text: item),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;

  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue.withOpacity(0.10),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppTheme.lightBlue.withOpacity(0.20)),
      ),
      child: Text(
        '$score/100',
        style: const TextStyle(
          color: AppTheme.lightBlue,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionLabel({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.lightBlue, size: 15),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.primaryText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _BulletItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BulletItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.lightBlue, size: 13),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.secondaryText,
                fontSize: 11.5,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumLock extends StatelessWidget {
  const _PremiumLock();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.purple.withOpacity(0.28)),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.purple.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: AppTheme.lightBlue,
              size: 21,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Unlock Full Analysis',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.primaryText,
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Subscribe to unlock questions 4–8 and your complete improvement report.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.secondaryText,
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final state = context
                    .findAncestorStateOfType<_QuestionAnalysisScreenState>();

                state?._showPremiumDialog();
              },
              icon: const Icon(Icons.workspace_premium_outlined, size: 17),
              label: const Text(
                'Unlock Premium',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
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
    );
  }
}

class _OverallImprovement extends StatelessWidget {
  const _OverallImprovement();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.purple.withOpacity(0.18)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppTheme.purple, size: 19),
              SizedBox(width: 7),
              Text(
                'Overall Improvement Suggestions',
                style: TextStyle(
                  color: AppTheme.primaryText,
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Your overall performance shows a strong foundation in communication, confidence, and relevance. To improve further, focus on making your answers more structured and specific. Whenever possible, support your statements with concrete examples and clearly explain the situation, action, and result. Keep your responses focused and continue practicing your delivery so your confidence and clarity remain consistent.',
            style: TextStyle(
              color: AppTheme.secondaryText,
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionFeedback {
  final int number;
  final String question;
  final String answer;
  final int score;
  final List<String> strengths;
  final List<String> improvements;

  const _QuestionFeedback({
    required this.number,
    required this.question,
    required this.answer,
    required this.score,
    required this.strengths,
    required this.improvements,
  });
}
