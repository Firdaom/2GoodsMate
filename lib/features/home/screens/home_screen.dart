import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/core/constants/app_constants.dart';
import 'package:anigoods/features/home/repositories/home_repository.dart';
import 'package:anigoods/core/router/app_router.dart';
import 'package:anigoods/core/providers/search_provider.dart'; 
import 'package:anigoods/core/widgets/search_filter_widget.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _toggleWatchlist(String itemId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final homeRepo = HomeRepository();

    try {
      final watchlist = await homeRepo.getWatchlist(uid);
      if (watchlist.contains(itemId)) {
        await homeRepo.removeFromWatchlist(uid: uid, itemId: itemId);
      } else {
        await homeRepo.addToWatchlist(uid: uid, itemId: itemId);
      }
    } catch (e) {
      debugPrint('Error toggling watchlist: $e');
    }
  }

  Query _buildFirestoreQuery(String category, String rarity) {
    Query query = FirebaseFirestore.instance.collection(FirebaseCollections.items);
    if (category != 'All') query = query.where('category', isEqualTo: category);
    if (rarity != 'All') query = query.where('rarity', isEqualTo: rarity);
    return query.orderBy(ItemFields.postedAt, descending: true);
  }

  Widget _buildHeader(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            children: [
              TextSpan(text: '2Goods', style: TextStyle(color: AppTheme.textPrimary)),
              TextSpan(text: 'Mate', style: TextStyle(color: AppTheme.accent)),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.push(RouteNames.notifications.path), 
          child: const Icon(Icons.notifications_active, size: 22,color: AppTheme.accent),
        ),
      ],
    ),
  );

  Widget _renderItems(BuildContext context, List<ItemModel> items, List<String> watchlist) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '${items.length} ITEM${items.length != 1 ? "S" : ""} FOUND',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 0.4),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Text('No items match your search.', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                )
              : ListView.builder(
                  key: const PageStorageKey<String>('home_items'),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: items.length,
                  itemBuilder: (_, i) => ItemCard(
                    key: ValueKey(items[i].id),
                    item: items[i],
                    isWatchlisted: watchlist.contains(items[i].id),
                    onTap: () => context.push(
                      RouteNames.itemDetail.path,
                      extra: {
                        'item': items[i],
                        'isWatchlisted': watchlist.contains(items[i].id),
                        'onWatchlistToggle': () => _toggleWatchlist(items[i].id),
                      },
                    ),
                    onWatchlistToggle: () => _toggleWatchlist(items[i].id),
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(homeSearchQueryProvider);
    final category = ref.watch(homeCategoryProvider);
    final rarity = ref.watch(homeRarityProvider);

    return Scaffold(

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            
            // search & filter widget 
            SearchAndFilterWidget(),
            const SizedBox(height: 10),

            // สร้างลิสต์ข้อมูลโดยใช้ตัวแปรจาก Provider
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _buildFirestoreQuery(category, rarity).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final all = snapshot.data?.docs.map((doc) => ItemModel.fromFirestore(doc)).toList() ?? [];
                  
                  // กรองข้อมูลด้วยคำค้นหา
                  final items = query.isEmpty
                      ? all
                      : all.where((item) => item.matchesQuery(query.toLowerCase())).toList();

                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid == null) return _renderItems(context, items, []);

                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection(FirebaseCollections.users).doc(uid).snapshots(),
                    builder: (context, userSnapshot) {
                      final watchlist = userSnapshot.data?.get(UserFields.watchlist) as List<dynamic>? ?? [];
                      final watchlistIds = List<String>.from(watchlist.cast<String>());
                      return _renderItems(context, items, watchlistIds);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}