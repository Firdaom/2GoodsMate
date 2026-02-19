import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/features/home/presentation/screens/home_screen.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';


class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});
  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _titleCtrl   = TextEditingController();
  final _seriesCtrl  = TextEditingController();
  final _priceCtrl   = TextEditingController();
  final _descCtrl    = TextEditingController();
  final _tagsCtrl    = TextEditingController();
  final _contactCtrl = TextEditingController();

  String _category  = 'Figures';
  String _rarity    = 'Common';
  String _condition = 'New';
  File?  _imageFile;
  bool   _loading   = false;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleCtrl.dispose(); _seriesCtrl.dispose();
    _priceCtrl.dispose(); _descCtrl.dispose();
    _tagsCtrl.dispose();  _contactCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _titleCtrl.text.isNotEmpty && _seriesCtrl.text.isNotEmpty &&
      _priceCtrl.text.isNotEmpty && _descCtrl.text.isNotEmpty;

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<String> _uploadImage(String itemId) async {
    if (_imageFile == null) return '';
    final ref = FirebaseStorage.instance.ref('items/$itemId/main.jpg');
    await ref.putFile(_imageFile!);
    return await ref.getDownloadURL();
  }

  List<ContactLink> _parseContacts(String raw) => raw
      .split('\n')
      .where((l) => l.trim().isNotEmpty)
      .map((line) {
        final parts = line.split(',');
        return ContactLink(
          platform: parts[0].trim(),
          url: parts.length > 1 ? parts.sublist(1).join(',').trim() : '',
        );
      })
      .where((l) => l.platform.isNotEmpty && l.url.isNotEmpty)
      .toList();

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final sellerName = userDoc.exists ? (userDoc['name'] ?? user.email ?? '') : (user.email ?? '');

      // Create doc first to get ID
      final docRef = FirebaseFirestore.instance.collection('items').doc();
      final imageUrl = await _uploadImage(docRef.id);

      final item = ItemModel(
        id: docRef.id,
        title: _titleCtrl.text.trim(),
        series: _seriesCtrl.text.trim(),
        category: _category,
        rarity: _rarity,
        price: double.tryParse(_priceCtrl.text) ?? 0,
        condition: _condition,
        imageUrl: imageUrl,
        sellerId: user.uid,
        sellerName: sellerName,
        description: _descCtrl.text.trim(),
        tags: _tagsCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
        contactLinks: _parseContacts(_contactCtrl.text),
        postedAt: DateTime.now(),
      );

      await docRef.set(item.toFirestore());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item posted!'), backgroundColor: Color(0xFF4ADE80)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.danger),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image picker ───────────────────────────────
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.accentLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.accent.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                color: AppTheme.accent, size: 32),
                            const SizedBox(height: 6),
                            const Text('Add Photo',
                                style: TextStyle(
                                  fontSize: 12, color: AppTheme.accent,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            _label('Item Title *'),
            const SizedBox(height: 6),
            _field(_titleCtrl, 'e.g., Hatsune Miku - 1st Live Ver.'),
            const SizedBox(height: 14),

            _label('Series *'),
            const SizedBox(height: 6),
            _field(_seriesCtrl, 'e.g., Vocaloid, Naruto...'),
            const SizedBox(height: 14),

            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('Category *'),
                const SizedBox(height: 6),
                _dropdown(_category, kCategories.where((c) => c != 'All').toList(), (v) => setState(() => _category = v!)),
              ])),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('Rarity *'),
                const SizedBox(height: 6),
                _dropdown(_rarity, kRarities.where((r) => r != 'All').toList(), (v) => setState(() => _rarity = v!)),
              ])),
            ]),
            const SizedBox(height: 14),

            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('Price (฿) *'),
                const SizedBox(height: 6),
                TextField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                  decoration: const InputDecoration(hintText: '4500'),
                ),
              ])),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('Condition *'),
                const SizedBox(height: 6),
                _dropdown(_condition, const ['New', 'Like New', 'Good'], (v) => setState(() => _condition = v!)),
              ])),
            ]),
            const SizedBox(height: 14),

            _label('Description *'),
            const SizedBox(height: 6),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              decoration: const InputDecoration(hintText: 'Describe your item...'),
            ),
            const SizedBox(height: 14),

            _label('Tags (comma-separated)'),
            const SizedBox(height: 6),
            _field(_tagsCtrl, 'Limited Run, Sealed, Official'),
            const SizedBox(height: 14),

            _label('Contact Links (platform,url per line)'),
            const SizedBox(height: 6),
            TextField(
              controller: _contactCtrl,
              maxLines: 3,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
              decoration: const InputDecoration(
                  hintText: 'facebook,https://facebook.com/page\nline,https://line.me/ti/p/id'),
            ),
            const SizedBox(height: 4),
            const Text('Supported: facebook, twitter, instagram, line, shopee, lazada',
                style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            const SizedBox(height: 28),

            GestureDetector(
              onTap: _canSubmit && !_loading ? _submit : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: _canSubmit
                      ? const LinearGradient(colors: [AppTheme.accent, AppTheme.accentDark])
                      : null,
                  color: _canSubmit ? null : AppTheme.border,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _canSubmit
                      ? [BoxShadow(color: AppTheme.accent.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 4))]
                      : null,
                ),
                child: Center(
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Post Item',
                          style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700,
                            color: _canSubmit ? Colors.white : AppTheme.textMuted,
                          )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 0.6));

  Widget _field(TextEditingController ctrl, String hint) => TextField(
        controller: ctrl,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
        decoration: InputDecoration(hintText: hint),
      );

  Widget _dropdown(String value, List<String> items, ValueChanged<String?> onChange) =>
      DropdownButtonFormField<String>(
        value: value, onChanged: onChange,
        dropdownColor: AppTheme.surface,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
        decoration: const InputDecoration(),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      );
}
 