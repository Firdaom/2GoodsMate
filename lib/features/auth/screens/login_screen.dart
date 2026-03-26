import 'package:anigoods/features/auth/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/services/error_handler.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/core/constants/app_constants.dart';
import 'package:anigoods/core/services/auth_service.dart';
import 'package:anigoods/core/providers/repositories_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authService = AuthService();
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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.signInWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      if (mounted) {
        context.goNamed('home');
      }
    } catch (e) {
      ErrorHandler.logError('login_screen._signIn()', e);
      setState(() => _error = ErrorHandler.getUserMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _navigateToRegister() {
    context.goNamed('register');
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ErrorHandler.showInfo(context, 'Please enter your email address');
      return;
    }

    try {
      final authRepo = AuthRepository();
      await authRepo.sendPasswordResetEmail(email);
      if (mounted) {
        ErrorHandler.showSuccess(context, 'Password reset email sent! Check your inbox.');
      }
    } catch (e) {
      ErrorHandler.showError(context, e, contextLabel: 'login_screen._forgotPassword()');
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

              // Logo
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
                  child: Image.asset(
                    'assets/2goodsMate_logo.png',
                    fit: BoxFit.cover,
                  ),
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
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                ),
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
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _signIn(),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppTheme.textMuted,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Error
              if (_error != null) ...[
                Text(
                  _error!,
                  style: const TextStyle(color: AppTheme.danger, fontSize: 12),
                ),
                const SizedBox(height: 12),
              ],

              // Sign In
              PrimaryButton(
                label: 'Sign In',
                onTap: _canSubmit && !_loading ? _signIn : null,
                loading: _loading,
              ),
              const SizedBox(height: 16),

              // Forgot
              GestureDetector(
                onTap: _forgotPassword,
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Divider
              const SizedBox(height: 24),
              const Row(
                children: [
                  Expanded(child: Divider(color: AppTheme.border)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ),
                  Expanded(child: Divider(color: AppTheme.border)),
                ],
              ),
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
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accent,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
              const Text(
                'By continuing, you agree to our\nTerms of Service and Privacy Policy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                  height: 1.5,
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
