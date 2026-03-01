import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:anigoods/models/user_model.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/features/profile/screens/setting_screen.dart';

// ════════════════════════════════════════════════════════
// PROFILE
// ════════════════════════════════════════════════════════
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists && mounted) setState(() => _user = UserModel.fromFirestore(doc));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text('Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 24),

              // Avatar
              Center(
                child: Column(children: [
                  Container(
                    width: 88, height: 88,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [AppTheme.accent, AppTheme.accentDark],
                          begin: Alignment.topLeft, end: Alignment.bottomRight),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.accent.withOpacity(0.3), width: 3),
                      boxShadow: [BoxShadow(color: AppTheme.accent.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 4))],
                    ),
                    child: _user?.profileImageUrl != null
                        ? ClipOval(child: Image.network(_user!.profileImageUrl!, fit: BoxFit.cover))
                        : const Center(child: Text('🎨', style: TextStyle(fontSize: 38))),
                  ),
                  const SizedBox(height: 12),
                  Text(_user?.name ?? '',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(_user?.username ?? '',
                      style: const TextStyle(fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.w500)),
                ]),
              ),
              const SizedBox(height: 28),

              const SectionHeader(title: 'Account'),
              const SizedBox(height: 4),
              SettingsRow(
                emoji: '👤',
                label: 'Personal Information',
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(user: _user)));
                  _load();
                },
              ),
              const SettingsRow(emoji: '❤️', label: 'My Watchlist'),
              const SettingsRow(emoji: '📦', label: 'My Listings'),
              SettingsRow(
                emoji: '⚙️',
                label: 'Settings',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
              const SizedBox(height: 16),
              const SectionHeader(title: 'Other'),
              const SizedBox(height: 4),
              const SettingsRow(emoji: '❓', label: 'Help & Support'),
              const SettingsRow(emoji: '📄', label: 'About 2GoodsMate'),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// EDIT PROFILE
// ════════════════════════════════════════════════════════
class EditProfileScreen extends StatefulWidget {
  final UserModel? user;
  const EditProfileScreen({super.key, this.user});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl     = TextEditingController();
  final _usernameCtrl = TextEditingController();
  XFile? _pickedImage;
  String? _existingImageUrl;
  bool _loading = false;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nameCtrl.text     = widget.user!.name;
      _usernameCtrl.text = widget.user!.username;
      _existingImageUrl  = widget.user!.profileImageUrl;
    }
  }

  @override
  void dispose() { _nameCtrl.dispose(); _usernameCtrl.dispose(); super.dispose(); }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _pickedImage = image);
    }
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }

    String? imageUrl = _existingImageUrl;

    // อัปโหลดรูปถ้ามีการเลือก
    if (_pickedImage != null) {
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('$uid.jpg');
        
        if (kIsWeb) {
          // For Web: use putData with bytes
          final bytes = await _pickedImage!.readAsBytes();
          await ref.putData(bytes);
        } else {
          // For Mobile: use putFile
          await ref.putFile(File(_pickedImage!.path));
        }
        
        imageUrl = await ref.getDownloadURL();
      } catch (e) {
        print('Error uploading image: $e');
      }
    }

    // บันทึก user data
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': _nameCtrl.text.trim(),
      'username': _usernameCtrl.text.trim(),
      'profileImageUrl': imageUrl,
    }, SetOptions(merge: true));

    setState(() => _loading = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(children: [
                Stack(
                  children: [
                    Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppTheme.accent, AppTheme.accentDark]),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.accent.withOpacity(0.3), width: 3),
                      ),
                      child: _pickedImage != null
                          ? ClipOval(
                              child: kIsWeb
                                  ? Image.network(_pickedImage!.path, fit: BoxFit.cover)
                                  : Image.file(File(_pickedImage!.path), fit: BoxFit.cover)
                            )
                          : _existingImageUrl != null
                              ? ClipOval(child: Image.network(_existingImageUrl!, fit: BoxFit.cover))
                              : const Center(child: Text('🎨', style: TextStyle(fontSize: 50))),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.accent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Tap camera to add photo', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 28),
            _label('Display Name'),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              decoration: const InputDecoration(hintText: 'Your name'),
            ),
            const SizedBox(height: 16),
            _label('Username'),
            const SizedBox(height: 6),
            TextField(
              controller: _usernameCtrl,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              decoration: const InputDecoration(hintText: '@username'),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _loading ? null : _save,
              child: Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.accent, AppTheme.accentDark]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: AppTheme.accent.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 4))],
                ),
                child: Center(
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Changes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text.toUpperCase(),
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 0.6));
}
