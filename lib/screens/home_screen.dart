import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'ai_interview_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({
    super.key,
    this.userName = 'Alex',
  });

  static const _recentSessions = <(String, String, String, String, Color)>[];

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCvName;

  Future<void> _pickCv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (!mounted || result == null || result.files.isEmpty) return;

    setState(() => _selectedCvName = result.files.single.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InterviewMe', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: EdgeInsets.all(constraints.maxWidth > 700 ? 32 : 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _welcomeHeader(context),
                  const SizedBox(height: 28),
                  _actionCard(
                    context,
                    title: 'Start Live AI Interview',
                    description: 'Practice a live interview session with InterviewMe.',
                    icon: Icons.mic_rounded,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const AiInterviewScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _actionCard(
                    context,
                    title: 'Upload CV',
                    description: _selectedCvName ?? 'Choose a PDF, DOC, or DOCX resume.',
                    icon: Icons.upload_file_rounded,
                    onPressed: _pickCv,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _welcomeHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good morning, ${widget.userName}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
          ),
        const SizedBox(height: 8),
        const Text(
          'Follow your 3-step preparation journey below to practice live AI interviews and review tailored feedback.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.4),
        ),
      ],
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentCyan.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.accentCyan),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 5),
                      Text(description, style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: AppColors.accentCyan),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryCards(double availableWidth) {
    final cards = [
      ('Interviews Done', '08', Icons.quiz_outlined, AppColors.accentCyan),
      ('Average Score', '88%', Icons.insights_rounded, AppColors.success),
      ('Target Field', 'Software Eng.', Icons.work_outline_rounded, AppColors.warning),
      ('Prep Status', 'Ready', Icons.check_circle_outline_rounded, AppColors.accentPurple),
    ];
    final columns = availableWidth > 900 ? 4 : availableWidth > 550 ? 2 : 1;
    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: columns == 1 ? 3.4 : 2.1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cards.map(_summaryCard).toList(),
    );
  }

  Widget _summaryCard((String, String, IconData, Color) card) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: card.$4.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(card.$3, color: card.$4),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  card.$2,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  card.$1,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String caption) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.cardBorder.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            caption,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _preparationWorkflowCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _stepRow(
            stepNumber: 1,
            title: 'Step 1: Upload CV & Select Target Field',
            description: 'Provide your resume and select your target field (Software Engineering, Management, Finance, etc.) so AI generates tailored questions.',
            icon: Icons.upload_file_rounded,
            badgeText: 'Completed',
            badgeColor: AppColors.success,
            isCurrent: false,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 24,
                child: VerticalDivider(thickness: 2, color: AppColors.accentCyan),
              ),
            ),
          ),
          _stepRow(
            stepNumber: 2,
            title: 'Step 2: Live AI Practice Interview',
            description: 'Enter the interactive AI interview room for real-time voice and text interview practice tailored to your profile.',
            icon: Icons.smart_toy_outlined,
            badgeText: 'Active Step',
            badgeColor: AppColors.accentCyan,
            isCurrent: true,
            actionButton: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.mic_rounded, size: 18),
              label: const Text('Start AI Practice Session'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 24,
                child: VerticalDivider(thickness: 2, color: AppColors.cardBorder),
              ),
            ),
          ),
          _stepRow(
            stepNumber: 3,
            title: 'Step 3: Review Detailed Results & Feedback',
            description: 'Inspect overall score, question-by-question breakdown, strengths, and areas for improvement after finishing practice.',
            icon: Icons.analytics_outlined,
            badgeText: 'Next Step',
            badgeColor: AppColors.textMuted,
            isCurrent: false,
          ),
        ],
      ),
    );
  }

  Widget _stepRow({
    required int stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required String badgeText,
    required Color badgeColor,
    required bool isCurrent,
    Widget? actionButton,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.deepNavy : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: isCurrent ? Border.all(color: AppColors.accentCyan.withValues(alpha: 0.5)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                ),
                child: Center(
                  child: Icon(icon, color: badgeColor, size: 20),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isCurrent ? AppColors.textPrimary : AppColors.textPrimary.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                    ),
                    if (actionButton != null) ...[
                      const SizedBox(height: 14),
                      actionButton,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _recentSessionsList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: HomeScreen._recentSessions
            .map((session) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.deepNavy,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.record_voice_over_outlined, color: AppColors.accentCyan, size: 20),
                  ),
                  title: Text(
                    session.$1,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  subtitle: Text(
                    '${session.$2}  •  ${session.$4}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: _statusChip(session.$3, session.$5),
                ))
            .toList(),
      ),
    );
  }

  Widget _statusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                children: [
                  Image.asset('assets/interviewme-logo-v8.png', width: 100),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.cardBorder),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(Icons.dashboard_outlined, 'Home', true),
                  _drawerItem(Icons.route_outlined, 'Prep Journey', false),
                  _drawerItem(Icons.smart_toy_outlined, 'AI Practice Room', false),
                  _drawerItem(Icons.analytics_outlined, 'Feedback & Results', false),
                  _drawerItem(Icons.person_outline_rounded, 'Profile', false),
                  _drawerItem(Icons.settings_outlined, 'Settings', false),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.cardBorder),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
              onTap: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                (route) => false,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, bool selected) {
    return ListTile(
      enabled: selected,
      selected: selected,
      selectedTileColor: AppColors.cardSurface,
      leading: Icon(
        icon,
        color: selected ? AppColors.accentCyan : AppColors.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? AppColors.textPrimary : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      onTap: selected ? () {} : null,
    );
  }
}
