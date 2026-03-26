import 'package:anigoods/core/constants/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WatchlistRepository {
  // ✅ ย้ายจาก home_screen.dart:36-43
  Future<List<String>> getWatchlist(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection(FirebaseCollections.users)
        .doc(uid)
        .get();
    return List<String>.from(doc[UserFields.watchlist] ?? []);
  }
  
  // ✅ ย้ายจาก home_screen.dart:45-56
  Future<void> toggleWatchlist(String uid, String itemId) async {
    // ดึงสถานะปัจจุบันจาก server ก่อน (ปลอดภัยกว่า)
    final currentList = await getWatchlist(uid);
    final updated = currentList.contains(itemId)
        ? currentList.where((id) => id != itemId).toList()
        : [...currentList, itemId];
    
    await FirebaseFirestore.instance
        .collection(FirebaseCollections.users)
        .doc(uid)
        .update({UserFields.watchlist: updated});
  }
}