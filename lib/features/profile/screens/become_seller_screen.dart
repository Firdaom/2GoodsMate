import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';

class BecomeSellerScreen extends StatefulWidget {
  const BecomeSellerScreen({super.key});

  @override
  State<BecomeSellerScreen> createState() => _BecomeSellerScreenState();
}

class _BecomeSellerScreenState extends State<BecomeSellerScreen> {
  final _formKey = GlobalKey<FormState>();

  // Shop Info
  final _shopNameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();

  // Personal Info
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  DateTime? _selectedDob;

  // Verification
  String _idType = 'National ID';
  final _idNumberCtrl = TextEditingController();

  // Bank Info
  String? _selectedBank;
  final _accNameCtrl = TextEditingController();
  final _accNumberCtrl = TextEditingController();

  bool _agreedToTerms = false;
  bool _isLoading = false;

  final List<String> _bankOptions = ['Kasikornbank (KBank)', 'SCB', 'Bangkok Bank', 'Krungthai (KTB)', 'Other'];

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _bioCtrl.dispose();
    _urlCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _idNumberCtrl.dispose();
    _accNameCtrl.dispose();
    _accNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select your Date of Birth')));
      return;
    }
    if (_selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select your Bank')));
      return;
    }
    if (!_agreedToTerms) return;

    setState(() => _isLoading = true);

    // จำลองการโหลดส่งข้อมูล ->ค่อยมาต่อ API กับ Firebase
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted successfully!'), backgroundColor: AppTheme.success),
      );
      context.pop(); // กลับไปหน้าโปรไฟล์
    }
  }

  Future<void> _pickDob() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accent,
              surface: AppTheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _selectedDob = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.accentDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Become a Seller', style: TextStyle(color: AppTheme.accentDark, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Start Your Journey', style: TextStyle(color: AppTheme.accentDark, fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Fill out the form below to verify your identity and setup your shop.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5)),
              const SizedBox(height: 32),

              // ─── SHOP INFORMATION ───
              _SectionHeader('1. Shop Information'),
              _buildTextField('Shop Name', _shopNameCtrl, hint: 'e.g., Anime Goods TH'),
              _buildTextField('Bio (Description)', _bioCtrl, hint: 'Tell buyers about your shop...', maxLines: 3),
              _buildTextField('Shop URL (Optional)', _urlCtrl, hint: 'e.g., facebook.com/myshop', isRequired: false),
              const SizedBox(height: 24),

              // ─── PERSONAL INFORMATION ───
              _SectionHeader('2. Personal Information'),
              Row(
                children: [
                  Expanded(child: _buildTextField('First Name', _firstNameCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField('Last Name', _lastNameCtrl)),
                ],
              ),
              _buildTextField('Phone Number', _phoneCtrl, hint: 'e.g., 0812345678', keyboardType: TextInputType.phone),
              
              // Date of Birth Picker
              const _FieldLabel('Date of Birth'),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickDob,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text(
                    _selectedDob == null ? 'Select Date' : '${_selectedDob!.day}/${_selectedDob!.month}/${_selectedDob!.year}',
                    style: TextStyle(color: _selectedDob == null ? AppTheme.textMuted : AppTheme.textPrimary, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField('Full Address', _addressCtrl, hint: 'Enter your current address', maxLines: 2),
              const SizedBox(height: 24),

              // ─── VERIFICATION ───
              _SectionHeader('3. Identity Verification'),
              const _FieldLabel('ID Type'),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildRadioOption('National ID'),
                  const SizedBox(width: 20),
                  _buildRadioOption('Passport'),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField('ID Number', _idNumberCtrl, hint: 'Enter your ${_idType} number', keyboardType: TextInputType.number),
              const SizedBox(height: 24),

              // ─── BANK DETAILS ───
              _SectionHeader('4. Bank Details'),
              const _FieldLabel('Bank Name'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedBank,
                dropdownColor: AppTheme.surface,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                hint: const Text('Select your bank', style: TextStyle(color: AppTheme.textMuted)),
                items: _bankOptions.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (val) => setState(() => _selectedBank = val),
                validator: (val) => val == null ? 'Please select a bank' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField('Account Name', _accNameCtrl, hint: 'e.g., Somchai Jaidee'),
              _buildTextField('Account Number', _accNumberCtrl, hint: 'e.g., 1234567890', keyboardType: TextInputType.number),
              const SizedBox(height: 32),

              // ─── TERMS & SUBMIT ───
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24, height: 24,
                    child: Checkbox(
                      value: _agreedToTerms,
                      onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                      activeColor: AppTheme.accent,
                      checkColor: AppTheme.background,
                      side: const BorderSide(color: AppTheme.textMuted, width: 1.5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.5),
                        children: [
                          const TextSpan(text: 'I confirm that all information is accurate and agree to the '),
                          TextSpan(
                            text: 'Seller Terms & Conditions',
                            style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600),
                            recognizer: TapGestureRecognizer()..onTap = () => context.push('/terms'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                label: 'Submit Application',
                onTap: (_isLoading || !_agreedToTerms) ? null : _submitForm,
                loading: _isLoading,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildRadioOption(String title) {
    return GestureDetector(
      onTap: () => setState(() => _idType = title),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_idType == title ? Icons.radio_button_checked : Icons.radio_button_off, color: _idType == title ? AppTheme.accent : AppTheme.textMuted, size: 20),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(color: _idType == title ? AppTheme.textPrimary : AppTheme.textMuted, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hint, int maxLines = 1, bool isRequired = true, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.textMuted),
            filled: true,
            fillColor: AppTheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: isRequired ? (v) => v!.trim().isEmpty ? 'Required' : null : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 0.6));
}