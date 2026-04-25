import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:anigoods/core/constants/firebase_constants.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';


final profileRepositoryProvider = Provider((ref) => ProfileRepository(
  firestore: FirebaseFirestore.instance,
));

class ProfileRepository {
  final FirebaseFirestore _firestore;

  ProfileRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

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
      debugPrint(' Error updating notification keywords: $e');
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
       
        final data = doc.data();
        if (data != null && data.containsKey(UserFields.notificationKeywords)) {
          return List<String>.from(data[UserFields.notificationKeywords] ?? []);
        }
      }
      return [];
    } catch (e) {
      debugPrint(' Error fetching notification keywords: $e');
      rethrow;
    }
  }
}