import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/core/constants/app_constants.dart';
import 'package:anigoods/core/router/app_router.dart';

class MyListingScreen extends StatelessWidget {
  const MyListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: uid == null
          ? const Center(child: Text('Please login to view your listings.'))
          : StreamBuilder<QuerySnapshot>(
              // 🔥 ดึงเฉพาะไอเทมที่เราเป็นคนโพสต์ขาย
              stream: FirebaseFirestore.instance
                  .collection(FirebaseCollections.items)
                  .where('sellerId', isEqualTo: uid)
                  // .orderBy(ItemFields.postedAt, descending: true) // ถ้า Error ให้เอาออกก่อน แล้วไปทำ Index ใน Firebase
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final docs = snapshot.data?.docs ?? [];

                // 📦 ถ้ายังไม่เคยโพสต์ขายอะไรเลย
                if (docs.isEmpty) {
                  return const EmptyState(
                    emoji: '📦',
                    title: 'No Listings Yet',
                    subtitle: 'Turn your collection into cash!\nStart selling today.',
                  );
                }

                final items = docs.map((doc) => ItemModel.fromFirestore(doc)).toList();

                // 📋 ถ้ามีของที่โพสต์ไว้ ให้แสดงเป็นลิสต์
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ItemCard(
                      item: item,
                      isWatchlisted: false, // หน้าของตัวเองไม่ต้องโชว์หัวใจก็ได้ หรือจะดึงมาก็ทำแบบหน้า Home
                      onTap: () {
                        // กดดูรายละเอียดไอเทมตัวเองได้
                        context.push(
                          RouteNames.itemDetail.path,
                          extra: {
                            'item': item,
                            'isWatchlisted': false,
                            'onWatchlistToggle': () {}, 
                          },
                        );
                      },
                      onWatchlistToggle: () {},
                    );
                  },
                );
              },
            ),
    );
  }
}