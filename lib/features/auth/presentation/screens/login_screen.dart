import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:anigoods/core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _emailCtrl.text.isNotEmpty && _passwordCtrl.text.isNotEmpty;

  Future<void> _signIn() async {
    if (!_canSubmit) return;
    setState(() { _loading = true; _error = null; });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (mounted) {
      context.goNamed('home'); 
      }
      
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Error Code: ${e.code}');
      debugPrint('Firebase Error Message: ${e.message}');
      setState(() => _error = e.message ?? 'Authentication failed');
    } catch (e) {
      debugPrint('Unexpected Error: $e');
      setState(() => _error = 'An unexpected error occurred');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createAccount() async {
    if (!_canSubmit) return;
    setState(() { _loading = true; _error = null; });
    try {
      // Create user account
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      
      // Send email verification
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      
      // Navigate to verify email screen
      if (mounted) {
        context.goNamed('verify-email');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Error Code: ${e.code}');
      debugPrint('Firebase Error Message: ${e.message}');
      setState(() => _error = e.message ?? 'Account creation failed');
    } catch (e) {
      debugPrint('Unexpected Error: $e');
      setState(() => _error = 'An unexpected error occurred');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _navigateToRegister() {
    context.goNamed('register');
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

              // Logo
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withOpacity(0.25),
                      blurRadius: 20, offset: const Offset(0, 6),
                    ),
                  ],
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
                    TextSpan(text: '2Goods',
                        style: TextStyle(color: AppTheme.textPrimary)),
                    TextSpan(text: 'Mate',
                        style: TextStyle(color: AppTheme.accent)),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Find your anime collectibles',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 48),

              // Email
              _label('Email'),
              const SizedBox(height: 6),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(hintText: 'your@email.com'),
              ),
              const SizedBox(height: 16),

              // Password
              _label('Password'),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscure,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _signIn(),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  helperText: _passwordCtrl.text.isNotEmpty && _passwordCtrl.text.length < 8 
                    ? '${_passwordCtrl.text.length}/8 characters'
                    : null,
                  helperStyle: TextStyle(
                    fontSize: 11, 
                    color: _passwordCtrl.text.length < 8 ? AppTheme.danger : AppTheme.textMuted,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppTheme.textMuted, size: 18,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Error
              if (_error != null) ...[
                Text(_error!,
                    style: const TextStyle(color: AppTheme.danger, fontSize: 12)),
                const SizedBox(height: 12),
              ],

              // Sign In
              _PrimaryButton(
                label: 'Sign In',
                onTap: _canSubmit && !_loading ? _signIn : null,
                loading: _loading,
              ),
              const SizedBox(height: 16),

              // Forgot
              GestureDetector(
                onTap: () {},
                child: const Text('Forgot password?',
                    style: TextStyle(
                      fontSize: 12, color: AppTheme.accent,
                      fontWeight: FontWeight.w500,
                    )),
              ),

              // Divider
              const SizedBox(height: 24),
              const Row(children: [
                Expanded(child: Divider(color: AppTheme.border)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('OR',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                ),
                Expanded(child: Divider(color: AppTheme.border)),
              ]),
              const SizedBox(height: 24),

              // Create Account
              GestureDetector(
                onTap: _navigateToRegister,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.accent),
                  ),
                  child: Center(
                    child: Text('Create Account',
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: AppTheme.accent,
                        )),
                  ),
                ),
              ),

              const SizedBox(height: 40),
              const Text(
                'By continuing, you agree to our\nTerms of Service and Privacy Policy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11, color: AppTheme.textMuted, height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(text.toUpperCase(),
            style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: AppTheme.textMuted, letterSpacing: 0.6,
            )),
      );
}

// ─── Shared Primary Button ────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;

  const _PrimaryButton({
    required this.label,
    this.onTap,
    this.loading = false,
  });

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
          gradient: enabled
              ? const LinearGradient(
                  colors: [AppTheme.accent, AppTheme.accentDark])
              : null,
          color: enabled ? null : AppTheme.border,
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [BoxShadow(
                  color: AppTheme.accent.withOpacity(0.25),
                  blurRadius: 16, offset: const Offset(0, 4),
                )]
              : null,
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white,
                  ))
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: enabled ? Colors.white : AppTheme.textMuted,
                  ),
                ),
        ),
      ),
    );
  }
}
