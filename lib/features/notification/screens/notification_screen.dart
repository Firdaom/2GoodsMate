import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/features/item_detail/screens/item_detail_screen.dart';
import 'package:anigoods/features/add_item/screens/addItem_screen.dart';
import 'package:anigoods/core/constants/app_constants.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';


// ════════════════════════════════════════════════════════
// notification_keywords_screen.dart
// ════════════════════════════════════════════════

class NotificationKeywordsScreen extends StatefulWidget {
  const NotificationKeywordsScreen({super.key});
  @override
  State<NotificationKeywordsScreen> createState() =>
      _NotificationKeywordsScreenState();
}

class _NotificationKeywordsScreenState
    extends State<NotificationKeywordsScreen> {
  final _ctrl = TextEditingController();
  List<String> _keywords = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection(FirebaseCollections.users)
        .doc(uid)
        .get();
    if (doc.exists && mounted)
      setState(
        () => _keywords = List<String>.from(
          doc[UserFields.notificationKeywords] ?? [],
        ),
      );
  }

  Future<void> _add() async {
    final kw = _ctrl.text.trim();
    if (kw.isEmpty) return;

    // อัปเดตหน้าจอให้ผู้ใช้เห็นทันที (Optimistic UI)
    setState(() => _keywords.add(kw));
    _ctrl.clear();

    //สั่ง Firebase ให้เพิ่มคำนี้เข้าไปใน Array หลังบ้าน
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection(FirebaseCollections.users)
          .doc(uid)
          .update({
        UserFields.notificationKeywords: FieldValue.arrayUnion([kw]),
      });
    }
  }

  Future<void> _remove(int i) async {
    final kwToRemove = _keywords[i]; // จำคำที่จะลบไว้ก่อน

    // 1. ลบออกจากหน้าจอผู้ใช้ทันที
    setState(() => _keywords.removeAt(i));

    // 2. สั่ง Firebase ให้เตะคำนี้ออกจาก Array หลังบ้าน
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection(FirebaseCollections.users)
          .doc(uid)
          .update({
        UserFields.notificationKeywords: FieldValue.arrayRemove([kwToRemove]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keyword Alerts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                  Text(
                    '💡 How it works',
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Add keywords and get notified when new matching items are listed!',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionLabel('ADD NEW KEYWORD'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'e.g., Haikyu, Naruto...',
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _add,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.accent, AppTheme.accentDark],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SectionLabel('YOUR KEYWORDS (${_keywords.length})'),
            const SizedBox(height: 8),
            Expanded(
              child: _keywords.isEmpty
                  ? const EmptyState(
                     icon: Icons.search_sharp,
                      title: 'No keywords yet',
                      subtitle: 'Add keywords to start tracking',
                    )
                  : ListView.separated(
                      itemCount: _keywords.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.notifications, size: 16),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _keywords[i],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _remove(i),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppTheme.danger.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.danger.withOpacity(0.2),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    '×',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.danger,
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
}