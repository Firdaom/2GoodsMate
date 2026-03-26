import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:anigoods/core/constants/app_constants.dart';

/// Repository handling profile-specific operations
class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Update user notification keywords
  Future<void> updateNotificationKeywords({
    required String uid,
    required List<String> keywords,
  }) async {
    try {
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .set(
            {UserFields.notificationKeywords: keywords},
            SetOptions(merge: true),
          );
    } catch (e) {
      debugPrint('Error updating notification keywords: $e');
      rethrow;
    }
  }

  /// Get user notification keywords
  Future<List<String>> getNotificationKeywords(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .get();
      if (doc.exists) {
        return List<String>.from(doc[UserFields.notificationKeywords] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching notification keywords: $e');
      rethrow;
    }
  }
}