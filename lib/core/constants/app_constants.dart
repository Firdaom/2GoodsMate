import 'package:flutter/material.dart';

class AppConstants {
  
  // ─── Timeouts ─────────────────────────────────────
  static const Duration imageUploadTimeout = Duration(seconds: 60);
  static const Duration firestoreSaveTimeout = Duration(seconds: 30);
  
  // ─── SnackBar Durations ───────────────────────────
  static const Duration successSnackBarDuration = Duration(seconds: 3);
  static const Duration errorSnackBarDuration = Duration(seconds: 5);
}

// ═══════════════════════════════════════════════════
// FIREBASE CONSTANTS
// ═══════════════════════════════════════════════════

/// Firestore collection names
class FirebaseCollections {
  static const String users = 'users';
  static const String items = 'items';
  static const String reports = 'reports';
}

/// Firestore field names for User collection
class UserFields {
  static const String name = 'name';
  static const String username = 'username';
  static const String email = 'email';
  static const String avatar = 'avatar';
  static const String profileImageUrl = 'profileImageUrl';
  static const String watchlist = 'watchlist';
  static const String notificationKeywords = 'notificationKeywords';
  static const String isVerified = 'isVerified';
  static const String createdAt = 'createdAt';
}

/// Firestore field names for Item collection
class ItemFields {
  static const String title = 'title';
  static const String series = 'series';
  static const String category = 'category';
  static const String rarity = 'rarity';
  static const String price = 'price';
  static const String condition = 'condition';
  static const String imageUrl = 'imageUrl';
  static const String sellerId = 'sellerId';
  static const String sellerName = 'sellerName';
  static const String sellerVerified = 'sellerVerified';
  static const String description = 'description';
  static const String tags = 'tags';
  static const String contactLinks = 'contactLinks';
  static const String postedAt = 'postedAt';
  static const String moderationStatus = 'moderationStatus';
  static const String qualityScore = 'qualityScore';
  static const String reportCount = 'reportCount';
  static const String flaggedAt = 'flaggedAt';
}

/// Firebase Auth error codes
class AuthErrorCodes {
  static const String userNotFound = 'user-not-found';
  static const String wrongPassword = 'wrong-password';
  static const String invalidCredential = 'invalid-credential';
  static const String invalidEmail = 'invalid-email';
  static const String emailAlreadyInUse = 'email-already-in-use';
  static const String weakPassword = 'weak-password';
  static const String tooManyRequests = 'too-many-requests';
}

/// Firebase Storage paths
class StoragePaths {
  static const String itemImages = 'items';
  static const String profileImages = 'profile_images';
}