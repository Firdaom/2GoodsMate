import 'package:anigoods/core/constants/firebase_constants.dart';
import 'package:anigoods/core/exceptions/app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final homeRepositoryProvider = Provider((ref) => HomeRepository(
  firestore: FirebaseFirestore.instance,
));

class HomeRepository {
  final FirebaseFirestore _firestore;

  HomeRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  /// ดึงรายการ Watchlist ของ User
  Future<List<String>> getWatchlist(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .get();
      if (doc.exists) {
        return List<String>.from(doc.data()?[UserFields.watchlist] ?? []);
      }
      return [];
    } on FirebaseException catch (e) {
      throw AppException(
        message: e.message ?? 'Failed to load watchlist',
        code: e.code,
        originalError: e,
      );
    }
  }

  /// เพิ่มไอเทมเข้า Watchlist
  Future<void> addToWatchlist({
    required String uid,
    required String itemId,
  }) async {
    try {
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .update({
            UserFields.watchlist: FieldValue.arrayUnion([itemId])
          });
    } on FirebaseException catch (e) {
      throw AppException(
        message: e.message ?? 'Failed to add to watchlist',
        code: e.code,
        originalError: e,
      );
    }
  }

  /// ลบไอเทมออกจาก Watchlist
  Future<void> removeFromWatchlist({
    required String uid,
    required String itemId,
  }) async {
    try {
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .update({
            UserFields.watchlist: FieldValue.arrayRemove([itemId])
          });
    } on FirebaseException catch (e) {
      throw AppException(
        message: e.message ?? 'Failed to remove from watchlist',
        code: e.code,
        originalError: e,
      );
    }
  }

}