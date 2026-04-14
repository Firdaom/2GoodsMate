import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/services/error_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anigoods/core/router/app_router.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/features/auth/services/auth_service.dart';

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
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  //  สร้างตัวจับโฟกัส (FocusNode)
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  // ตัวแปรเช็คว่า "เคยคลิกเข้าแล้วออกหรือยัง?" (Touched)
  bool _emailTouched = false;
  bool _passwordTouched = false;
  bool _confirmTouched = false;

  //ตัวแปรใหม่สำหรับเช็คการกดติ๊กถูกข้อตกลง
  bool _agreedToTerms = false;

  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  bool _loading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;
  String? _firebaseError;

  @override
  void initState() {
    super.initState();

    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => context.push(RouteNames.terms.path);

    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => context.push(RouteNames.privacy.path);

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
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  String? get _emailError {
    if (!_emailTouched) return null;
    final text = _emailCtrl.text.trim();

    if (text.isEmpty) return 'Please enter your email';

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
    setState(() {
      _emailTouched = true;
      _passwordTouched = true;
      _confirmTouched = true;
    });

    if (_emailError != null ||
        _passwordError != null ||
        _confirmError != null) {
      return;
    }

    // เซฟตี้อีกชั้น: ถ้าเผลอกดได้ทั้งที่ยังไม่ติ๊กถูก ให้เด้งออกทันที
    if (!_agreedToTerms) return;

    setState(() {
      _loading = true;
      _firebaseError = null;
    });
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
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                ),
                onChanged: (_) {
                  if (_emailTouched) setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'your@email.com',
                  errorText: _emailError,
                ),
              ),
              const SizedBox(height: 16),

              _FieldLabel('Password'),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordCtrl,
                focusNode: _passwordFocus,
                obscureText: _obscure1,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                ),
                onChanged: (_) {
                  if (_passwordTouched) setState(() {});
                  if (_confirmTouched) setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Min. 8 characters',
                  errorText: _passwordError,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure1 ? Icons.visibility_off : Icons.visibility,
                      color: AppTheme.textMuted,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _FieldLabel('Confirm Password'),
              const SizedBox(height: 6),
              TextField(
                controller: _confirmCtrl,
                focusNode: _confirmFocus,
                obscureText: _obscure2,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                ),
                onChanged: (_) {
                  if (_confirmTouched) setState(() {});
                },
                onSubmitted: (_) => _register(),
                decoration: InputDecoration(
                  hintText: 'Repeat password',
                  errorText: _confirmError,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure2 ? Icons.visibility_off : Icons.visibility,
                      color: AppTheme.textMuted,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (_firebaseError != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppTheme.danger,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _firebaseError!,
                      style: const TextStyle(
                        color: AppTheme.danger,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              //  Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreedToTerms = value ?? false;
                        });
                      },
                      activeColor: AppTheme.accent, // สีกล่องตอนติ๊กถูก
                      checkColor: AppTheme.background, // สีเครื่องหมายถูก
                      side: const BorderSide(
                        color: AppTheme.textMuted,
                        width: 1.5,
                      ), // สีกล่องตอนยังไม่ติ๊ก
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ), // ลบมุมกล่องนิดนึง
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: _termsRecognizer,
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: _privacyRecognizer,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // อัปเดตปุ่ม Create Account
              PrimaryButton(
                label: 'Create Account',
                //  เช็คเงื่อนไข: ถ้ากำลังโหลด หรือ ยังไม่ติ๊กถูก ให้ปุ่มเป็น null (กดไม่ได้)
                onTap: (_loading || !_agreedToTerms) ? null : _register,
                loading: _loading,
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  GestureDetector(
                    onTap: () => context.go(RouteNames.login.path),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
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
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset('assets/logo.png', fit: BoxFit.cover),
        ),
      ),
      const SizedBox(height: 16),
      RichText(
        text: const TextSpan(
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          children: [
            TextSpan(
              text: '2Goods',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            TextSpan(
              text: 'Mate',
              style: TextStyle(color: AppTheme.accent),
            ),
          ],
        ),
      ),
      const SizedBox(height: 6),
      Text(
        subtitle,
        style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
      ),
    ],
  );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppTheme.textMuted,
        letterSpacing: 0.6,
      ),
    ),
  );
}
