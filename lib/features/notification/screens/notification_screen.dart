import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/core/constants/firebase_constants.dart';
import 'package:anigoods/features/auth/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationKeywordsScreen extends ConsumerStatefulWidget {
  const NotificationKeywordsScreen({super.key});
  @override
  ConsumerState<NotificationKeywordsScreen> createState() => _NotificationKeywordsScreenState();
}

class _NotificationKeywordsScreenState extends ConsumerState<NotificationKeywordsScreen> {
  final _ctrl = TextEditingController();
  List<String> _keywords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKeywords();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String? get _userId => ref.read(firebaseAuthProvider).currentUser?.uid;

  Future<void> _loadKeywords() async {
    if (_userId == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirebaseCollections.users)
          .doc(_userId)
          .get();
      
      if (doc.exists && mounted) {
        setState(() {
          _keywords = List<String>.from(doc.data()?[UserFields.notificationKeywords] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addKeyword() async {
    final kw = _ctrl.text.trim();
    if (kw.isEmpty || _userId == null) return;
    if (_keywords.contains(kw)) return; // กันคำซ้ำ

    setState(() => _keywords.add(kw)); // Optimistic UI
    _ctrl.clear();

    await FirebaseFirestore.instance.collection(FirebaseCollections.users).doc(_userId).update({
      UserFields.notificationKeywords: FieldValue.arrayUnion([kw]),
    });
  }

  Future<void> _removeKeyword(int index) async {
    if (_userId == null) return;
    final kwToRemove = _keywords[index];

    setState(() => _keywords.removeAt(index)); // UI เปลี่ยนทันที

    await FirebaseFirestore.instance.collection(FirebaseCollections.users).doc(_userId).update({
      UserFields.notificationKeywords: FieldValue.arrayRemove([kwToRemove]),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keyword Alerts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHowItWorks(),
                const SizedBox(height: 24),
                const SectionLabel('ADD NEW KEYWORD'),
                const SizedBox(height: 8),
                _buildInputRow(),
                const SizedBox(height: 24),
                SectionLabel('YOUR KEYWORDS (${_keywords.length})'),
                const SizedBox(height: 12),
                Expanded(child: _buildKeywordList()),
              ],
            ),
          ),
    );
  }

  Widget _buildHowItWorks() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.accentLight,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.accent.withOpacity(0.1)),
    ),
    child: Row(
      children: [
        const Text('💡', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Add keywords and get notified when new matching items are listed!',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
          ),
        ),
      ],
    ),
  );

  Widget _buildInputRow() => Row(
    children: [
      Expanded(
        child: TextField(
          controller: _ctrl,
          decoration: const InputDecoration(hintText: 'e.g., Haikyu, Naruto...'),
          onSubmitted: (_) => _addKeyword(),
        ),
      ),
      const SizedBox(width: 10),
      GestureDetector(
        onTap: _addKeyword,
        child: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.accent, AppTheme.accentDark]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    ],
  );

  Widget _buildKeywordList() {
    if (_keywords.isEmpty) {
      return const EmptyState(
        icon: Icons.notifications_none_rounded,
        title: 'No keywords yet',
        subtitle: 'Add keywords to start tracking',
      );
    }
    return ListView.separated(
      itemCount: _keywords.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _buildKeywordTile(i),
    );
  }

  Widget _buildKeywordTile(int index) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.border),
    ),
    child: Row(
      children: [
        const Icon(Icons.notifications_rounded, size: 16, color: AppTheme.accent),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _keywords[index],
            style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 20),
          onPressed: () => _removeKeyword(index),
        ),
      ],
    ),
  );
}