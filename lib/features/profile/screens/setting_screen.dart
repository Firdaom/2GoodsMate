import 'package:anigoods/core/utils/snackbar_helper.dart';
import 'package:anigoods/features/cart/providers/cart_provider.dart';
import 'package:anigoods/features/home/providers/home_provider.dart';
import 'package:anigoods/features/watchlist/providers/watchlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/core/router/app_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _resetPassword(BuildContext context) async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (context.mounted) {
        SnackBarHelper.showSuccess(
          context,
          'Password reset link sent to your email!',
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showError(
          context,
          e,
          contextLabel: 'settings.resetPassword',
        );
      }
    }
  }

  // 2. เลือกภาษา
  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Select Language',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Text('🇹🇭', style: TextStyle(fontSize: 24)),
              title: const Text('ภาษาไทย'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              trailing: const Icon(Icons.check, color: AppTheme.accent),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 3. Log Out
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
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

              ref.invalidate(watchlistProvider);
              ref.invalidate(homeItemsProvider);
              ref.invalidate(cartProvider);

              if (context.mounted) context.go(RouteNames.login.path);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Account',
          style: TextStyle(color: AppTheme.danger),
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  ref.invalidate(watchlistProvider);
                  ref.invalidate(homeItemsProvider);

                  await user.delete();

                  if (context.mounted) {
                    SnackBarHelper.showSuccess(
                      context,
                      'Your account has been deleted.',
                    );
                    context.go(RouteNames.login.path);
                  }
                }
              } on FirebaseAuthException catch (e) {
                if (context.mounted) {
                  if (e.code == 'requires-recent-login') {
                    SnackBarHelper.showInfo(
                      context,
                      'Please log out and log in again before deleting your account.',
                      backgroundColor: AppTheme.danger,
                    );
                  } else {
                    SnackBarHelper.showError(
                      context,
                      e,
                      contextLabel: 'settings.deleteAccount',
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  SnackBarHelper.showError(
                    context,
                    e,
                    contextLabel: 'settings.deleteAccount',
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('PRIVACY & SECURITY'),
            const SizedBox(height: 8),
            SettingsRow(
              icon: Icons.lock_outline,
              label: 'Change Password',
              onTap: () => _resetPassword(context),
            ),
            SettingsRow(
              icon: Icons.privacy_tip_outlined,
              label: 'Privacy Settings',
              onTap: () {
                SnackBarHelper.showInfo(
                  context,
                  'Coming soon! This feature is under development.',
                  backgroundColor:
                      AppTheme.accent, 
                );
              },
            ),

            const SizedBox(height: 16),
            const SectionLabel('PREFERENCES'),
            const SizedBox(height: 8),
            SettingsRow(
              icon: Icons.dark_mode_outlined,
              label: 'Dark Mode',
              onTap: () {
                SnackBarHelper.showInfo(
                  context,
                  'Coming soon! This feature is under development.',
                  backgroundColor:
                      AppTheme.accent, 
                );
              },
            ),
            SettingsRow(
              icon: Icons.language,
              label: 'Language',
              onTap: () => _showLanguageSheet(context),
            ),

            SettingsRow(
              icon: Icons.logout,
              label: 'Log Out',
              danger: true,
              onTap: () => _showLogoutDialog(context, ref),
            ),
            SettingsRow(
              icon: Icons.delete_outline,
              label: 'Delete Account',
              danger: true,
              onTap: () => _showDeleteAccountDialog(
                context,
                ref,
              ), 
            ),
          ],
        ),
      ),
    );
  }
}
