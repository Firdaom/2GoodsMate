import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart'; 
import 'package:anigoods/core/providers/search_provider.dart'; 

const List<String> kCategories = ['All', 'Figures', 'Cards', 'Manga', 'Merchandise', 'Vinyl'];
const List<String> kRarities = ['All', 'Limited', 'Rare', 'Common'];

class SearchAndFilterWidget extends ConsumerStatefulWidget {
  final bool isWatchlist; 
  const SearchAndFilterWidget({super.key, this.isWatchlist = false});

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
    _focusNode.addListener(() {
      setState(() {}); 
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _focusNode.dispose(); 
    super.dispose();
  }

  // --- 1. ฟังก์ชันตัวใหม่ที่รับค่า Provider ---
  void _showRaritySheet(StateProvider<String> provider) {
    final currentRarity = ref.read(provider);
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
            Center(
              child: Container(
                width: 36, height: 3,
                decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Filter by Rarity', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            ...kRarities.map(
              (rarity) => GestureDetector(
                onTap: () {
                  ref.read(provider.notifier).state = rarity;
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.border))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        rarity,
                        style: TextStyle(
                          fontSize: 14,
                          color: currentRarity == rarity ? AppTheme.accent : AppTheme.textSecondary,
                          fontWeight: currentRarity == rarity ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      if (currentRarity == rarity) const Icon(Icons.check, color: AppTheme.accent, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // เลือก Provider ตามประเภทหน้า
    final queryProvider = widget.isWatchlist ? watchlistSearchQueryProvider : homeSearchQueryProvider;
    final categoryProvider = widget.isWatchlist ? watchlistCategoryProvider : homeCategoryProvider;
    final rarityProvider = widget.isWatchlist ? watchlistRarityProvider : homeRarityProvider;

    final query = ref.watch(queryProvider);
    final category = ref.watch(categoryProvider);
    final rarity = ref.watch(rarityProvider);

    final isActive = _focusNode.hasFocus || query.isNotEmpty;

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
              boxShadow: _focusNode.hasFocus
                  ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]
                  : null, 
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(Icons.search, color: isActive ? AppTheme.accent : AppTheme.textMuted, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    focusNode: _focusNode, 
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Search items...',
                      border: InputBorder.none, 
                      enabledBorder: InputBorder.none, 
                      focusedBorder: InputBorder.none,
                      fillColor: Colors.transparent, 
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (v) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        ref.read(queryProvider.notifier).state = v;
                      });
                    },
                  ),
                ),
                if (query.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      ref.read(queryProvider.notifier).state = ''; 
                      _focusNode.unfocus(); 
                    },
                    child: const Padding(padding: EdgeInsets.only(right: 14), child: Icon(Icons.close, color: AppTheme.textMuted, size: 16)),
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
              GestureDetector(
                onTap: () => _showRaritySheet(rarityProvider), // ✅ ส่ง Provider เข้าไป
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: rarity != 'All' ? AppTheme.accent : AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: rarity != 'All' ? AppTheme.accent : AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.filter_list, size: 14, color: rarity != 'All' ? Colors.white : AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text('Rarity', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: rarity != 'All' ? Colors.white : AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ),
              ...kCategories.map(
                (cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CategoryChip(
                    label: cat,
                    selected: category == cat,
                    onTap: () {
                      ref.read(categoryProvider.notifier).state = cat;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}