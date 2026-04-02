import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/core/router/app_router.dart';

// ════════════════════════════════════════════════════════
// SETTINGS
// ════════════════════════════════════════════════════════
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                context.go(RouteNames.login.path);
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel( 'PRIVACY & SECURITY'),
            const SizedBox(height: 8),
            const SettingsRow(emoji: '🔒', label: 'Change Password'),
            const SettingsRow(emoji: '👁️', label: 'Privacy Settings'),
            const SettingsRow(emoji: '🛡️', label: 'Two-Factor Authentication'),
            const SizedBox(height: 16),
            const SectionLabel( 'NOTIFICATIONS'),
            const SizedBox(height: 8),
            const SettingsRow(emoji: '🔔', label: 'Push Notifications'),
            const SettingsRow(emoji: '📧', label: 'Email Notifications'),
            const SettingsRow(emoji: '📬', label: 'New Listings Alerts'),
            const SizedBox(height: 16),
            const SectionLabel( 'PREFERENCES'),
            const SizedBox(height: 8),
            const SettingsRow(emoji: '🌙', label: 'Dark Mode'),
            const SettingsRow(emoji: '🌐', label: 'Language'),
            const SettingsRow(emoji: '💱', label: 'Currency'),
            const SizedBox(height: 16),
            const SectionLabel( 'LEGAL'),
            const SizedBox(height: 8),
            const SettingsRow(emoji: '📄', label: 'Terms of Service'),
            const SettingsRow(emoji: '🔐', label: 'Privacy Policy'),
            const SettingsRow(emoji: 'ℹ️', label: 'App Version 1.0.0'),
            const SizedBox(height: 24),
            Divider(color: AppTheme.border),
            const SizedBox(height: 8),
            SettingsRow(
              emoji: '🚪', label: 'Log Out', danger: true,
              onTap: () => _showLogoutDialog(context),
            ),
            const SettingsRow(emoji: '🗑️', label: 'Delete Account', danger: true),
          ],
        ),
      ),
    );
  }
}
