import 'package:anigoods/core/widgets/item_card.dart';
import 'package:anigoods/features/home/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/core/router/app_router.dart';
import 'package:anigoods/features/home/providers/home_filter_provider.dart';
import 'package:anigoods/features/watchlist/providers/watchlist_provider.dart';
import 'package:anigoods/core/widgets/search_filter_widget.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(homeFilterProvider);
    final watchlist = ref.watch(watchlistProvider);

    ref.listen(homeScrollTriggerProvider, (previous, next) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic, 
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            const SearchAndFilterWidget(isWatchlist: false),
            const SizedBox(height: 10),

            Expanded(
              child: ref
                  .watch(homeItemsProvider)
                  .when(
                    data: (items) =>
                        _renderItems(context, ref, items, watchlist),

                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppTheme.accent),
                    ),

                    error: (error, stackTrace) => Center(
                      child: Text(
                        'Error: $error',
                        style: const TextStyle(color: AppTheme.danger),
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // จัดการการแสดงผลลิสต์รายการ
  Widget _renderItems(
    BuildContext context,
    WidgetRef ref,
    List<ItemModel> items,
    Set<String> watchlist,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
        const SizedBox(height: 10),
        Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Text(
                    'No items match your search.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                )
              : ListView.builder(
                  key: const PageStorageKey<String>('home_items'),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    final isFavorite = watchlist.contains(item.id);

                    return ItemCard(
                      key: ValueKey(item.id),
                      item: item,
                      isWatchlisted: isFavorite,
                      onTap: () {
                        context.pushNamed(
                          RouteNames.itemDetail.name,
                          pathParameters: {'itemId': item.id},
                        );
                      },
                      onWatchlistToggle: () {
                        ref.read(watchlistProvider.notifier).toggle(item.id);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 15, 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            children: [
              TextSpan(
                text: '2Goods',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              TextSpan(
                text: 'Mate',
                style: TextStyle(color: AppTheme.accent),
              ),
            ],
          ),
        ),
        Row(
          children: [
            CartIconButton(),
            const SizedBox(width: 4),
            IconButton(
              onPressed: () => context.pushNamed(RouteNames.notifications.name),
              icon: const Icon(
                Icons.notifications_none_outlined,
                color: AppTheme.textPrimary,
                size: 24,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
