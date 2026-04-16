import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/core/router/app_router.dart';
import 'package:anigoods/features/cart/providers/cart_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // 1. ฟังก์ชันเปลี่ยนรหัสผ่าน
  Future<void> _resetPassword(BuildContext context) async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset link sent to your email!'),
            backgroundColor: AppTheme.accent,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.danger,
          ),
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
              if (context.mounted) context.go(RouteNames.login.path);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  // 4. ลบบัญชีแบบต่อจริงกับ Firebase
  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account', style: TextStyle(color: AppTheme.danger)),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // ปิด Dialog ก่อนทำงาน
              
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await user.delete(); // สั่งลบจาก Firebase Auth ของจริง
                  
                  if (context.mounted) {
                    context.go(RouteNames.login.path); // เตะกลับหน้า Login
                  }
                }
              } on FirebaseAuthException catch (e) {
                // ดัก Error กรณีเซสชันหมดอายุ (ต้องล็อกอินใหม่ก่อนลบ)
                if (e.code == 'requires-recent-login') {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please log out and log in again before deleting your account.'),
                        backgroundColor: AppTheme.danger,
                      ),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.message}'),
                        backgroundColor: AppTheme.danger,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppTheme.danger,
                    ),
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
              onTap: () {},
            ),

            const SizedBox(height: 16),
            const SectionLabel('PREFERENCES'),
            const SizedBox(height: 8),
            SettingsRow(
              icon: Icons.dark_mode_outlined,
              label: 'Dark Mode',
              onTap: () {},
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
              onTap: () => _showDeleteAccountDialog(context, ref), // เปลี่ยนให้เรียกใช้ฟังก์ชันจริง
            ),
          ],
        ),
      ),
    );
  }
}