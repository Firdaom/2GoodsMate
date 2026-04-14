import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart'; 
import 'package:anigoods/features/home/providers/home_filter_provider.dart'; 
import 'package:anigoods/features/watchlist/screens/watchlist_screen.dart'; 

const List<String> kCategories = ['All', 'Figures', 'Cards', 'Manga', 'Merchandise', 'Vinyl'];
const List<String> kRarities = ['All', 'Limited', 'Rare', 'Common'];

class SearchAndFilterWidget extends ConsumerStatefulWidget {
  final bool isWatchlist;
  
  const SearchAndFilterWidget({
    super.key,
    this.isWatchlist = false, 
  });

  @override
  ConsumerState<SearchAndFilterWidget> createState() => _SearchAndFilterWidgetState();
}

class _SearchAndFilterWidgetState extends ConsumerState<SearchAndFilterWidget> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode(); 
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isWatchlist) {
        _searchCtrl.text = ref.read(watchlistSearchQueryProvider);
      } else {
        _searchCtrl.text = ref.read(homeFilterProvider).query;
      }
    });
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _focusNode.dispose(); 
    super.dispose();
  }

  void _showRaritySheet() {
    // ดึงค่าปัจจุบันมาแสดงใน BottomSheet
    final currentRarity = widget.isWatchlist 
        ? ref.read(watchlistRarityProvider)
        : ref.read(homeFilterProvider).rarity;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 36, height: 3, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Filter by Rarity', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            ...kRarities.map((rarity) => ListTile(
              title: Text(rarity, style: TextStyle(
                color: currentRarity == rarity ? AppTheme.accent : AppTheme.textSecondary,
                fontWeight: currentRarity == rarity ? FontWeight.w700 : FontWeight.w500,
              )),
              trailing: currentRarity == rarity ? const Icon(Icons.check, color: AppTheme.accent) : null,
              onTap: () {
                if (widget.isWatchlist) {
                  ref.read(watchlistRarityProvider.notifier).state = rarity;
                } else {
                  ref.read(homeFilterProvider.notifier).update((state) => state.copyWith(rarity: rarity));
                }
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentRarity = widget.isWatchlist ? ref.watch(watchlistRarityProvider) : ref.watch(homeFilterProvider).rarity;
    final String currentCategory = widget.isWatchlist ? ref.watch(watchlistCategoryProvider) : ref.watch(homeFilterProvider).category;
    final String currentQuery = widget.isWatchlist ? ref.watch(watchlistSearchQueryProvider) : ref.watch(homeFilterProvider).query;
    
    final isActive = _focusNode.hasFocus || currentQuery.isNotEmpty;

    return Column(
      children: [
        // --- Search Bar ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isActive ? AppTheme.accent.withOpacity(0.4) : AppTheme.border),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(Icons.search, color: isActive ? AppTheme.accent : AppTheme.textMuted, size: 18),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    focusNode: _focusNode, 
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                    decoration: const InputDecoration(hintText: 'Search items...', 
                    border: InputBorder.none, 
                    enabledBorder: InputBorder.none,   
                    focusedBorder: InputBorder.none,   
                    filled: false,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                    onChanged: (v) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        if (widget.isWatchlist) {
                          ref.read(watchlistSearchQueryProvider.notifier).state = v;
                        } else {
                          ref.read(homeFilterProvider.notifier).update((state) => state.copyWith(query: v));
                        }
                      });
                    },
                  ),
                ),
                if (currentQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      _searchCtrl.clear();
                      if (widget.isWatchlist) {
                        ref.read(watchlistSearchQueryProvider.notifier).state = '';
                      } else {
                        ref.read(homeFilterProvider.notifier).update((state) => state.copyWith(query: ''));
                      }
                      _focusNode.unfocus();
                    },
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // --- Filter Chips ---
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildRarityBtn(currentRarity),
              ...kCategories.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CategoryChip(
                  label: cat,
                  selected: currentCategory == cat,
                  onTap: () {
                    if (widget.isWatchlist) {
                      ref.read(watchlistCategoryProvider.notifier).state = cat;
                    } else {
                      ref.read(homeFilterProvider.notifier).update((state) => state.copyWith(category: cat));
                    }
                  },
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRarityBtn(String currentRarity) {
    final isSelected = currentRarity != 'All';
    return GestureDetector(
      onTap: _showRaritySheet,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accent : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.accent : AppTheme.border),
        ),
        child: Row(
          children: [
            Icon(Icons.filter_list, size: 14, color: isSelected ? AppTheme.surface : AppTheme.textSecondary),
            const SizedBox(width: 4),
           Text(
              currentRarity == 'All' ? 'Rarity' : currentRarity, 
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.w600, 
                color: isSelected ? Colors.white : AppTheme.textSecondary
              )
            ),
          ],
        ),
      ),
    );
  }
}