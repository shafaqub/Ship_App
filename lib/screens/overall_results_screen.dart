import 'package:flutter/material.dart';

import '../services/grok_voice_service.dart';
import '../theme/app_theme.dart';

class OverallResultsScreen
    extends StatelessWidget {
  final InterviewEvaluation evaluation;

  const OverallResultsScreen({
    super.key,
    required this.evaluation,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Interview Results',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(16),

          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 900,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,

                children: [
                  const SizedBox(
                    height: 10,
                  ),

                  const Text(
                    'Interview Complete',
                    textAlign:
                        TextAlign.center,

                    style: TextStyle(
                      color:
                          AppTheme.primaryText,
                      fontSize: 26,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Text(
                    'Your AI-generated interview evaluation is ready.',
                    textAlign:
                        TextAlign.center,

                    style: TextStyle(
                      color:
                          AppTheme.secondaryText,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // =====================================================
                  // OVERALL SCORE
                  // =====================================================

                  Container(
                    padding:
                        const EdgeInsets.all(
                      24,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          AppTheme.cardBackground,

                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),

                      border: Border.all(
                        color: AppTheme.purple
                            .withOpacity(
                          0.25,
                        ),
                      ),
                    ),

                    child: Column(
                      children: [
                        const Text(
                          'Overall Score',
                          style: TextStyle(
                            color: AppTheme
                                .secondaryText,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Text(
                          '${evaluation.overallScore}',
                          style:
                              const TextStyle(
                            color:
                                AppTheme.lightBlue,
                            fontSize: 52,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const Text(
                          '/ 100',
                          style: TextStyle(
                            color: AppTheme
                                .secondaryText,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),

                          child:
                              LinearProgressIndicator(
                            value:
                                _scoreValue(
                              evaluation
                                  .overallScore,
                            ),

                            minHeight: 9,

                            backgroundColor:
                                AppTheme
                                    .background,

                            valueColor:
                                const AlwaysStoppedAnimation<
                                    Color>(
                              AppTheme.lightBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // =====================================================
                  // STATS
                  // =====================================================

                  Row(
                    children: [
                      Expanded(
                        child:
                            _StatCard(
                          title:
                              'Questions',
                          value: '5',
                          icon:
                              Icons.quiz_outlined,
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child:
                            _StatCard(
                          title:
                              'Technical',
                          value:
                              '${evaluation.technicalKnowledge}%',
                          icon:
                              Icons.code_rounded,
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child:
                            _StatCard(
                          title:
                              'Communication',
                          value:
                              '${evaluation.communication}%',
                          icon:
                              Icons.record_voice_over_outlined,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  // =====================================================
                  // PERFORMANCE
                  // =====================================================

                  const Text(
                    'Performance Overview',
                    style: TextStyle(
                      color:
                          AppTheme.primaryText,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _PerformanceCard(
                    title:
                        'Technical Knowledge',
                    score:
                        evaluation.technicalKnowledge,
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  _PerformanceCard(
                    title:
                        'Communication',
                    score:
                        evaluation.communication,
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  _PerformanceCard(
                    title:
                        'Clarity',
                    score:
                        evaluation.clarity,
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  _PerformanceCard(
                    title:
                        'Confidence',
                    score:
                        evaluation.confidence,
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // =====================================================
                  // AI SUMMARY
                  // =====================================================

                  _SectionTitle(
                    title:
                        'AI Summary',
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _InfoCard(
                    child: Text(
                      evaluation.summary,
                      style:
                          const TextStyle(
                        color: AppTheme
                            .secondaryText,
                        fontSize: 13,
                        height: 1.55,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // =====================================================
                  // QUESTION-BY-QUESTION EVALUATION
                  // =====================================================

                  const Text(
                    'Question-by-Question Analysis',
                    style: TextStyle(
                      color:
                          AppTheme.primaryText,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  ...evaluation.questions
                      .map(
                    (question) =>
                        Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),

                      child:
                          _QuestionEvaluationCard(
                        evaluation:
                            question,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  // =====================================================
                  // RECOMMENDATIONS
                  // =====================================================

                  if (evaluation
                      .recommendations
                      .isNotEmpty) ...[
                    const Text(
                      'Recommendations',
                      style:
                          TextStyle(
                        color: AppTheme
                            .primaryText,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    _InfoCard(
                      child:
                          Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: evaluation
                            .recommendations
                            .map(
                          (recommendation) =>
                              Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom: 10,
                            ),

                            child:
                                Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [
                                const Icon(
                                  Icons
                                      .check_circle_outline,
                                  color:
                                      AppTheme.lightBlue,
                                  size:
                                      18,
                                ),

                                const SizedBox(
                                  width: 9,
                                ),

                                Expanded(
                                  child:
                                      Text(
                                    recommendation,
                                    style:
                                        const TextStyle(
                                      color:
                                          AppTheme.secondaryText,
                                      fontSize:
                                          13,
                                      height:
                                          1.45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).toList(),
                      ),
                    ),
                  ],

                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _scoreValue(
    int score,
  ) {
    return (score.clamp(0, 100)) / 100;
  }
}

// ================================================================
// SECTION TITLE
// ================================================================

class _SectionTitle
    extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Text(
      title,
      style: const TextStyle(
        color:
            AppTheme.primaryText,
        fontSize: 18,
        fontWeight:
            FontWeight.bold,
      ),
    );
  }
}

// ================================================================
// INFO CARD
// ================================================================

class _InfoCard
    extends StatelessWidget {
  final Widget child;

  const _InfoCard({
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(16),

      decoration:
          BoxDecoration(
        color:
            AppTheme.cardBackground,

        borderRadius:
            BorderRadius.circular(
          14,
        ),

        border: Border.all(
          color: AppTheme.purple
              .withOpacity(
            0.12,
          ),
        ),
      ),

      child: child,
    );
  }
}

// ================================================================
// STAT CARD
// ================================================================

class _StatCard
    extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 14,
      ),

      decoration:
          BoxDecoration(
        color:
            AppTheme.cardBackground,

        borderRadius:
            BorderRadius.circular(
          14,
        ),

        border: Border.all(
          color: AppTheme.lightBlue
              .withOpacity(
            0.12,
          ),
        ),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            color:
                AppTheme.lightBlue,
            size: 20,
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            value,
            style:
                const TextStyle(
              color:
                  AppTheme.primaryText,
              fontSize: 17,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          Text(
            title,
            textAlign:
                TextAlign.center,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,

            style:
                const TextStyle(
              color:
                  AppTheme.secondaryText,
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// PERFORMANCE CARD
// ================================================================

class _PerformanceCard
    extends StatelessWidget {
  final String title;
  final int score;

  const _PerformanceCard({
    required this.title,
    required this.score,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),

      decoration:
          BoxDecoration(
        color:
            AppTheme.cardBackground,

        borderRadius:
            BorderRadius.circular(
          13,
        ),

        border: Border.all(
          color: AppTheme.purple
              .withOpacity(
            0.12,
          ),
        ),
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style:
                  const TextStyle(
                color:
                    AppTheme.primaryText,
                fontSize: 12.5,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          SizedBox(
            width: 90,

            child:
                ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                6,
              ),

              child:
                  LinearProgressIndicator(
                value:
                    score.clamp(
                          0,
                          100,
                        ) /
                        100,

                minHeight: 6,

                backgroundColor:
                    AppTheme.background,

                valueColor:
                    const AlwaysStoppedAnimation<
                        Color>(
                  AppTheme.lightBlue,
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          SizedBox(
            width: 35,

            child: Text(
              '$score%',
              textAlign:
                  TextAlign.right,

              style:
                  const TextStyle(
                color:
                    AppTheme.lightBlue,
                fontSize: 11,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// QUESTION EVALUATION CARD
// ================================================================

class _QuestionEvaluationCard
    extends StatelessWidget {
  final QuestionEvaluation evaluation;

  const _QuestionEvaluationCard({
    required this.evaluation,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(16),

      decoration:
          BoxDecoration(
        color:
            AppTheme.cardBackground,

        borderRadius:
            BorderRadius.circular(
          16,
        ),

        border: Border.all(
          color: AppTheme.purple
              .withOpacity(
            0.14,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,

                alignment:
                    Alignment.center,

                decoration:
                    BoxDecoration(
                  color: AppTheme.lightBlue
                      .withOpacity(
                    0.12,
                  ),

                  shape:
                      BoxShape.circle,
                ),

                child: Text(
                  '${evaluation.questionNumber}',
                  style:
                      const TextStyle(
                    color:
                        AppTheme.lightBlue,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              const Expanded(
                child: Text(
                  'Interview Question',
                  style:
                      TextStyle(
                    color:
                        AppTheme.secondaryText,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ),

              Text(
                '${evaluation.score}/100',
                style:
                    const TextStyle(
                  color:
                      AppTheme.lightBlue,
                  fontSize: 15,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 14,
          ),

          const Text(
            'Question',
            style:
                TextStyle(
              color:
                  AppTheme.primaryText,
              fontSize: 12,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            evaluation.question,
            style:
                const TextStyle(
              color:
                  AppTheme.secondaryText,
              fontSize: 13,
              height: 1.45,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          const Text(
            'Your Answer',
            style:
                TextStyle(
              color:
                  AppTheme.primaryText,
              fontSize: 12,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Container(
            width:
                double.infinity,

            padding:
                const EdgeInsets.all(
              12,
            ),

            decoration:
                BoxDecoration(
              color:
                  AppTheme.background,

              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),

            child: Text(
              evaluation.answer.isEmpty
                  ? 'No answer recorded.'
                  : evaluation.answer,

              style:
                  const TextStyle(
                color:
                    AppTheme.secondaryText,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          _FeedbackRow(
            title: 'Feedback',
            text:
                evaluation.feedback,
            icon:
                Icons.analytics_outlined,
          ),

          const SizedBox(
            height: 10,
          ),

          _FeedbackRow(
            title: 'Strength',
            text:
                evaluation.strength,
            icon:
                Icons.check_circle_outline,
          ),

          const SizedBox(
            height: 10,
          ),

          _FeedbackRow(
            title: 'Improve',
            text:
                evaluation.improvement,
            icon:
                Icons.trending_up_rounded,
          ),
        ],
      ),
    );
  }
}

// ================================================================
// FEEDBACK ROW
// ================================================================

class _FeedbackRow
    extends StatelessWidget {
  final String title;
  final String text;
  final IconData icon;

  const _FeedbackRow({
    required this.title,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Icon(
          icon,
          color:
              AppTheme.lightBlue,
          size: 18,
        ),

        const SizedBox(
          width: 9,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [
              Text(
                title,
                style:
                    const TextStyle(
                  color:
                      AppTheme.primaryText,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              Text(
                text,
                style:
                    const TextStyle(
                  color:
                      AppTheme.secondaryText,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}