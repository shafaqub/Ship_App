import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ProfileData extends ChangeNotifier {
  String name;
  final String email;
  String careerField;
  String skills;
  String interests;

  ProfileData({
    required this.name,
    required this.email,
    this.careerField = '',
    this.skills = '',
    this.interests = '',
  });

  void update({
    required String name,
    required String careerField,
    required String skills,
    required String interests,
  }) {
    this.name = name;
    this.careerField = careerField;
    this.skills = skills;
    this.interests = interests;
    notifyListeners();
  }
}

class ProfileScreen extends StatefulWidget {
  final ProfileData profile;

  const ProfileScreen({super.key, required this.profile});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _careerController;
  late final TextEditingController _skillsController;
  late final TextEditingController _interestsController;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _careerController = TextEditingController(text: widget.profile.careerField);
    _skillsController = TextEditingController(text: widget.profile.skills);
    _interestsController = TextEditingController(
      text: widget.profile.interests,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _careerController.dispose();
    _skillsController.dispose();
    _interestsController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name cannot be empty.')));
      return;
    }

    widget.profile.update(
      name: name,
      careerField: _careerController.text.trim(),
      skills: _skillsController.text.trim(),
      interests: _interestsController.text.trim(),
    );
    setState(() => _editing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved for this session.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.profile,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _profileHeader(),
                    const SizedBox(height: 18),
                    _section(
                      title: 'Personal information',
                      icon: Icons.badge_outlined,
                      children: [
                        if (_editing)
                          TextField(
                            key: const ValueKey('profile-name-input'),
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                            ),
                          )
                        else
                          _detailRow('Full name', widget.profile.name),
                        _detailRow(
                          'Email address',
                          widget.profile.email.isEmpty
                              ? 'Not provided by the sign-in service'
                              : widget.profile.email,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _section(
                      title: 'Professional information',
                      icon: Icons.work_outline_rounded,
                      children: [
                        _profileField(
                          label: 'Career field',
                          value: widget.profile.careerField,
                          controller: _careerController,
                          hint: 'Not selected',
                          keyValue: 'profile-career-input',
                        ),
                        _profileField(
                          label: 'Skills',
                          value: widget.profile.skills,
                          controller: _skillsController,
                          hint: 'Add skills separated by commas',
                          keyValue: 'profile-skills-input',
                        ),
                        _profileField(
                          label: 'Professional interests',
                          value: widget.profile.interests,
                          controller: _interestsController,
                          hint: 'Not provided',
                          keyValue: 'profile-interests-input',
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _section(
                      title: 'Account overview',
                      icon: Icons.verified_user_outlined,
                      children: const [
                        _StaticDetailRow(
                          label: 'Account status',
                          value: 'Signed in',
                        ),
                        _StaticDetailRow(
                          label: 'Registration date',
                          value: 'Not provided by the authentication service',
                        ),
                      ],
                    ),
                    if (_editing) ...[
                      const SizedBox(height: 14),
                      const Text(
                        'Profile changes are saved in this app session. Server-side profile updates are not available.',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          key: const ValueKey('profile-save-button'),
                          onPressed: _saveProfile,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Save profile'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileHeader() {
    final initials = widget.profile.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.accentCyan.withValues(alpha: 0.14),
              child: Text(
                initials.isEmpty ? '?' : initials,
                style: const TextStyle(
                  color: AppColors.accentCyan,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.profile.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.profile.email.isEmpty
                        ? 'Email unavailable'
                        : widget.profile.email,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              key: const ValueKey('profile-edit-button'),
              onPressed: () {
                _nameController.text = widget.profile.name;
                _careerController.text = widget.profile.careerField;
                _skillsController.text = widget.profile.skills;
                _interestsController.text = widget.profile.interests;
                setState(() => _editing = !_editing);
              },
              icon: Icon(_editing ? Icons.close_rounded : Icons.edit_outlined),
              label: Text(_editing ? 'Cancel' : 'Edit profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.accentCyan, size: 20),
                const SizedBox(width: 9),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) => _StaticDetailRow(
    label: label,
    value: value.isEmpty ? 'Not provided' : value,
  );

  Widget _profileField({
    required String label,
    required String value,
    required TextEditingController controller,
    required String hint,
    required String keyValue,
  }) {
    if (_editing) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          key: ValueKey(keyValue),
          controller: controller,
          decoration: InputDecoration(labelText: label, hintText: hint),
        ),
      );
    }
    return _StaticDetailRow(label: label, value: value.isEmpty ? hint : value);
  }
}

class _StaticDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _StaticDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
