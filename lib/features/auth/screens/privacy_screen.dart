import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:anigoods/core/theme/app_theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.accent, size: 20),
          onPressed: () => context.pop(), 
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: AppTheme.accent, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(
                color: AppTheme.accent,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Last updated: April 2026',
              style: TextStyle(color: Color(0xFFC3C6D6), fontSize: 13),
            ),
            const SizedBox(height: 32),

            //  ส่วนเนื้อหา 
           _buildSectionTitle('1. Information We Collect'),
            _buildParagraph(
              'When you register for 2GoodsMate, we collect personal information that you provide to us, such as your name, email address, and password. We also collect data about your interactions with the app, such as your watchlist and items you post.',
            ),

            _buildSectionTitle('2. How We Use Your Information'),
            _buildParagraph(
              'We use your information to provide, maintain, and improve our Service. This includes authenticating your login, enabling you to communicate with other collectors, and personalizing your marketplace experience.',
            ),

            _buildSectionTitle('3. Information Sharing'),
            _buildParagraph(
              'We do not sell your personal information to third parties. We may share your information only when necessary to provide our services (like database hosting via Firebase), comply with the law, or protect our rights.',
            ),

            _buildSectionTitle('4. Data Security'),
            _buildParagraph(
              'We use industry-standard security measures to protect your personal information. However, no method of transmission over the internet or electronic storage is 100% secure, and we cannot guarantee absolute security.',
            ),

            _buildSectionTitle('5. Your Rights'),
            _buildParagraph(
              'You have the right to access, update, or delete your personal information at any time through your account settings. If you delete your account, your data will be removed from our active databases.',
            ),

            const SizedBox(height: 60), 
          ],
        ),
      ),
    );
  }

  // Widget ช่วยสร้างหัวข้อใหญ่ 
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.accent, // ใช้สีฟ้า Accent ของแอป
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  //  Widget ช่วยสร้างเนื้อหา
  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textMuted, // ใช้สีเทาอ่อน
        fontSize: 14,
        height: 1.6, // ระยะห่างบรรทัด
      ),
    );
  }
}