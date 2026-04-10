import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/core/router/app_router.dart';

// ════════════════════════════════════════════════════════
// SETTINGS
// ════════════════════════════════════════════════════════

// 🔥 เปลี่ยนกลับเป็น StatelessWidget ธรรมดา
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // 1. ฟังก์ชันเปลี่ยนรหัสผ่าน (ส่งอีเมลไปให้ตั้งใหม่)
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
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppTheme.danger),
        );
      }
    }
  }

  // 2. ฟังก์ชันเลือกภาษา (เปิด Bottom Sheet)
  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Select Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Text('🇹🇭', style: TextStyle(fontSize: 24)),
              title: const Text('ภาษาไทย'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              trailing: const Icon(Icons.check, color: AppTheme.accent), 
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 3. ฟังก์ชัน Log Out
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
  // 🔥 เอา WidgetRef ref ออกไปให้เหลือแค่นี้
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
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Privacy settings coming soon!')));
              },
            ),
            
            const SizedBox(height: 16),
            const SectionLabel('PREFERENCES'),
            const SizedBox(height: 8),
            
            SettingsRow(
              icon: Icons.dark_mode_outlined,
              label: 'Dark Mode',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dark mode toggle coming soon!'))
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
              onTap: () => _showLogoutDialog(context),
            ),
            
            SettingsRow(
              icon: Icons.delete_outline,
              label: 'Delete Account',
              danger: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact support to delete account.')));
              },
            ),
          ],
        ),
      ),
    );
  }
}