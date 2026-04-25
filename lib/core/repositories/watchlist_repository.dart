import 'package:anigoods/core/constants/firebase_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final watchlistRepositoryProvider = Provider((ref) => WatchlistRepository(
  firestore: FirebaseFirestore.instance,
));

class WatchlistRepository {
  final FirebaseFirestore _firestore;

  WatchlistRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  /// ดึงรายชื่อ Item ID ที่ผู้ใช้กดถูกใจไว้ 
  Future<List<String>> getWatchlist(String uid) async {
    try {
      final doc = await _firestore.collection(FirebaseCollections.users).doc(uid).get();
      if (doc.exists) {
        return List<String>.from(doc.data()?[UserFields.watchlist] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting watchlist: $e');
      return [];
    }
  }

  ///  สลับสถานะ 
  Future<void> toggleWatchlist({
    required String uid, 
    required String itemId, 
    required bool isCurrentlySaved
  }) async {
    try {
      final userDocRef = _firestore.collection(FirebaseCollections.users).doc(uid);
      
      if (isCurrentlySaved) {
        // ถ้า UI บอกว่าเซฟไว้อยู่ -> สั่งลบ
        await userDocRef.update({
          UserFields.watchlist: FieldValue.arrayRemove([itemId])
        });
      } else {
        // ถ้า UI บอกว่ายังไม่เซฟ -> สั่งเพิ่ม
        await userDocRef.update({
          UserFields.watchlist: FieldValue.arrayUnion([itemId])
        });
      }
    } catch (e) {
      debugPrint('Error toggling watchlist: $e');
      rethrow;
    }
  }
}