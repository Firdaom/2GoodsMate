import 'package:anigoods/features/profile/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:anigoods/models/user_model.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/services/error_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 

class EditProfileScreen extends ConsumerStatefulWidget { 
  final UserModel? user;
  const EditProfileScreen({super.key, this.user});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> { 
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  XFile? _pickedImage;
  String? _existingImageUrl;
  bool _loading = false;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nameCtrl.text = widget.user!.name;
      _usernameCtrl.text = widget.user!.username;
      _existingImageUrl = widget.user!.profileImageUrl;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

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

    try {
      String? imageUrl = _existingImageUrl;

      final userRepo = ref.read(userRepositoryProvider);

      if (_pickedImage != null) {
        try {
          imageUrl = await userRepo.uploadProfileImage(uid: uid, image: _pickedImage!);
        } catch (e) {
          ErrorHandler.showError(context, e, contextLabel: 'Edit Image Upload');
        }
      }

      await userRepo.updateUserProfile(
        uid: uid,
        name: _nameCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        profileImageUrl: imageUrl,
      );

      if (mounted) {
        ErrorHandler.showSuccess(context, 'Profile updated successfully!');
        Navigator.pop(context, true); 
      }
    } catch (e) {
      ErrorHandler.showError(context, e, contextLabel: 'Edit Profile Save');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
              child: Column(
                children: [
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
                            ? ClipOval(child: kIsWeb ? Image.network(_pickedImage!.path, fit: BoxFit.cover) : Image.file(File(_pickedImage!.path), fit: BoxFit.cover))
                            : _existingImageUrl != null
                                ? ClipOval(child: Image.network(_existingImageUrl!, fit: BoxFit.cover))
                                : const Center(child: Icon(Icons.person, size: 50, color: AppTheme.textMuted)),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Tap camera to add photo', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _label('Display Name'),
            const SizedBox(height: 6),
            TextField(controller: _nameCtrl, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13), decoration: const InputDecoration(hintText: 'Your name')),
            const SizedBox(height: 16),
            _label('Username'),
            const SizedBox(height: 6),
            TextField(controller: _usernameCtrl, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13), decoration: const InputDecoration(prefixText: '@', hintText: 'username')),
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

  Widget _label(String text) => Text(text.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 0.6));
}