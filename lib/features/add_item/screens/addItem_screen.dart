import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/core/services/error_handler.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:anigoods/core/repositories/item_repository.dart';
import 'package:anigoods/features/add_item/screens/image_upload_picker.dart';

const List<String> kCategories = [
  'Figures',
  'Cards',
  'Manga',
  'Merchandise',
  'Vinyl',
];
const List<String> kRarities = ['Limited', 'Rare', 'Common'];

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});
  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemRepository = ItemRepository();
  final _titleCtrl = TextEditingController();
  final _seriesCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();

  String _category = 'Figures';
  String _rarity = 'Common';
  String _condition = 'New';
  List<XFile> _imageFiles = [];
  bool _loading = false;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _seriesCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _tagsCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isNotEmpty) {
      setState(() => _imageFiles = picked);
    }
  }

  void _removeImage(int index) {
    setState(() => _imageFiles.removeAt(index));
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
    if (!_formKey.currentState!.validate()) {
      return; // ถ้ามีช่องไหนกรอกไม่ครบ ให้หยุดทำงานตรงนี้ พร้อมแสดงข้อความแจ้งเตือน
    }
    setState(() => _loading = true);
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Uploading item...', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Call repository to create item
      await _itemRepository.createItem(
        title: _titleCtrl.text.trim(),
        series: _seriesCtrl.text.trim(),
        category: _category,
        rarity: _rarity,
        price: double.tryParse(_priceCtrl.text) ?? 0,
        condition: _condition,
        description: _descCtrl.text.trim(),
        tags: _tagsCtrl.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(),
        contactLinks: _parseContacts(_contactCtrl.text),
        imageFiles: _imageFiles.isNotEmpty ? _imageFiles : null,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ErrorHandler.showSuccess(context, 'Item posted successfully!');
        Navigator.pop(context); // Go back
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ErrorHandler.showError(context, e, contextLabel: 'addItem_screen.dart');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  

  /// Build title and series fields
  Widget _buildTitleAndSeries() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('Item Title *'),
      const SizedBox(height: 6),
      _field(_titleCtrl, 'e.g., Hatsune Miku - 1st Live Ver.'),
      const SizedBox(height: 14),
      _label('Series *'),
      const SizedBox(height: 6),
      _field(_seriesCtrl, 'e.g., Vocaloid, Naruto...'),
      const SizedBox(height: 14),
    ],
  );

  /// Build category and rarity selectors
  Widget _buildCategoryAndRarity() => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Category *'),
            const SizedBox(height: 6),
            _dropdown(
              _category,
              kCategories.where((c) => c != 'All').toList(),
              (v) => setState(() => _category = v!),
            ),
          ],
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Rarity *'),
            const SizedBox(height: 6),
            _dropdown(
              _rarity,
              kRarities.where((r) => r != 'All').toList(),
              (v) => setState(() => _rarity = v!),
            ),
          ],
        ),
      ),
    ],
  );

  /// Build price and condition fields
  Widget _buildPriceAndCondition() => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Price (฿) *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              decoration: const InputDecoration(hintText: '4500'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the price';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Condition *'),
            const SizedBox(height: 6),
            _dropdown(_condition, const [
              'New',
              'Like New',
              'Good',
            ], (v) => setState(() => _condition = v!)),
          ],
        ),
      ),
    ],
  );

  /// Build description field
  Widget _buildDescription() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('Description *'),
      const SizedBox(height: 6),
      TextFormField(
        controller: _descCtrl,
        maxLines: 3,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter the description';
          }
          return null;
        },
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
        decoration: const InputDecoration(hintText: 'Describe your item...'),
      ),
      const SizedBox(height: 14),
    ],
  );

  /// Build tags and contact links fields
  Widget _buildTagsAndContacts() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('Tags (comma-separated)'),
      const SizedBox(height: 6),
      _field(_tagsCtrl, 'Limited Run, Sealed, Official'),
      const SizedBox(height: 14),
      _label('Contact Links (platform,url per line)'),
      const SizedBox(height: 6),
      TextFormField(
        controller: _contactCtrl,
        maxLines: 3,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
        decoration: const InputDecoration(
          hintText:
              'facebook,https://facebook.com/page\nline,https://line.me/ti/p/id',
        ),
      ),
      const SizedBox(height: 4),
      const Text(
        'Supported: facebook, twitter, instagram, line, shopee, lazada',
        style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
      ),
    ],
  );

  /// Build submit button
  Widget _buildSubmitButton() => GestureDetector(
    onTap: _loading ? null : _submit,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.accent, AppTheme.accentDark],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
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
                'Post Item',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        physics: _imageFiles.isNotEmpty
            ? const NeverScrollableScrollPhysics()
            : const AlwaysScrollableScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageUploadPicker(
                imageFiles: _imageFiles,
                onPickImage: _pickImage,
                onRemoveImage: _removeImage,
              ),
              const SizedBox(height: 20),
              _buildTitleAndSeries(),
              _buildCategoryAndRarity(),
              const SizedBox(height: 14),
              _buildPriceAndCondition(),
              const SizedBox(height: 14),
              _buildDescription(),
              _buildTagsAndContacts(),
              const SizedBox(height: 28),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppTheme.textMuted,
      letterSpacing: 0.6,
    ),
  );

  Widget _field(
    TextEditingController ctrl,
    String hint, {
    bool isRequired = true,
  }) => TextFormField(
    controller: ctrl,
    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
    decoration: InputDecoration(hintText: hint),
    validator: (value) {
      if (isRequired && (value == null || value.trim().isEmpty)) {
        return 'Please enter this field';
      }
      return null; //
    },
  );

  Widget _dropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChange,
  ) => DropdownButtonFormField<String>(
    value: value,
    onChanged: onChange,
    dropdownColor: AppTheme.surface,
    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
    decoration: const InputDecoration(),
    items: items
        .map((i) => DropdownMenuItem(value: i, child: Text(i)))
        .toList(),
  );
}
