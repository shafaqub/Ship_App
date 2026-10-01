import 'package:flutter/material.dart';

import '../services/grok_voice_service.dart';
import 'question_analysis_screen.dart';

class OverallResultsScreen extends StatelessWidget {
  final InterviewEvaluation evaluation;

  const OverallResultsScreen({
    super.key,
    required this.evaluation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020B1A),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Interview Results',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildScoreSection(),

              const SizedBox(height: 24),

              _buildSummaryCard(),

              const SizedBox(height: 20),

              _buildPerformanceCard(),

              const SizedBox(height: 20),

              _buildRecommendationsCard(),

              const SizedBox(height: 28),

              _buildDetailedAnalysisButton(context),

              const SizedBox(height: 14),

              _buildDoneButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreSection() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 8),

          const Text(
            'Interview Complete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Here is your AI-generated performance report.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.60),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 26),

          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0A1628),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 2,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${evaluation.overallScore}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '/100',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Overall Score',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return _buildCard(
      title: 'Overall Feedback',
      icon: Icons.auto_awesome,
      child: Text(
        evaluation.summary,
        style: TextStyle(
          color: Colors.white.withOpacity(0.80),
          fontSize: 14,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return _buildCard(
      title: 'Performance Breakdown',
      icon: Icons.analytics_outlined,
      child: Column(
        children: [
          _buildPerformanceRow(
            'Technical Knowledge',
            evaluation.technicalKnowledge,
          ),
          const SizedBox(height: 16),
          _buildPerformanceRow(
            'Communication',
            evaluation.communication,
          ),
          const SizedBox(height: 16),
          _buildPerformanceRow(
            'Clarity',
            evaluation.clarity,
          ),
          const SizedBox(height: 16),
          _buildPerformanceRow(
            'Confidence',
            evaluation.confidence,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceRow(
    String title,
    int score,
  ) {
    final safeScore = score.clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              '$safeScore/100',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: safeScore / 100,
            minHeight: 7,
            backgroundColor: Colors.white.withOpacity(0.08),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsCard() {
    final recommendations = evaluation.recommendations;

    return _buildCard(
      title: 'Areas to Improve',
      icon: Icons.trending_up,
      child: recommendations.isEmpty
          ? Text(
              'No additional recommendations were provided.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 14,
              ),
            )
          : Column(
              children: List.generate(
                recommendations.length,
                (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == recommendations.length - 1 ? 0 : 14,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            recommendations[index],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.78),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildDetailedAnalysisButton(
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuestionAnalysisScreen(
                evaluation: evaluation,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF020B1A),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 20,
            ),
            SizedBox(width: 9),
            Text(
              'View Detailed Analysis',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoneButton(
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          Navigator.popUntil(
            context,
            (route) => route.isFirst,
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white70,
          side: BorderSide(
            color: Colors.white.withOpacity(0.12),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          'Done',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.white70,
                size: 19,
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          child,
        ],
      ),
    );
  }
}

