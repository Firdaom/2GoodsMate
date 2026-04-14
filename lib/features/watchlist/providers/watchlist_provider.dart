import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:anigoods/core/constants/firebase_constants.dart';

final watchlistProvider = StateNotifierProvider<WatchlistNotifier, Set<String>>((ref) {
  return WatchlistNotifier();
});

class WatchlistNotifier extends StateNotifier<Set<String>> {
  WatchlistNotifier() : super({}) {

    _loadInitialWatchlist();
  }

  Future<void> _loadInitialWatchlist() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection(FirebaseCollections.users).doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final List<dynamic> savedWatchlist = doc.data()?[UserFields.watchlist] ?? [];
        state = Set<String>.from(savedWatchlist);
      }
    } catch (e) {
      print("Error loading watchlist: $e");
    }
  }

  Future<void> toggle(String itemId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final isSaved = state.contains(itemId);


    if (isSaved) {
      state = {...state}..remove(itemId);
    } else {
      state = {...state}..add(itemId);
    }

    try {
      final userRef = FirebaseFirestore.instance.collection(FirebaseCollections.users).doc(uid);
      if (isSaved) {
        await userRef.update({
          UserFields.watchlist: FieldValue.arrayRemove([itemId])
        });
      } else {
        await userRef.update({
          UserFields.watchlist: FieldValue.arrayUnion([itemId])
        });
      }
    } catch (e) {
      print("Error updating Firestore: $e");
      
      if (isSaved) {
        state = {...state}..add(itemId);
      } else {
        state = {...state}..remove(itemId);
      }
    }
  }
}