import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PracticeTopic {
  final String title;
  final String level;
  final List<String> questions;

  const PracticeTopic({
    required this.title,
    required this.level,
    required this.questions,
  });
}

class PracticeCategory {
  final String title;
  final String description;
  final IconData icon;
  final List<PracticeTopic> topics;

  const PracticeCategory({
    required this.title,
    required this.description,
    required this.icon,
    required this.topics,
  });
}

const practiceCategories = <PracticeCategory>[
  PracticeCategory(
    title: 'Graphics Designer',
    description:
        'Explore visual design, creative tools, and portfolio decisions.',
    icon: Icons.brush_outlined,
    topics: [
      PracticeTopic(
        title: 'Design fundamentals',
        level: 'Foundations',
        questions: [
          'Explain how you use contrast, hierarchy, and alignment in a design.',
          'How do you balance consistency with originality in a visual system?',
        ],
      ),
      PracticeTopic(
        title: 'Typography and color',
        level: 'Foundations',
        questions: [
          'How do you choose typefaces and establish a readable type hierarchy?',
          'What do you consider when building an accessible color palette?',
        ],
      ),
      PracticeTopic(
        title: 'UI/UX and design tools',
        level: 'Applied',
        questions: [
          'How do you use user needs to guide a screen layout?',
          'Describe how you use Photoshop or Illustrator during a project.',
        ],
      ),
      PracticeTopic(
        title: 'Portfolio and projects',
        level: 'Applied',
        questions: [
          'Walk through a portfolio project from brief to final delivery.',
          'Tell me about a design decision you changed after receiving feedback.',
        ],
      ),
    ],
  ),
  PracticeCategory(
    title: 'Web Developer',
    description:
        'Review web fundamentals, responsive interfaces, APIs, and projects.',
    icon: Icons.code_rounded,
    topics: [
      PracticeTopic(
        title: 'HTML, CSS, and JavaScript',
        level: 'Foundations',
        questions: [
          'What makes HTML semantic, and why does semantic markup matter?',
          'How do you organize CSS to keep a growing interface maintainable?',
          'Explain how you use asynchronous JavaScript in an application.',
        ],
      ),
      PracticeTopic(
        title: 'Responsive web design',
        level: 'Foundations',
        questions: [
          'How do you approach a layout that needs to work across screen sizes?',
          'When would you use a flexible grid instead of fixed dimensions?',
        ],
      ),
      PracticeTopic(
        title: 'Frontend and backend',
        level: 'Applied',
        questions: [
          'How does a frontend communicate with a backend service?',
          'Describe how you would investigate a slow page or API response.',
        ],
      ),
      PracticeTopic(
        title: 'APIs, data, and projects',
        level: 'Applied',
        questions: [
          'What should a client handle when an API request fails?',
          'Describe a project where you worked with an API or database.',
          'Which development tools help you debug and test web applications?',
        ],
      ),
    ],
  ),
];

class PrepJourneyScreen extends StatelessWidget {
  const PrepJourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prep Journey')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Practice Answers',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose a professional field to explore interview questions and draft your answers.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    for (final category in practiceCategories) ...[
                      _PracticeCategoryCard(category: category),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PracticeCategoryCard extends StatelessWidget {
  final PracticeCategory category;

  const _PracticeCategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('practice-category-${category.title}'),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PracticeQuestionsScreen(category: category),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon, color: AppColors.accentCyan),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      category.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PracticeQuestionsScreen extends StatefulWidget {
  final PracticeCategory category;

  const PracticeQuestionsScreen({super.key, required this.category});

  @override
  State<PracticeQuestionsScreen> createState() =>
      _PracticeQuestionsScreenState();
}

class _PracticeQuestionsScreenState extends State<PracticeQuestionsScreen> {
  final Map<int, TextEditingController> _answerControllers = {};
  final Set<int> _savedAnswers = {};

  @override
  void dispose() {
    for (final controller in _answerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveAnswer(int questionIndex) {
    final answer = _answerControllers[questionIndex]?.text.trim() ?? '';
    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write an answer before saving.')),
      );
      return;
    }
    setState(() => _savedAnswers.add(questionIndex));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Answer saved for this session.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    var questionIndex = 0;
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.category.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Practice prompts',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    for (final topic in widget.category.topics) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, top: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                topic.title,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              topic.level,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      for (final question in topic.questions)
                        _QuestionCard(
                          key: ValueKey('practice-question-$questionIndex'),
                          questionIndex: questionIndex++,
                          question: question,
                          controller: _answerControllers.putIfAbsent(
                            questionIndex - 1,
                            TextEditingController.new,
                          ),
                          saved: _savedAnswers.contains(questionIndex - 1),
                          onSave: _saveAnswer,
                        ),
                      const SizedBox(height: 8),
                    ],
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Answers are stored only while this practice page is open.',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int questionIndex;
  final String question;
  final TextEditingController controller;
  final bool saved;
  final ValueChanged<int> onSave;

  const _QuestionCard({
    super.key,
    required this.questionIndex,
    required this.question,
    required this.controller,
    required this.saved,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: ValueKey('practice-answer-$questionIndex'),
              controller: controller,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Your answer',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                key: ValueKey('practice-save-$questionIndex'),
                onPressed: () => onSave(questionIndex),
                icon: Icon(saved ? Icons.check_rounded : Icons.save_outlined),
                label: Text(saved ? 'Saved' : 'Save answer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
