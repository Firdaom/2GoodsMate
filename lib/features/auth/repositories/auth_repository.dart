import 'package:firebase_auth/firebase_auth.dart';
import 'package:anigoods/core/exceptions/app_exception.dart';

/// Repository handling all authentication operations
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Register with email and password
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Convert Firebase Auth exceptions to AppException
  AppException _handleAuthException(FirebaseAuthException e) {
    final userMessage = _getUserFriendlyMessage(e.code);
    return AppException(
      message: userMessage,
      code: e.code,
      originalError: e,
    );
  }

  /// Get user-friendly message for each auth error code
  String _getUserFriendlyMessage(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-email':
        return 'Invalid email or password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later';
      case 'weak-password':
        return 'Password is too weak';
      case 'email-already-in-use':
        return 'Email is already in use';
      case 'operation-not-allowed':
        return 'Email/password registration is disabled';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'Authentication failed';
    }
  }
}