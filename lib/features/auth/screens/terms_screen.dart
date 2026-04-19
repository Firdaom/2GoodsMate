import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:anigoods/core/theme/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          'Terms of Service',
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
              'Terms and Conditions',
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
            _buildSectionTitle('1. Acceptance of Terms'),
            _buildParagraph(
              'By accessing and using the 2GoodsMate application, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our application or services.',
            ),

            _buildSectionTitle('2. User Accounts'),
            _buildParagraph(
              'You are responsible for safeguarding the password that you use to access the Service. You agree not to disclose your password to any third party. You must notify us immediately upon becoming aware of any breach of security or unauthorized use of your account.',
            ),

            _buildSectionTitle('3. Marketplace Rules'),
            _buildParagraph(
              '2GoodsMate is a platform for anime collectors. Users must accurately describe items, respect intellectual property rights, and fulfill accepted transactions. We reserve the right to suspend or terminate accounts that violate these community guidelines.',
            ),

            _buildSectionTitle('4. Content Ownership'),
            _buildParagraph(
              'You retain your rights to any content you submit, post or display on or through the Service. By submitting content, you grant us a worldwide, non-exclusive, royalty-free license to use, copy, reproduce, process, and display that content.',
            ),

            _buildSectionTitle('5. Termination'),
            _buildParagraph(
              'We may terminate or suspend access to our Service immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.',
            ),

            const SizedBox(height: 60), 
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.accent, 
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(
        color:AppTheme.textMuted,
        fontSize: 14,
        height: 1.6, 
      ),
    );
  }
}