import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:anigoods/core/services/error_handler.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:anigoods/core/repositories/item_repository.dart';
import 'package:anigoods/features/add_item/screens/image_upload_picker.dart';


// เขียนไว้พัฒนาต่อสำหรับใช้งานโพสต์สินค้า เมื่อยูเซอร์จะเปิดร้านเอง ปัจจุบันนี้อยุ่ในช่วงพัฒนา ยังไม่มีการดึงโค้ดหน้านี้ไปใช้

const List<String> kCategories = ['Figures', 'Cards', 'Manga', 'Merchandise', 'Vinyl'];
const List<String> kRarities = ['Limited', 'Rare', 'Common'];

class AddItemScreen extends ConsumerStatefulWidget { 
  const AddItemScreen({super.key});
  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> { 
  final _formKey = GlobalKey<FormState>();
  
  final _titleCtrl = TextEditingController();
  final _seriesCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFiles.isEmpty) {
      ErrorHandler.showError(context, 'Please add at least one image', contextLabel: 'Image Check');
      return;
    }

    setState(() => _loading = true);
    
    // Show Loading Dialog
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
                CircularProgressIndicator(color: AppTheme.accent),
                SizedBox(height: 16),
                Text('Posting your item...', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final itemRepo = ref.read(itemRepositoryProvider);

      await itemRepo.createItem(
        title: _titleCtrl.text.trim(),
        series: _seriesCtrl.text.trim(),
        category: _category,
        rarity: _rarity,
        price: double.tryParse(_priceCtrl.text) ?? 0,
        condition: _condition,
        description: _descCtrl.text.trim(),
        tags: _tagsCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
        imageFiles: _imageFiles,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading
        ErrorHandler.showSuccess(context, 'Item posted successfully!');
        Navigator.pop(context); // Go back to Home/Profile
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ErrorHandler.showError(context, e, contextLabel: 'Submit Item');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
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
              const SizedBox(height: 24),
              _buildTitleAndSeries(),
              _buildCategoryAndRarity(),
              const SizedBox(height: 16),
              _buildPriceAndCondition(),
              const SizedBox(height: 16),
              _buildDescription(),
              _buildTagsAndContacts(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Helpers (คงเดิมแต่จัดระเบียบให้สวย) ---

  Widget _buildTitleAndSeries() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('Item Title *'),
      const SizedBox(height: 6),
      _field(_titleCtrl, 'e.g., Hatsune Miku - 1st Live Ver.'),
      const SizedBox(height: 16),
      _label('Series *'),
      const SizedBox(height: 6),
      _field(_seriesCtrl, 'e.g., Vocaloid, Naruto...'),
      const SizedBox(height: 16),
    ],
  );

  Widget _buildCategoryAndRarity() => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Category *'),
            const SizedBox(height: 6),
            _dropdown(_category, kCategories, (v) => setState(() => _category = v!)),
          ],
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Rarity *'),
            const SizedBox(height: 6),
            _dropdown(_rarity, kRarities, (v) => setState(() => _rarity = v!)),
          ],
        ),
      ),
    ],
  );

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
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              decoration: const InputDecoration(hintText: '4500'),
              validator: (v) => (v == null || v.isEmpty) ? 'Enter price' : null,
            ),
          ],
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Condition *'),
            const SizedBox(height: 6),
            _dropdown(_condition, const ['New', 'Like New', 'Good'], (v) => setState(() => _condition = v!)),
          ],
        ),
      ),
    ],
  );

  Widget _buildDescription() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('Description *'),
      const SizedBox(height: 6),
      TextFormField(
        controller: _descCtrl,
        maxLines: 4,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
        decoration: const InputDecoration(hintText: 'Describe your item in detail...'),
        validator: (v) => (v == null || v.isEmpty) ? 'Enter description' : null,
      ),
      const SizedBox(height: 16),
    ],
  );

  Widget _buildTagsAndContacts() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('Tags (comma-separated)'),
      const SizedBox(height: 6),
      _field(_tagsCtrl, 'Sealed, Official, Japan Import', isRequired: false),
      const SizedBox(height: 16),
    ],
  );

  Widget _buildSubmitButton() => GestureDetector(
    onTap: _loading ? null : _submit,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppTheme.accent, AppTheme.accentDark]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppTheme.accent.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Center(
        child: _loading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Text('Post Item', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    ),
  );

  Widget _label(String text) => Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 0.6));

  Widget _field(TextEditingController ctrl, String hint, {bool isRequired = true}) => TextFormField(
    controller: ctrl,
    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
    decoration: InputDecoration(hintText: hint),
    validator: (v) => (isRequired && (v == null || v.isEmpty)) ? 'This field is required' : null,
  );

  Widget _dropdown(String value, List<String> items, ValueChanged<String?> onChange) => DropdownButtonFormField<String>(
    value: value,
    onChanged: onChange,
    dropdownColor: AppTheme.surface,
    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
    items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
  );
}