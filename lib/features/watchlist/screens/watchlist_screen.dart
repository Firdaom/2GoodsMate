import 'package:anigoods/core/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/core/constants/firebase_constants.dart';
import 'package:anigoods/core/router/app_router.dart';
import 'package:anigoods/core/widgets/search_filter_widget.dart';
import 'package:anigoods/features/watchlist/providers/watchlist_provider.dart';

// ══════════════════════════════════════════════════════════
//  PROVIDERS สำหรับหน้า Watchlist 
// ══════════════════════════════════════════════════════════
final watchlistSearchQueryProvider = StateProvider<String>((ref) => '');
final watchlistCategoryProvider = StateProvider<String>((ref) => 'All');
final watchlistRarityProvider = StateProvider<String>((ref) => 'All');

// ══════════════════════════════════════════════════════════
// 📺 2. WATCHLIST SCREEN
// ══════════════════════════════════════════════════════════
class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final query = ref.watch(watchlistSearchQueryProvider);
    final category = ref.watch(watchlistCategoryProvider);
    final rarity = ref.watch(watchlistRarityProvider);

    final watchlist = ref.watch(watchlistProvider).toList();

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
              child: watchlist.isEmpty
                  ? const EmptyState(
                      icon: Icons.favorite_outline,
                      title: 'No items yet',
                      subtitle: 'Tap the heart on items\nto save them here',
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(FirebaseCollections.items)
                          .where(FieldPath.documentId, whereIn: watchlist)
                          .snapshots(),
                      builder: (context, itemsSnapshot) {
                        if (itemsSnapshot.connectionState == ConnectionState.waiting && !itemsSnapshot.hasData) {
                          return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                        }

                        var items = itemsSnapshot.data?.docs
                                .map((d) => ItemModel.fromFirestore(d))
                                .toList() ?? [];

                        items = items.where((item) {
                          final q = query.toLowerCase();
                          final matchQ = q.isEmpty || 
                                         item.title.toLowerCase().contains(q) || 
                                         item.series.toLowerCase().contains(q);
                          final matchCat = category == 'All' || item.category == category;
                          final matchRar = rarity == 'All' || item.rarity == rarity;
                          return matchQ && matchCat && matchRar;
                        }).toList();

                        if (items.isEmpty) {
                          return const Center(
                            child: Text(
                              'No saved items match your search.',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                            ),
                          );
                        }

                        return _renderItems(context, ref, items);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 10, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Watchlist',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
            Row(
              children: [
                const CartIconButton(),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => context.push(RouteNames.notifications.path),
                  icon: const Icon(Icons.notifications_active, color: AppTheme.textPrimary, size: 24),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _renderItems(BuildContext context, WidgetRef ref, List<ItemModel> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 10),
          child: Text(
            '${items.length} ITEM${items.length != 1 ? "S" : ""} FOUND',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 0.4),
          ),
        ),
        Expanded(
          child: ListView.builder(
            key: const PageStorageKey<String>('watchlist_items'),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final isFav = ref.watch(watchlistProvider).contains(items[i].id);

              return ItemCard(
                key: ValueKey(items[i].id),
                item: items[i],
                isWatchlisted: isFav,
                onTap: () => context.push(
                  RouteNames.itemDetail.path,
                  extra: {
                    'item': items[i],
                    'isWatchlisted': isFav,
                    'onWatchlistToggle': () => ref.read(watchlistProvider.notifier).toggle(items[i].id),
                  },
                ),
                onWatchlistToggle: () => ref.read(watchlistProvider.notifier).toggle(items[i].id),
              );
            },
          ),
        ),
      ],
    );
  }
}