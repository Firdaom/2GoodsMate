import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/features/item_detail/presentation/screens/item_detail_screen.dart';
import 'package:anigoods/features/add_item/screens/addItem_screen.dart';
import 'package:anigoods/features/notification/screens/notification_screen.dart';



const List<String> kCategories = ['All','Figures','Cards','Manga','Merchandise','Vinyl'];
const List<String> kRarities   = ['All','Limited','Rare','Common'];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String _query    = '';
  String _category = 'All';
  String _rarity   = 'All';
  List<String> _watchlist = [];

  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  Future<void> _loadWatchlist() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists && mounted) {
      setState(() => _watchlist = List<String>.from(doc['watchlist'] ?? []));
    }
  }

  Future<void> _toggleWatchlist(String itemId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final updated = _watchlist.contains(itemId)
        ? _watchlist.where((id) => id != itemId).toList()
        : [..._watchlist, itemId];
    setState(() => _watchlist = updated);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'watchlist': updated});
  }

  List<ItemModel> _filter(List<ItemModel> items) => items.where((item) {
        final q = _query.toLowerCase();
        final matchQ   = q.isEmpty || item.matchesQuery(q);
        final matchCat = _category == 'All' || item.category == _category;
        final matchRar = _rarity   == 'All' || item.rarity   == _rarity;
        return matchQ && matchCat && matchRar;
      }).toList();

  void _showRaritySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 3,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Filter by Rarity',
                style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                )),
            const SizedBox(height: 12),
            ...kRarities.map((r) => GestureDetector(
              onTap: () { setState(() => _rarity = r); Navigator.pop(context); },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: AppTheme.border))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r,
                        style: TextStyle(
                          fontSize: 14,
                          color: _rarity == r
                              ? AppTheme.accent
                              : AppTheme.textSecondary,
                          fontWeight: _rarity == r
                              ? FontWeight.w700
                              : FontWeight.w500,
                        )),
                    if (_rarity == r)
                      const Icon(Icons.check,
                          color: AppTheme.accent, size: 18),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back 👋',
                          style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: AppTheme.accent.withOpacity(0.8),
                            letterSpacing: 0.8,
                          )),
                      const SizedBox(height: 2),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700),
                          children: [
                            TextSpan(text: '2Goods',
                                style: TextStyle(color: AppTheme.textPrimary)),
                            TextSpan(text: 'Mate',
                                style: TextStyle(color: AppTheme.accent)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationKeywordsScreen())),
                    child: const Text('🔔', style: TextStyle(fontSize: 22)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Search ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _query.isNotEmpty
                        ? AppTheme.accent.withOpacity(0.4)
                        : AppTheme.border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8, offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Icon(Icons.search,
                        color: _query.isNotEmpty
                            ? AppTheme.accent
                            : AppTheme.textMuted,
                        size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Search figures, cards, manga...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          fillColor: Colors.transparent,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 14),
                          child: Icon(Icons.close,
                              color: AppTheme.textMuted, size: 16),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Filter chips ───────────────────────────────
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  GestureDetector(
                    onTap: _showRaritySheet,
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _rarity != 'All'
                            ? AppTheme.accent
                            : AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _rarity != 'All'
                              ? AppTheme.accent
                              : AppTheme.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.filter_list,
                              size: 14,
                              color: _rarity != 'All'
                                  ? Colors.white
                                  : AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text('Rarity',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _rarity != 'All'
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                              )),
                        ],
                      ),
                    ),
                  ),
                  ...kCategories.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CategoryChip(
                          label: cat,
                          selected: _category == cat,
                          onTap: () => setState(() => _category = cat),
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ── Items ──────────────────────────────────────
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('items')
                    .orderBy('postedAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.accent));
                  }
                  final all = snapshot.data?.docs
                          .map((d) => ItemModel.fromFirestore(d))
                          .toList() ??
                      [];
                  final items = _filter(all);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '${items.length} ITEM${items.length != 1 ? "S" : ""} FOUND',
                          style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted, letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: items.isEmpty
                            ? const Center(
                                child: Text(
                                  'No items match your search.',
                                  style: TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 13),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                    20, 0, 20, 20),
                                itemCount: items.length,
                                itemBuilder: (_, i) => ItemCard(
                                  item: items[i],
                                  isWatchlisted:
                                      _watchlist.contains(items[i].id),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ItemDetailScreen(
                                        item: items[i],
                                        isWatchlisted: _watchlist
                                            .contains(items[i].id),
                                        onWatchlistToggle: () =>
                                            _toggleWatchlist(items[i].id),
                                      ),
                                    ),
                                  ),
                                  onWatchlistToggle: () =>
                                      _toggleWatchlist(items[i].id),
                                ),
                              ),
                      ),
                    ],
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
