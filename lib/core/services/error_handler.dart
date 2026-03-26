import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/exceptions/app_exception.dart';

/// ════════════════════════════════════════════════════════
/// ERROR HANDLER SERVICE
/// ────────────────────────────────────────────────────────
/// ✅ User-friendly messages for UI
/// ✅ Detailed logging for developers
/// ✅ Consistent error handling across all screens
/// ════════════════════════════════════════════════════════

class ErrorHandler {
  /// Get user-friendly error message from exception
  static String getUserMessage(dynamic error) {
    // App Exception (custom errors from repositories)
    if (error is AppException) {
      return error.message;
    }

    // Firebase Auth Errors
    if (error is FirebaseAuthException) {
      switch (error.code) {
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

    // Firebase/Firestore Errors
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Permission denied. Please sign in again';
        case 'not-found':
          return 'Item not found';
        case 'already-exists':
          return 'This item already exists';
        case 'failed-precondition':
          return 'Cannot perform this action at this time';
        case 'aborted':
          return 'Operation was cancelled';
        case 'unavailable':
          return 'Service temporarily unavailable';
        case 'deadline-exceeded':
          return 'Request timed out. Please try again';
        case 'unauthenticated':
          return 'Please sign in to continue';
        default:
          return 'Something went wrong. Please try again';
      }
    }

    // Generic errors
    if (error is String) {
      return error.isEmpty ? 'An error occurred' : error;
    }

    return 'An unexpected error occurred';
  }

  /// Log detailed error information for developers
  static void logError(
    String context,
    dynamic error, {
    StackTrace? stackTrace,
  }) {
    debugPrint('┌─────────────────────────────────────────');
    debugPrint('│ ERROR in $context');
    debugPrint('├─────────────────────────────────────────');

    if (error is AppException) {
      debugPrint('│ Type: App Exception');
      debugPrint('│ Code: ${error.code}');
      debugPrint('│ Message: ${error.message}');
      if (error.originalError != null) {
        debugPrint('│ Original Error: ${error.originalError}');
      }
    } else if (error is FirebaseAuthException) {
      debugPrint('│ Type: Firebase Auth Exception');
      debugPrint('│ Code: ${error.code}');
      debugPrint('│ Message: ${error.message}');
    } else if (error is FirebaseException) {
      debugPrint('│ Type: Firebase Exception');
      debugPrint('│ Code: ${error.code}');
      debugPrint('│ Message: ${error.message}');
    } else {
      debugPrint('│ Type: ${error.runtimeType}');
      debugPrint('│ Error: $error');
    }

    if (stackTrace != null) {
      debugPrint('│ Stack Trace:');
      debugPrint(stackTrace.toString());
    }
    debugPrint('└─────────────────────────────────────────');
  }

  /// Show error via ScaffoldMessenger
  static void showError(
    BuildContext context,
    dynamic error, {
    String? contextLabel,
    Duration duration = const Duration(seconds: 4),
  }) {
    logError(contextLabel ?? 'Unknown', error);

    final userMessage = getUserMessage(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(userMessage),
        backgroundColor: AppTheme.danger,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show info/warning message
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? AppTheme.accentDark,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success message
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.success,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
