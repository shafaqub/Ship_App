import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  final ProfileData profile;
  final VoidCallback onLogout;

  const SettingsScreen({
    super.key,
    required this.profile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _SettingsSection(title: 'Account settings', children: []),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline_rounded),
                title: const Text('Profile information'),
                subtitle: Text(
                  profile.email.isEmpty ? profile.name : profile.email,
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ProfileScreen(profile: profile),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const _SettingsSection(
              title: 'Appearance',
              children: [
                _SettingsInfoTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark theme',
                  subtitle: 'The app currently uses its dark theme.',
                  status: 'Active',
                ),
              ],
            ),
            const SizedBox(height: 18),
            const _SettingsSection(
              title: 'Notifications',
              children: [
                _SettingsInfoTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notification preferences',
                  subtitle: 'Notifications are not available in this version.',
                  status: 'Unavailable',
                ),
              ],
            ),
            const SizedBox(height: 18),
            const _SettingsSection(
              title: 'Privacy and security',
              children: [
                _SettingsInfoTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Account security',
                  subtitle:
                      'Sign-in and password verification are managed by your authentication service.',
                  status: 'Managed',
                ),
              ],
            ),
            const SizedBox(height: 18),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: onLogout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        if (children.isNotEmpty) ...children,
      ],
    );
  }
}

class _SettingsInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;

  const _SettingsInfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.accentCyan),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          status,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ),
    );
  }
}
