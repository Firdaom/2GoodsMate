import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/models/report_model.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/services/moderation_service.dart';
import 'package:anigoods/core/constants/app_constants.dart';

class AdminReviewScreen extends StatelessWidget {
  const AdminReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Review'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending Items'),
              Tab(text: 'Flagged Items'),
              Tab(text: 'Reports'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_PendingItemsTab(), _FlaggedItemsTab(), _ReportsTab()],
        ),
      ),
    );
  }
}

// ✅ Tab 1: Pending Items (รอ review)
class _PendingItemsTab extends StatelessWidget {
  const _PendingItemsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(FirebaseCollections.items)
          .where('moderationStatus', isEqualTo: ModerationStatus.pending.name)
          .orderBy('postedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accent),
          );
        }

        final items =
            snapshot.data?.docs
                .map((d) => ItemModel.fromFirestore(d))
                .toList() ??
            [];

        if (items.isEmpty) {
          return const Center(
            child: Text(
              'No pending items',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: items.length,
          itemBuilder: (_, i) => _AdminItemCard(
            key: ValueKey(items[i].id),
            item: items[i],
            onApprove: () => _approveItem(context, items[i].id),
            onReject: () => _rejectItem(context, items[i].id),
          ),
        );
      },
    );
  }

  Future<void> _approveItem(BuildContext context, String itemId) async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollections.items)
        .doc(itemId)
        .update({
          ItemFields.moderationStatus: ModerationStatus.approved.name,
          'reviewedAt':
              FieldValue.serverTimestamp(), // ถ้าใช้บ่อยให้เพิ่ม ItemFields.reviewedAt
        });

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item approved ✅')));
    }
  }

  Future<void> _rejectItem(BuildContext context, String itemId) async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollections.items)
        .doc(itemId)
        .update({
          ItemFields.moderationStatus: ModerationStatus.rejected.name,
          'reviewedAt': FieldValue.serverTimestamp(),
        });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item rejected ❌'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }
}

// ✅ Tab 2: Flagged Items
class _FlaggedItemsTab extends StatelessWidget {
  const _FlaggedItemsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(FirebaseCollections.items)
          .where('moderationStatus', isEqualTo: ModerationStatus.flagged.name)
          .orderBy('flaggedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accent),
          );
        }

        final items =
            snapshot.data?.docs
                .map((d) => ItemModel.fromFirestore(d))
                .toList() ??
            [];

        if (items.isEmpty) {
          return const Center(
            child: Text(
              'No flagged items',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: items.length,
          itemBuilder: (_, i) => _AdminItemCard(
            key: ValueKey(items[i].id),
            item: items[i],
            showReportCount: true,
            onApprove: () => _unflagItem(context, items[i].id),
            onReject: () => _rejectItem(context, items[i].id),
          ),
        );
      },
    );
  }

  Future<void> _unflagItem(BuildContext context, String itemId) async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollections.items)
        .doc(itemId)
        .update({
          'moderationStatus': ModerationStatus.approved.name,
          'reviewedAt': FieldValue.serverTimestamp(),
        });

    // Mark all reports as reviewed
    final reports = await FirebaseFirestore.instance
        .collection(FirebaseCollections.reports)
        .where('itemId', isEqualTo: itemId)
        .get();

    for (var doc in reports.docs) {
      await doc.reference.update({
        'reviewed': true,
        'adminNote': 'Item approved after review',
      });
    }

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item unflagged ✅')));
    }
  }

  Future<void> _rejectItem(BuildContext context, String itemId) async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollections.items)
        .doc(itemId)
        .update({
          'moderationStatus': ModerationStatus.rejected.name,
          'reviewedAt': FieldValue.serverTimestamp(),
        });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed ❌'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }
}

// ✅ Tab 3: Reports
class _ReportsTab extends StatelessWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(FirebaseCollections.reports)
          .where('reviewed', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accent),
          );
        }

        final reports =
            snapshot.data?.docs
                .map((d) => ReportModel.fromFirestore(d))
                .toList() ??
            [];

        if (reports.isEmpty) {
          return const Center(
            child: Text(
              'No unreviewed reports',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: reports.length,
          itemBuilder: (_, i) => _ReportCard(
            key: ValueKey(reports[i].id),
            report: reports[i],
          ),
        );
      },
    );
  }
}

// Item card for admin review
class _AdminItemCard extends StatelessWidget {
  final ItemModel item;
  final bool showReportCount;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _AdminItemCard({
    super.key,
    required this.item,
    this.showReportCount = false,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 60,
                  height: 60,
                  color: AppTheme.accentLight,
                  child: item.imageUrls.isNotEmpty
                      ? Image.network(item.imageUrls[0], fit: BoxFit.cover)
                      : const Center(
                          child: Text('🎁', style: TextStyle(fontSize: 24)),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '฿${_formatPrice(item.price)} • ${item.sellerName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Text(
            item.description,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          if (showReportCount) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '⚠️ ${item.reportCount ?? 0} reports',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.condNew,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Reject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.danger,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) => price
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

// Report card
class _ReportCard extends StatelessWidget {
  final ReportModel report;
  const _ReportCard({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  report.itemTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _formatDate(report.createdAt),
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '🚩 ${report.reason.displayName}',
            style: const TextStyle(fontSize: 12, color: AppTheme.danger),
          ),
          if (report.additionalInfo != null) ...[
            const SizedBox(height: 4),
            Text(
              report.additionalInfo!,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Reported by: ${report.reporterName}',
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}';
  }
}
