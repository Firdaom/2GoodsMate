import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/features/item_detail/screens/item_detail_screen.dart';
import 'package:anigoods/features/add_item/screens/addItem_screen.dart';
import 'package:anigoods/core/constants/app_constants.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});
  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {

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

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
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
                    child: const Text('➕', style: TextStyle(fontSize: 24)),
                  ),
                ],
              ),
            ),
            Expanded(
              // ✅ StreamBuilder ฟัง user document แบบ real-time
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(FirebaseCollections.users)
                    .doc(uid)
                    .snapshots(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.accent),
                    );
                  }

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return const EmptyState(
                      emoji: '🔖',
                      title: 'No items yet',
                      subtitle: 'Tap the heart on items\nto save them here',
                    );
                  }

                  final watchlist = List<String>.from(
                    userSnapshot.data!.get('watchlist') ?? [],
                  );

                  if (watchlist.isEmpty) {
                    return const EmptyState(
                      emoji: '🔖',
                      title: 'No items yet',
                      subtitle: 'Tap the heart on items\nto save them here',
                    );
                  }

                  // ✅ StreamBuilder ดึง items ที่อยู่ใน watchlist
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
                            color: AppTheme.accent,
                          ),
                        );
                      }

                      final items =
                          itemsSnapshot.data?.docs
                              .map((d) => ItemModel.fromFirestore(d))
                              .toList() ??
                          [];

                      if (items.isEmpty) {
                        return const EmptyState(
                          emoji: '🔖',
                          title: 'No items yet',
                          subtitle: 'Tap the heart on items\nto save them here',
                        );
                      }

                      return ListView.builder(
                        key: PageStorageKey<String>('watchlist_items'),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: items.length,
                        itemBuilder: (_, i) => ItemCard(
                          key: ValueKey(items[i].id),
                          item: items[i],
                          isWatchlisted: true,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ItemDetailScreen(
                                item: items[i],
                                isWatchlisted: true,
                                onWatchlistToggle: () {
                                  _remove(items[i].id);
                                },
                              ),
                            ),
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



