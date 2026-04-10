import 'package:anigoods/core/router/app_router.dart';
import 'package:anigoods/features/profile/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:anigoods/models/user_model.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/services/error_handler.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/features/profile/screens/setting_screen.dart';
import 'package:anigoods/features/profile/screens/edit_profile_screen.dart';
import 'package:go_router/go_router.dart';

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
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final userRepo = UserRepository(); 
    final user = await userRepo.getUserProfile(uid); 
    if (mounted) setState(() => _user = user);
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
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // Avatar
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.accent, AppTheme.accentDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.accent.withOpacity(0.3),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accent.withOpacity(0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _user?.profileImageUrl != null
                          ? ClipOval(
                              child: Image.network(
                                _user!.profileImageUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.person,
                                size: 38,
                                color: AppTheme.border,
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _user?.name ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _user?.username != null && _user!.username.isNotEmpty
                          ? '@${_user!.username}'
                          : '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

             const SectionLabel( 'ACCOUNT'),
              const SizedBox(height: 8),
              
              SettingsRow(
                icon: Icons.person_outline,
                label: 'Personal Information',
                onTap: () async {
                  // 👇 1. เพิ่ม rootNavigator: true ตรงนี้ เพื่อให้ Bottom Bar หายไปตอนแก้โปรไฟล์
                  await Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(user: _user),
                    ),
                  );
                  _load();
                },
              ),
               SettingsRow(
                icon: Icons.inventory_2_outlined,
                label: 'My Listings',
                onTap: () => context.push(RouteNames.myListings.path),
             
              ),
              
              SettingsRow(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () => context.push(RouteNames.settings.path), 
              ),
            ],
          ),
        ),
      ),
    );
  }
}