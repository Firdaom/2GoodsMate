import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/item_card.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/core/router/app_router.dart';
import 'package:anigoods/core/widgets/search_filter_widget.dart';
import 'package:anigoods/features/watchlist/providers/watchlist_provider.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    // เช็คว่ามีรายการในใจไหม
    final watchlistIds = ref.watch(watchlistProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SearchAndFilterWidget(isWatchlist: true),
            const SizedBox(height: 16),

            Expanded(
              child: watchlistIds.isEmpty
                  ? const EmptyState(
                      icon: Icons.favorite_outline,
                      title: 'No items yet',
                      subtitle: 'Tap the heart on items\nto save them here',
                    )
              
                  : ref.watch(watchlistItemsProvider).when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: AppTheme.accent),
                      ),
                      error: (err, stack) => Center(
                        child: Text('Error: $err', style: const TextStyle(color: AppTheme.danger)),
                      ),
                      data: (items) {
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
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
                onPressed: () => context.pushNamed(RouteNames.notifications.name),
                icon: const Icon(Icons.notifications_none_outlined, color: AppTheme.textPrimary, size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
              final item = items[i];
              final isFav = ref.watch(watchlistProvider).contains(item.id);

              return ItemCard(
                key: ValueKey(item.id),
                item: item,
                isWatchlisted: isFav,
                onTap: () => context.pushNamed(
                  RouteNames.itemDetail.name,
                  pathParameters: {'itemId': item.id},
                ),
                onWatchlistToggle: () => ref.read(watchlistProvider.notifier).toggle(item.id),
              );
            },
          ),
        ),
      ],
    );
  }
}