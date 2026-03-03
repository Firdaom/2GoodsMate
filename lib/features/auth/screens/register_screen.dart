import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anigoods/core/router/app_router.dart';


// ══════════════════════════════════════════════════════════
// REGISTER SCREEN
// ══════════════════════════════════════════════════════════
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

  bool get _passwordsMatch =>
      _confirmCtrl.text.isEmpty || _passwordCtrl.text == _confirmCtrl.text;

  bool get _canSubmit =>
      _emailCtrl.text.isNotEmpty &&
      _passwordCtrl.text.isNotEmpty &&
      _passwordCtrl.text.length >= 8 &&
      _confirmCtrl.text.isNotEmpty &&
      _passwordCtrl.text == _confirmCtrl.text;

  Future<void> _register() async {
  if (!_canSubmit) return;
  setState(() { _loading = true; _error = null; });
  try {
    // Create Firebase Auth account
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    
    // ✅ สร้าง user document ใน Firestore
    final email = _emailCtrl.text.trim();
    final username = email.split('@')[0]; 
    
    await FirebaseFirestore.instance
        .collection('users')
        .doc(credential.user!.uid)
        .set({
      'email': email,
      'name': username, // ชื่อเริ่มต้นจาก email
      'username': username, // username เริ่มต้นจาก email
      'avatar': '🎨', // อีโมจิเริ่มต้น
      'watchlist': [],  // เริ่มต้นเป็น array เปล่า
      'notificationKeywords': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // Send verification email
    //await credential.user?.sendEmailVerification();
    
    if (mounted) {
      context.go(RouteNames.home.path);
    }
  } on FirebaseAuthException catch (e) {
    debugPrint('Firebase Error: ${e.code} - ${e.message}');
    setState(() => _error = e.message ?? 'Account creation failed');
  } catch (e) {
    debugPrint('Unexpected Error: $e');
    setState(() => _error = 'An unexpected error occurred');
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
              _Logo(subtitle: 'Join the collector community'),
              const SizedBox(height: 40),

              _FieldLabel('Email'),
              const SizedBox(height: 6),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(hintText: 'your@email.com'),
              ),
              const SizedBox(height: 16),

              _FieldLabel('Password'),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscure1,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Min. 8 characters',
                  errorText: _passwordCtrl.text.isNotEmpty && _passwordCtrl.text.length < 8 ? 'Min. 8 characters required' : null,
                  errorStyle: const TextStyle(color: AppTheme.danger, fontSize: 11),
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
                obscureText: _obscure2,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _register(),
                decoration: InputDecoration(
                  hintText: 'Repeat password',
                  errorText: _passwordsMatch ? null : 'Passwords do not match',
                  errorStyle: const TextStyle(color: AppTheme.danger, fontSize: 11),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.textMuted, size: 18),
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: AppTheme.danger, fontSize: 12)),
                const SizedBox(height: 12),
              ],

              _PrimaryButton(
                label: 'Create Account',
                onTap: _canSubmit && !_loading ? _register : null,
                loading: _loading,
              ),
              const SizedBox(height: 20),

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Already have an account? ',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
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

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  const _PrimaryButton({required this.label, this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: enabled ? const LinearGradient(colors: [AppTheme.accent, AppTheme.accentDark]) : null,
          color: enabled ? null : AppTheme.border,
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [BoxShadow(color: AppTheme.accent.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 4))]
              : null,
        ),
        child: Center(
          child: loading
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(label,
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: enabled ? Colors.white : AppTheme.textMuted,
                  )),
        ),
      ),
    );
  }
}
