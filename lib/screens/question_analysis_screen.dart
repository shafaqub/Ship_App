import 'package:flutter/material.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../theme/app_theme.dart';
import '../services/revenue_cat_service.dart';

class QuestionAnalysisScreen extends StatefulWidget {
  const QuestionAnalysisScreen({super.key});

  @override
  State<QuestionAnalysisScreen> createState() =>
      _QuestionAnalysisScreenState();
}

class _QuestionAnalysisScreenState
    extends State<QuestionAnalysisScreen> {
  bool isPremium = false;
  bool _openingPaywall = false;

  static const List<_QuestionFeedback> _questions = [
    _QuestionFeedback(
      number: 1,
      question:
          'What is the difference between let, const, and var in JavaScript?',
      answer:
          'Let is used for defining a variable, var is also for variables, and const is for a constant.',
      score: 82,
      strengths: [
        'Identified the main purpose of the three declarations',
        'Answer was direct and easy to understand',
        'Demonstrated basic JavaScript knowledge',
      ],
      improvements: [
        'Explain scope differences between var and let',
        'Mention that const prevents reassignment',
        'Give a small practical example',
      ],
    ),
    _QuestionFeedback(
      number: 2,
      question:
          'How would you make a website responsive for different screen sizes?',
      answer:
          'I would use responsive CSS and media queries so the website can adjust according to the screen size. I would also make sure the layout works on mobile and desktop.',
      score: 86,
      strengths: [
        'Correctly mentioned responsive CSS',
        'Included media queries',
        'Considered both mobile and desktop layouts',
      ],
      improvements: [
        'Mention flexible layouts such as Flexbox or Grid',
        'Explain responsive units such as percentages or rem',
        'Discuss testing across different screen sizes',
      ],
    ),
    _QuestionFeedback(
      number: 3,
      question:
          'What happens when you enter a URL into a web browser?',
      answer:
          'The browser sends a request to the server and receives the website. Then the browser loads and displays the page.',
      score: 78,
      strengths: [
        'Understood the request and response concept',
        'Correctly connected the browser with the server',
        'Explained the process in simple terms',
      ],
      improvements: [
        'Mention DNS resolution',
        'Explain HTTP or HTTPS communication',
        'Describe how the browser parses and renders the response',
      ],
    ),
    _QuestionFeedback(
      number: 4,
      question:
          'How would you debug a JavaScript function that is not working correctly?',
      answer:
          'I would first check the console for errors and then look at the code to find where the problem is. I would test different parts of the function to understand what is causing the issue.',
      score: 80,
      strengths: [
        'Started with checking console errors',
        'Used a logical debugging approach',
        'Focused on isolating the problem',
      ],
      improvements: [
        'Mention browser developer tools',
        'Use breakpoints and inspect variable values',
        'Explain how you would reproduce the problem consistently',
      ],
    ),
    _QuestionFeedback(
      number: 5,
      question:
          'How would you optimize a front-end application that is loading slowly?',
      answer:
          'I would check what is making the website slow and then optimize the code and resources. I would reduce unnecessary files and make sure images and other resources are optimized.',
      score: 84,
      strengths: [
        'Recognized that the bottleneck should be identified first',
        'Mentioned optimizing resources',
        'Considered unnecessary files and assets',
      ],
      improvements: [
        'Mention browser performance tools',
        'Discuss image compression and lazy loading',
        'Mention reducing unnecessary JavaScript and network requests',
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
    } catch (e) {
      debugPrint('RevenueCat entitlement check failed: $e');

      if (!mounted) return;

      setState(() {
        isPremium = false;
      });
    }
  }

  /// Opens the actual RevenueCat Paywall.
  ///
  /// RevenueCat handles:
  /// - subscription products
  /// - pricing
  /// - purchase button
  /// - Google Play purchase flow
  /// - restore purchases
  /// - paywall design configured in RevenueCat
  Future<void> _showRevenueCatPaywall() async {
    if (_openingPaywall) return;

    setState(() {
      _openingPaywall = true;
    });

    try {
      final result = await RevenueCatUI.presentPaywall();

      debugPrint('RevenueCat Paywall result: $result');

      // Check entitlement again after the paywall closes.
      await _checkPremiumStatus();

      if (!mounted) return;

      if (isPremium) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Premium unlocked successfully!',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint(
        'RevenueCat Paywall error: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open the premium subscription.',
          ),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _openingPaywall = false;
      });
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
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            14,
            8,
            14,
            18,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1000,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color:
                              AppTheme.purple.withOpacity(0.12),
                          borderRadius:
                              BorderRadius.circular(10),
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
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Question Analysis',
                              style: TextStyle(
                                color:
                                    AppTheme.primaryText,
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Review your performance on each question.',
                              style: TextStyle(
                                color:
                                    AppTheme.secondaryText,
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
                    _QuestionCard(
                      feedback: feedback,
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (!isPremium) ...[
                    _PremiumLock(
                      isLoading: _openingPaywall,
                      onUnlock: _showRevenueCatPaywall,
                    ),
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

  const _QuestionCard({
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.purple.withOpacity(0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
              _ScoreBadge(
                score: feedback.score,
              ),
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
            _BulletItem(
              icon: Icons.check_rounded,
              text: item,
            ),

          const SizedBox(height: 7),

          const _SectionLabel(
            icon: Icons.trending_up_rounded,
            title: 'Needs Improvement',
          ),

          const SizedBox(height: 6),

          for (final item in feedback.improvements)
            _BulletItem(
              icon: Icons.arrow_forward_rounded,
              text: item,
            ),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;

  const _ScoreBadge({
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue.withOpacity(0.10),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: AppTheme.lightBlue.withOpacity(0.20),
        ),
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

  const _SectionLabel({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.lightBlue,
          size: 15,
        ),
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

  const _BulletItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppTheme.lightBlue,
            size: 13,
          ),
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
  final bool isLoading;
  final VoidCallback onUnlock;

  const _PremiumLock({
    required this.isLoading,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.purple.withOpacity(0.28),
        ),
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
            'Subscribe to unlock questions 4–5 and your complete improvement report.',
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
              onPressed: isLoading
                  ? null
                  : onUnlock,
              icon: isLoading
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.workspace_premium_outlined,
                      size: 17,
                    ),
              label: Text(
                isLoading
                    ? 'Opening Premium...'
                    : 'Unlock Premium',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.purple,
                disabledBackgroundColor:
                    AppTheme.purple.withOpacity(0.5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(11),
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
        border: Border.all(
          color: AppTheme.purple.withOpacity(0.18),
        ),
      ),
      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppTheme.purple,
                size: 19,
              ),
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
            'Your interview shows a good foundation in front-end development and communication. To improve your technical interview performance, make your answers more structured and support technical concepts with short practical examples. When explaining a process, describe the steps in order instead of giving only a general overview. Continue practicing JavaScript fundamentals, browser concepts, responsive design, and debugging scenarios. Aim to answer confidently while keeping your responses focused and specific.',
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

