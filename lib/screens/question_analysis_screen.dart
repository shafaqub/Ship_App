import 'package:flutter/material.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../services/grok_voice_service.dart';
import '../services/revenue_cat_service.dart';

class QuestionAnalysisScreen extends StatefulWidget {
  final InterviewEvaluation evaluation;

  const QuestionAnalysisScreen({
    super.key,
    required this.evaluation,
  });

  @override
  State<QuestionAnalysisScreen> createState() =>
      _QuestionAnalysisScreenState();
}

class _QuestionAnalysisScreenState extends State<QuestionAnalysisScreen> {
  static const int freeQuestionLimit = 2;

  bool _isPremium = false;
  bool _checkingPremium = true;
  bool _unlockingPremium = false;

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
        _isPremium = premium;
        _checkingPremium = false;
      });
    } catch (e) {
      debugPrint('RevenueCat premium check failed: $e');

      if (!mounted) return;

      setState(() {
        _isPremium = false;
        _checkingPremium = false;
      });
    }
  }

  Future<void> _unlockPremium() async {
    if (_unlockingPremium) return;

    setState(() {
      _unlockingPremium = true;
    });

    try {
      /*
       * RevenueCat displays the actual configured paywall here.
       *
       * The paywall contains the subscription information,
       * monthly price, Subscribe button, restore option, etc.
       */
      await RevenueCatUI.presentPaywall();

      /*
       * After the paywall closes, check RevenueCat again.
       *
       * If the user successfully subscribed, the Premium
       * entitlement will now be active.
       */
      final premium = await RevenueCatService.isPremium();

      if (!mounted) return;

      setState(() {
        _isPremium = premium;
        _unlockingPremium = false;
      });

      if (premium) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Premium unlocked. All detailed analyses are now available.',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('RevenueCat paywall error: $e');

      if (!mounted) return;

      setState(() {
        _unlockingPremium = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open the Premium subscription. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.evaluation.questions;

    return Scaffold(
      backgroundColor: const Color(0xFF020B1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020B1A),
        elevation: 0,
        title: const Text(
          'Detailed Analysis',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: _checkingPremium
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                _buildHeader(),

                const SizedBox(height: 24),

                ...List.generate(
                  questions.length,
                  (index) {
                    final isLocked =
                        !_isPremium && index >= freeQuestionLimit;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: isLocked
                          ? _buildLockedQuestionCard(
                              index,
                              questions[index],
                            )
                          : _buildQuestionCard(
                              index,
                              questions[index],
                            ),
                    );
                  },
                ),

                if (!_isPremium &&
                    questions.length > freeQuestionLimit) ...[
                  const SizedBox(height: 8),
                  _buildPremiumSection(),
                ],
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Interview Analysis',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isPremium
              ? 'Premium unlocked — you can view detailed feedback for all questions.'
              : 'Your first 2 question analyses are free. Unlock Premium to see the remaining analyses.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(
    int index,
    dynamic question,
  ) {
    final questionNumber = _getQuestionNumber(question, index);
    final questionText = _getQuestionText(question);
    final answer = _getAnswer(question);
    final score = _getScore(question);
    final feedback = _getFeedback(question);
    final strength = _getStrength(question);
    final improvement = _getImprovement(question);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF162B49),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$questionNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  questionText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildScore(score),

          const SizedBox(height: 20),

          _buildAnalysisSection(
            title: 'Your Answer',
            icon: Icons.record_voice_over_outlined,
            text: answer,
          ),

          const SizedBox(height: 16),

          _buildAnalysisSection(
            title: 'AI Feedback',
            icon: Icons.auto_awesome,
            text: feedback,
          ),

          const SizedBox(height: 16),

          _buildAnalysisSection(
            title: 'Strength',
            icon: Icons.check_circle_outline,
            text: strength,
          ),

          const SizedBox(height: 16),

          _buildAnalysisSection(
            title: 'Improvement',
            icon: Icons.trending_up,
            text: improvement,
          ),
        ],
      ),
    );
  }

  Widget _buildLockedQuestionCard(
    int index,
    dynamic question,
  ) {
    final questionNumber = _getQuestionNumber(question, index);
    final questionText = _getQuestionText(question);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF091321),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF182438),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Question $questionNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.workspace_premium_outlined,
                color: Colors.amber,
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            questionText,
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 15,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  color: Colors.white54,
                  size: 18,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Detailed AI analysis is available with Premium.',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSection() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF101D31),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber.withOpacity(0.25),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: Colors.amber,
              size: 28,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Unlock Full Analysis',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Get detailed AI feedback for Questions 3–5 and access the complete interview analysis.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _unlockingPremium ? null : _unlockPremium,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.amber.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _unlockingPremium
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.black,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.workspace_premium, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Unlock Premium',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScore(int score) {
    return Row(
      children: [
        const Text(
          'AI Score',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          '$score/100',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisSection({
    required String title,
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.12),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 17,
                color: Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            text.isEmpty ? 'No analysis available.' : text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  int _getQuestionNumber(dynamic question, int index) {
    try {
      return question.questionNumber as int;
    } catch (_) {
      return index + 1;
    }
  }

  String _getQuestionText(dynamic question) {
    try {
      return question.question?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  String _getAnswer(dynamic question) {
    try {
      return question.answer?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  int _getScore(dynamic question) {
    try {
      final value = question.score;

      if (value is int) {
        return value;
      }

      return int.tryParse(value.toString()) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  String _getFeedback(dynamic question) {
    try {
      return question.feedback?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  String _getStrength(dynamic question) {
    try {
      return question.strength?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  String _getImprovement(dynamic question) {
    try {
      return question.improvement?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }
}

