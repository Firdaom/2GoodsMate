import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/features/item_detail/screens/item_detail_screen.dart';
import 'package:anigoods/features/add_item/screens/addItem_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});
  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  Future<void> _remove(String itemId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    
    if (doc.exists) {
      final currentWatchlist = List<String>.from(doc['watchlist'] ?? []);
      final updated = currentWatchlist.where((id) => id != itemId).toList();
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'watchlist': updated});
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please login')),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Watchlist',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddItemScreen())),
                    child: const Text('➕', style: TextStyle(fontSize: 24)),
                  ),
                ],
              ),
            ),
            Expanded(
              // ✅ StreamBuilder ฟัง user document แบบ real-time
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .snapshots(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                  }
                  
                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return const _EmptyState(
                      emoji: '🔖', 
                      title: 'No items yet', 
                      subtitle: 'Tap the heart on items\nto save them here'
                    );
                  }
                  
                  final watchlist = List<String>.from(
                    userSnapshot.data!.get('watchlist') ?? []
                  );
                  
                  if (watchlist.isEmpty) {
                    return const _EmptyState(
                      emoji: '🔖', 
                      title: 'No items yet', 
                      subtitle: 'Tap the heart on items\nto save them here'
                    );
                  }
                  
                  // ✅ StreamBuilder ดึง items ที่อยู่ใน watchlist
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('items')
                        .where(FieldPath.documentId, whereIn: watchlist)
                        .snapshots(),
                    builder: (context, itemsSnapshot) {
                      if (itemsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                      }
                      
                      final items = itemsSnapshot.data?.docs
                          .map((d) => ItemModel.fromFirestore(d))
                          .toList() ?? [];
                      
                      if (items.isEmpty) {
                        return const _EmptyState(
                          emoji: '🔖', 
                          title: 'No items yet', 
                          subtitle: 'Tap the heart on items\nto save them here'
                        );
                      }
                      
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: items.length,
                        itemBuilder: (_, i) => ItemCard(
                          item: items[i],
                          isWatchlisted: true,
                          onTap: () => Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (_) => ItemDetailScreen(
                                item: items[i], 
                                isWatchlisted: true,
                                onWatchlistToggle: () => _remove(items[i].id),
                              ),
                            )
                          ),
                          onWatchlistToggle: () => _remove(items[i].id),
                        ),
                      );
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

// ════════════════════════════════════════════════════════
// notification_keywords_screen.dart 
// ════════════════════════════════════════════════════════

class NotificationKeywordsScreen extends StatefulWidget {
  const NotificationKeywordsScreen({super.key});
  @override
  State<NotificationKeywordsScreen> createState() => _NotificationKeywordsScreenState();
}

class _NotificationKeywordsScreenState extends State<NotificationKeywordsScreen> {
  final _ctrl = TextEditingController();
  List<String> _keywords = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists && mounted) setState(() => _keywords = List<String>.from(doc['notificationKeywords'] ?? []));
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'notificationKeywords': _keywords});
  }

  void _add() {
    final kw = _ctrl.text.trim();
    if (kw.isEmpty) return;
    setState(() => _keywords.add(kw));
    _ctrl.clear();
    _save();
  }

  void _remove(int i) { setState(() => _keywords.removeAt(i)); _save(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keyword Alerts'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.accentLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.accent.withOpacity(0.2)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💡 How it works', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600, fontSize: 12)),
                  SizedBox(height: 4),
                  Text('Add keywords and get notified when new matching items are listed!',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _SectionLabel('ADD NEW KEYWORD'),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                  decoration: const InputDecoration(hintText: 'e.g., Haikyu, Naruto...'),
                  onSubmitted: (_) => _add(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _add,
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.accent, AppTheme.accentDark]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            _SectionLabel('YOUR KEYWORDS (${_keywords.length})'),
            const SizedBox(height: 8),
            Expanded(
              child: _keywords.isEmpty
                  ? const _EmptyState(emoji: '🔍', title: 'No keywords yet', subtitle: 'Add keywords to start tracking')
                  : ListView.separated(
                      itemCount: _keywords.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(children: [
                          const Text('🔔', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 10),
                          Expanded(child: Text(_keywords[i],
                              style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.w500))),
                          GestureDetector(
                            onTap: () => _remove(i),
                            child: Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                color: AppTheme.danger.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.danger.withOpacity(0.2)),
                              ),
                              child: const Center(child: Text('×',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.danger))),
                            ),
                          ),
                        ]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// Shared helpers
// ════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  final String emoji, title, subtitle;
  const _EmptyState({required this.emoji, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: const TextStyle(fontSize: 40)),
      const SizedBox(height: 12),
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
      const SizedBox(height: 4),
      Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
    ]),
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.8));
}