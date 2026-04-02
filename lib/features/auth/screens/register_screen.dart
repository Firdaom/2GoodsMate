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
  final _authService = AuthService();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  
  // 🎯 1. สร้างตัวจับโฟกัส (FocusNode)
  final _emailFocus    = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus  = FocusNode();

  // 🎯 2. ตัวแปรเช็คว่า "เคยคลิกเข้าแล้วออกหรือยัง?" (Touched)
  bool _emailTouched    = false;
  bool _passwordTouched = false;
  bool _confirmTouched  = false;

  bool _loading  = false;
  bool _obscure1 = true;
  bool _obscure2 = true;
  String? _firebaseError;

  @override
  void initState() {
    super.initState();
    // 🎯 3. ดักฟัง! ถ้าเสียโฟกัส (คลิกออก) ให้ตั้งค่า Touched เป็น true แล้วสั่งอัปเดตหน้าจอ
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) setState(() => _emailTouched = true);
    });
    _passwordFocus.addListener(() {
      if (!_passwordFocus.hasFocus) setState(() => _passwordTouched = true);
    });
    _confirmFocus.addListener(() {
      if (!_confirmFocus.hasFocus) setState(() => _confirmTouched = true);
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  String? get _emailError {
    if (!_emailTouched) return null; 
    final text = _emailCtrl.text.trim();
    
    if (text.isEmpty) return 'Please enter your email';
    
    // 👇 ใช้ Regex ตรวจสอบว่าต้องเป็นรูปแบบ อีเมล@โดเมน.com เท่านั้น
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(text)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  String? get _passwordError {
    if (!_passwordTouched) return null;
    final text = _passwordCtrl.text;
    if (text.isEmpty) return 'Please enter a password';
    if (text.length < 8) return 'Min. 8 characters required';
    return null;
  }

  String? get _confirmError {
    if (!_confirmTouched) return null;
    final text = _confirmCtrl.text;
    if (text.isEmpty) return 'Please confirm your password';
    if (text != _passwordCtrl.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _register() async {
    // 🎯 5. พอกดปุ่ม Create ให้บังคับ Touched เป็น true ให้หมด (เผื่อคนไม่พิมพ์อะไรเลยแล้วกดปุ่ม)
    setState(() {
      _emailTouched = true;
      _passwordTouched = true;
      _confirmTouched = true;
    });

    // ถ้ามี Error แม้แต่ช่องเดียว ให้หยุดการทำงาน
    if (_emailError != null || _passwordError != null || _confirmError != null) {
      return;
    }

    setState(() { _loading = true; _firebaseError = null; });
    try {
      await _authService.registerWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      if (mounted) {
        context.go(RouteNames.home.path);
      }
    } catch (e) {
      ErrorHandler.logError('register_screen._register()', e);
      setState(() => _firebaseError = ErrorHandler.getUserMessage(e));
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
          child: Column(
            children: [
              const SizedBox(height: 60),
              const _Logo(subtitle: 'Join the collector community'),
              const SizedBox(height: 40),

              _FieldLabel('Email'),
              const SizedBox(height: 6),
              TextField(
                controller: _emailCtrl,
                focusNode: _emailFocus, // 👈 ผูก FocusNode
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                onChanged: (_) {
                  // ถ้าเคยผิดไปแล้ว พอกลับมาแก้ให้มันหายแดงทันที (Real-time เฉพาะตอนแก้)
                  if (_emailTouched) setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'your@email.com',
                  errorText: _emailError, // 👈 โชว์ข้อความ Error อัตโนมัติ (ถ้ามี)
                ),
              ),
              const SizedBox(height: 16),

              _FieldLabel('Password'),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordCtrl,
                focusNode: _passwordFocus, // 👈 ผูก FocusNode
                obscureText: _obscure1,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                onChanged: (_) {
                  if (_passwordTouched) setState(() {});
                  if (_confirmTouched) setState(() {}); // อัปเดตช่องล่างด้วยเผื่อรหัสตรงกันแล้ว
                },
                decoration: InputDecoration(
                  hintText: 'Min. 8 characters',
                  errorText: _passwordError, // 👈 โชว์ข้อความ Error
                  suffixIcon: IconButton(
                    icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.textMuted, size: 18),
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _FieldLabel('Confirm Password'),
              const SizedBox(height: 6),
              TextField(
                controller: _confirmCtrl,
                focusNode: _confirmFocus, // 👈 ผูก FocusNode
                obscureText: _obscure2,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                onChanged: (_) {
                  if (_confirmTouched) setState(() {});
                },
                onSubmitted: (_) => _register(),
                decoration: InputDecoration(
                  hintText: 'Repeat password',
                  errorText: _confirmError, // 👈 โชว์ข้อความ Error
                  suffixIcon: IconButton(
                    icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.textMuted, size: 18),
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (_firebaseError != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.danger, size: 16),
                    const SizedBox(width: 8),
                    Text(_firebaseError!, style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              PrimaryButton(
                label: 'Create Account',
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