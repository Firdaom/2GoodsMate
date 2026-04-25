import 'package:anigoods/core/constants/firebase_constants.dart';
import 'package:anigoods/features/cart/providers/cart_provider.dart';
import 'package:anigoods/features/watchlist/providers/watchlist_filter_provider.dart';
import 'package:anigoods/core/repositories/watchlist_repository.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final watchlistProvider = StateNotifierProvider<WatchlistNotifier, Set<String>>((ref) {
  ref.watch(authStateProvider);
  
  final repo = ref.read(watchlistRepositoryProvider);
  return WatchlistNotifier(repo);
});

class WatchlistNotifier extends StateNotifier<Set<String>> {
  final WatchlistRepository _repository;

  WatchlistNotifier(this._repository) : super({}) {
    _loadInitialWatchlist();
  }

  Future<void> _loadInitialWatchlist() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final savedWatchlist = await _repository.getWatchlist(uid);
      state = Set<String>.from(savedWatchlist);
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
      await _repository.toggleWatchlist(
        uid: uid, 
        itemId: itemId, 
        isCurrentlySaved: isSaved,
      );
    } catch (e) {
      print("Error updating Firestore: $e");
      //  ถ้ามี Error Revert กลับ
      if (isSaved) {
        state = {...state}..add(itemId);
      } else {
        state = {...state}..remove(itemId);
      }
    }
  }
}


final watchlistItemsProvider = FutureProvider.autoDispose<List<ItemModel>>((ref) async {

  final watchlistIds = ref.watch(watchlistProvider).toList();

  if (watchlistIds.isEmpty) {
    return [];
  }

  final queryStr = ref.watch(watchlistSearchQueryProvider).toLowerCase();
  final category = ref.watch(watchlistCategoryProvider);
  final rarity = ref.watch(watchlistRarityProvider);


  final itemSnapshots = await Future.wait(
    watchlistIds.map((id) => FirebaseFirestore.instance
        .collection(FirebaseCollections.items)
        .doc(id)
        .get())
  );

  // แปลง Document เป็น ItemModel 
  var items = itemSnapshots
      .where((doc) => doc.exists && doc.data() != null)
      .map((doc) => ItemModel.fromFirestore(doc))
      .toList();

  // Client-Side Filtering 
  return items.where((item) {
    final matchQuery = queryStr.isEmpty || 
                       item.title.toLowerCase().contains(queryStr) || 
                       item.series.toLowerCase().contains(queryStr);
    final matchCat = category == 'All' || item.category == category;
    final matchRar = rarity == 'All' || item.rarity == rarity;
    
    return matchQuery && matchCat && matchRar;
  }).toList();
});