import 'package:anigoods/core/constants/firebase_constants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/models/report_model.dart';
import 'package:anigoods/core/services/moderation_service.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/constants/app_constants.dart';

class ReportItemScreen extends StatefulWidget {
  final ItemModel item;
  const ReportItemScreen({super.key, required this.item});

  @override
  State<ReportItemScreen> createState() => _ReportItemScreenState();
}

class _ReportItemScreenState extends State<ReportItemScreen> {
  ReportReason? _selectedReason;
  final _additionalInfoCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _additionalInfoCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a reason'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Please login first');

      final reportRef = FirebaseFirestore.instance
          .collection(FirebaseCollections.reports)
          .doc();

      final report = ReportModel(
        id: reportRef.id,
        itemId: widget.item.id,
        itemTitle: widget.item.title,
        reporterId: user.uid,
        reporterName: user.email?.split('@')[0] ?? 'Anonymous',
        reason: _selectedReason!,
        additionalInfo: _additionalInfoCtrl.text.trim().isEmpty
            ? null
            : _additionalInfoCtrl.text.trim(),
        createdAt: DateTime.now(),
      );

      await reportRef.set(report.toFirestore());

      // ✅ ถ้ามี 3+ reports → auto flag item
      await _checkAutoFlag(widget.item.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted. Thank you! 🙏'),
            backgroundColor: AppTheme.condNew,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Report error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ✅ Auto flag ถ้ามี reports เยอะ
  Future<void> _checkAutoFlag(String itemId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(FirebaseCollections.reports)
        .where('itemId', isEqualTo: itemId)
        .where('reviewed', isEqualTo: false)
        .get();

    if (snapshot.docs.length >= 3) {
      // มี 3+ reports → flag item
      await FirebaseFirestore.instance
          .collection(FirebaseCollections.items)
          .doc(itemId)
          .update({
            ItemFields.moderationStatus: ModerationStatus.flagged.name,
            'flaggedAt': FieldValue.serverTimestamp(),
            'reportCount': snapshot.docs.length,
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Item'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 50,
                      height: 50,
                      color: AppTheme.accentLight,
                      child: widget.item.imageUrls.isNotEmpty
                          ? Image.network(
                              widget.item.imageUrls[0],
                              fit: BoxFit.cover,
                            )
                          : const Center(
                              child: Text('🎁', style: TextStyle(fontSize: 20)),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Why are you reporting this item?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Reason options
            ...ReportReason.values.map((reason) => _buildReasonOption(reason)),

            const SizedBox(height: 20),
            const Text(
              'Additional information (optional)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _additionalInfoCtrl,
              maxLines: 4,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Please provide more details...',
              ),
            ),

            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.danger,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit Report',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonOption(ReportReason reason) {
    final isSelected = _selectedReason == reason;

    return GestureDetector(
      onTap: () => setState(() => _selectedReason = reason),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentLight : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.accent : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.accent : AppTheme.textMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                reason.displayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppTheme.accent : AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
