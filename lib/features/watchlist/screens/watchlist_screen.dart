import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // เปลี่ยนมาใช้ Riverpod
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/core/constants/app_constants.dart';
import 'package:anigoods/core/router/app_router.dart';
import 'package:anigoods/features/add_item/screens/addItem_screen.dart';
import 'package:anigoods/core/providers/search_provider.dart';
import 'package:anigoods/core/widgets/search_filter_widget.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  Future<void> _remove(String itemId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection(FirebaseCollections.users)
        .doc(uid)
        .update({
      UserFields.watchlist: FieldValue.arrayRemove([itemId])
    });
  }

  Widget _buildHeader(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Watchlist',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddItemScreen()),
              ),
              child: const Icon(
                Icons.add_box_rounded, 
                size: 28,
                color: AppTheme.accent),
            ),
          ],
        ),
      );

  Widget _renderItems(BuildContext context, List<ItemModel> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 10),
          child: Text(
            '${items.length} ITEM${items.length != 1 ? "S" : ""} FOUND',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
              letterSpacing: 0.4,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            key: const PageStorageKey<String>('watchlist_items'),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: items.length,
            itemBuilder: (_, i) => ItemCard(
              key: ValueKey(items[i].id),
              item: items[i],
              isWatchlisted: true,
              onTap: () => context.push(
                RouteNames.itemDetail.path,
                extra: {
                  'item': items[i],
                  'isWatchlisted': true,
                  'onWatchlistToggle': () => _remove(items[i].id),
                },
              ),
              onWatchlistToggle: () => _remove(items[i].id),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //ดึงสถานะจาก Provider ฝั่ง Watchlist เท่านั้น
    final query = ref.watch(watchlistSearchQueryProvider);
    final category = ref.watch(watchlistCategoryProvider);
    final rarity = ref.watch(watchlistRarityProvider);

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            
            const SearchAndFilterWidget(isWatchlist: true),
            
            const SizedBox(height: 16),

            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(FirebaseCollections.users)
                    .doc(uid)
                    .snapshots(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: AppTheme.accent));
                  }

                  final watchlist =
                      List<String>.from(userSnapshot.data?.get('watchlist') ?? []);

                  if (watchlist.isEmpty) {
                    return const EmptyState(
                      emoji: '🔖',
                      title: 'No items yet',
                      subtitle: 'Tap the heart on items\nto save them here',
                    );
                  }

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(FirebaseCollections.items)
                        .where(FieldPath.documentId, whereIn: watchlist)
                        .snapshots(),
                    builder: (context, itemsSnapshot) {
                      if (itemsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.accent));
                      }

                      var items = itemsSnapshot.data?.docs
                              .map((d) => ItemModel.fromFirestore(d))
                              .toList() ??
                          [];

                      // 🔥 3. กรองข้อมูลโดยใช้ค่าจาก Provider ของ Watchlist
                      items = items.where((item) {
                        final q = query.toLowerCase();
                        final matchQ = q.isEmpty || item.matchesQuery(q);
                        final matchCat =
                            category == 'All' || item.category == category;
                        final matchRar =
                            rarity == 'All' || item.rarity == rarity;
                        return matchQ && matchCat && matchRar;
                      }).toList();

                      if (items.isEmpty) {
                        return const Center(
                          child: Text(
                            'No saved items match your search.',
                            style: TextStyle(
                                color: AppTheme.textMuted, fontSize: 13),
                          ),
                        );
                      }

                      return _renderItems(context, items);
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