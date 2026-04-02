import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/services/error_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anigoods/core/router/app_router.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/core/services/auth_service.dart';

// ══════════════════════════════════════════════════════════
// REGISTER SCREEN
// ══════════════════════════════════════════════════════════
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. เพิ่มแฟ้มหนีบเอกสาร
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  
  bool _loading  = false;
  bool _obscure1 = true;
  bool _obscure2 = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // 🗑️ ลบตัวแปร _passwordsMatch และ _canSubmit ทิ้งไปได้เลย! แฟ้มเอกสารจะจัดการเอง

  Future<void> _register() async {
    // 2. สั่งให้แฟ้มตรวจเอกสารก่อน ถ้าช่องไหนไม่ผ่านให้หยุดทำงาน
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      // Create Firebase Auth account
      final credential = await _authService.registerWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      if (mounted) {
        context.go(RouteNames.home.path);
      }
    } catch (e) {
      ErrorHandler.logError('register_screen._register()', e);
      setState(() => _error = ErrorHandler.getUserMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          // 3. เอา Form มาครอบไว้
          child: Form(
            key: _formKey, // 👈 หนีบแฟ้มไว้ตรงนี้
            child: Column(
              children: [
                const SizedBox(height: 60),
                const _Logo(subtitle: 'Join the collector community'),
                const SizedBox(height: 40),

                _FieldLabel('Email'),
                const SizedBox(height: 6),
                // 4. เปลี่ยนเป็น TextFormField
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(hintText: 'your@email.com'),
                  // ใส่ Validator เช็คอีเมล
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _FieldLabel('Password'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure1,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Min. 8 characters',
                    // ลบ errorText แบบเก่าทิ้งไปเลย
                    suffixIcon: IconButton(
                      icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility,
                          color: AppTheme.textMuted, size: 18),
                      onPressed: () => setState(() => _obscure1 = !_obscure1), // setState ตรงนี้ยังต้องมี เพื่อสลับไอคอนรูปตา
                    ),
                  ),
                  // ใส่ Validator เช็ครหัสผ่าน
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Min. 8 characters required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _FieldLabel('Confirm Password'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscure2,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  onFieldSubmitted: (_) => _register(), // เปลี่ยนจาก onSubmitted เป็น onFieldSubmitted
                  decoration: InputDecoration(
                    hintText: 'Repeat password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility,
                          color: AppTheme.textMuted, size: 18),
                      onPressed: () => setState(() => _obscure2 = !_obscure2),
                    ),
                  ),
                  // ใส่ Validator เช็คว่ารหัสตรงกันไหม
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordCtrl.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // สำหรับโชว์ Error จาก Firebase (เช่น อีเมลซ้ำ)
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: AppTheme.danger, fontSize: 12)),
                  const SizedBox(height: 12),
                ],

                PrimaryButton(
                  label: 'Create Account',
                  // 5. ปุ่มกดได้เสมอ ไม่ต้องเช็ค _canSubmit แล้ว
                  onTap: _loading ? null : _register,
                  loading: _loading,
                ),
                const SizedBox(height: 20),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Already have an account? ',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: const Text('Sign In',
                        style: TextStyle(fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.w600)),
                  ),
                ]),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// SHARED WIDGETS
// ══════════════════════════════════════════════════════════
class _Logo extends StatelessWidget {
  final String subtitle;
  const _Logo({this.subtitle = 'Find your anime collectibles'});

  @override
  Widget build(BuildContext context) => Column(children: [
    Container(
      width: 120, height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: AppTheme.accent.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: ClipOval(
        child: Image.asset('assets/2goodsMate_logo.png', fit: BoxFit.cover),
      ),
    ),
    const SizedBox(height: 16),
    RichText(
      text: const TextSpan(
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        children: [
          TextSpan(text: '2Goods', style: TextStyle(color: AppTheme.textPrimary)),
          TextSpan(text: 'Mate',   style: TextStyle(color: AppTheme.accent)),
        ],
      ),
    ),
    const SizedBox(height: 6),
    Text(subtitle, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
  ]);
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 0.6)),
  );
}