import 'package:anigoods/core/constants/app_constants.dart';
import 'package:anigoods/core/exceptions/app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Repository handling home screen operations
class HomeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get user's watchlist (list of item IDs)
  Future<List<String>> getWatchlist(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .get();
      if (doc.exists) {
        return List<String>.from(doc[UserFields.watchlist] ?? []);
      }
      return [];
    } on FirebaseException catch (e) {
      throw AppException(
        message: _getWatchlistUserMessage(e.code),
        code: e.code,
        originalError: e,
      );
    }
  }

  /// Add item to watchlist
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
        message: _getWatchlistUserMessage(e.code),
        code: e.code,
        originalError: e,
      );
    }
  }

  /// Remove item from watchlist
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
        message: _getWatchlistUserMessage(e.code),
        code: e.code,
        originalError: e,
      );
    }
  }

  /// Update entire watchlist
  Future<void> updateWatchlist({
    required String uid,
    required List<String> watchlist,
  }) async {
    try {
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .update({UserFields.watchlist: watchlist});
    } on FirebaseException catch (e) {
      throw AppException(
        message: _getWatchlistUserMessage(e.code),
        code: e.code,
        originalError: e,
      );
    }
  }

  /// Get user-friendly message for watchlist operations
  String _getWatchlistUserMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'Permission denied. Please sign in again';
      case 'not-found':
        return 'Watchlist not found';
      case 'failed-precondition':
        return 'Cannot update watchlist at this time';
      case 'unavailable':
        return 'Service temporarily unavailable';
      case 'deadline-exceeded':
        return 'Request timed out. Please try again';
      case 'unauthenticated':
        return 'Please sign in to continue';
      default:
        return 'Failed to update watchlist. Please try again';
    }
  }
}