import 'package:anigoods/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anigoods/core/exceptions/app_exception.dart';
import 'package:anigoods/core/constants/firebase_constants.dart';

class ErrorHandler {
  /// Get user-friendly error message from exception
  static String getUserMessage(dynamic error) {
    // 1. Custom App Exceptions
    if (error is AppException) return error.message;

    // 2. Firebase Auth Errors
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case AuthErrorCodes.userNotFound:
        case AuthErrorCodes.wrongPassword:
        case AuthErrorCodes.invalidCredential:
        case AuthErrorCodes.invalidEmail:
          return 'Invalid email or password';
        case AuthErrorCodes.userDisabled:
          return 'This account has been disabled';
        case AuthErrorCodes.tooManyRequests:
          return 'Too many login attempts. Please try again later';
        case AuthErrorCodes.weakPassword:
          return 'Password is too weak';
        case AuthErrorCodes.emailAlreadyInUse:
          return 'Email is already in use';
        case AuthErrorCodes.operationNotAllowed:
          return 'Email/password registration is disabled';
        case AuthErrorCodes.networkRequestFailed:
          return 'Network error. Please check your connection';
        default:
          return 'Authentication failed';
      }
    }

    // 3. Firebase Core / Firestore / Storage Errors
    if (error is FirebaseException) {
      switch (error.code) {
        // ─── Firestore Errors ───────────────────────────
        case FirestoreErrorCodes.permissionDenied:
          return 'Permission denied. Please sign in again';
        case FirestoreErrorCodes.notFound:
          return 'Item not found';
        case FirestoreErrorCodes.alreadyExists:
          return 'This item already exists';
        case FirestoreErrorCodes.failedPrecondition:
          return 'Cannot perform this action at this time';
        case FirestoreErrorCodes.aborted:
          return 'Operation was cancelled';
        case FirestoreErrorCodes.unavailable:
          return 'Service temporarily unavailable';
        case FirestoreErrorCodes.deadlineExceeded:
          return 'Request timed out. Please try again';
        case FirestoreErrorCodes.unauthenticated:
          return 'Please sign in to continue';
          
        // ─── Storage Errors ─────────────────────────────
        case StorageErrorCodes.unauthorized:
          return 'You do not have permission to upload images';
        case StorageErrorCodes.canceled:
          return 'Upload was cancelled';
        case StorageErrorCodes.objectNotFound:
          return 'File not found';
        case StorageErrorCodes.quotaExceeded:
          return 'Storage quota exceeded';
        case StorageErrorCodes.unauthenticated: // บางที storage จะใช้ตัวนี้
          return 'Please sign in to upload images';
        case StorageErrorCodes.retryLimitExceeded:
          return 'Upload timeout. Please try again';

        default:
          return 'Something went wrong. Please try again';
      }
    }

    // 4. Generic errors (เช่น ส่ง String เข้ามาตรงๆ)
    if (error is String) {
      return error.isEmpty ? 'An error occurred' : error;
    }

    // 5. Fallback
    return 'An unexpected error occurred';
  }

  /// Log detailed error information for developers
  static void logError(String context, dynamic error, {StackTrace? stackTrace}) {
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
      debugPrint('│ Type: Firebase Exception (Firestore/Storage)');
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

static void showError(BuildContext context, dynamic error, {String? contextLabel}) {
    final String message = getUserMessage(error); 
    
    logError(contextLabel ?? 'UI Error', error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontSize: 13)),
        backgroundColor: AppTheme.danger, 
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontSize: 13)),
        backgroundColor: AppTheme.success, 
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}