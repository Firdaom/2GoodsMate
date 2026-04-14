import 'package:anigoods/core/constants/firebase_constants.dart'; // ✅ เช็คชื่อไฟล์ Constant ของคุณ
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
      final doc = await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .get();
      
      if (doc.exists) {
        final data = doc.data();
        return List<String>.from(data?[UserFields.watchlist] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('🔥 Error getting watchlist: $e');
      return [];
    }
  }

  /// สลับสถานะ ถูกใจ/ไม่ถูกใจ
  Future<void> toggleWatchlist(String uid, String itemId) async {
    try {
      final userDocRef = _firestore.collection(FirebaseCollections.users).doc(uid);
      final doc = await userDocRef.get();
      
      if (!doc.exists) return;

      final currentList = List<String>.from(doc.data()?[UserFields.watchlist] ?? []);
      
      if (currentList.contains(itemId)) {
        // ถ้ามีอยู่แล้ว ให้ลบออก
        await userDocRef.update({
          UserFields.watchlist: FieldValue.arrayRemove([itemId])
        });
      } else {
        // ถ้ายังไม่มี ให้เพิ่มเข้า
        await userDocRef.update({
          UserFields.watchlist: FieldValue.arrayUnion([itemId])
        });
      }
    } catch (e) {
      debugPrint('🔥 Error toggling watchlist: $e');
      rethrow;
    }
  }
}