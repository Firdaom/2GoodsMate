import 'package:anigoods/core/services/moderation_service.dart';
import 'package:anigoods/core/router/app_router.dart';
import 'package:anigoods/features/profile/repositories/user_repository.dart';
import 'package:anigoods/models/item_model.dart';
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
import 'package:cloud_firestore/cloud_firestore.dart';


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

  int _toPayCount = 0;
  int _toShipCount = 0;
  int _toReceiveCount = 0;
  int _toRateCount = 0;
  String? _latestOrderId;

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
    try {
      final orderSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('buyerId', isEqualTo: uid)
          .orderBy('createdAt', descending: true) // เรียงจากใหม่ไปเก่า
          .get();

      int pay = 0, ship = 0, receive = 0, rate = 0;
      String? latestId;

      if (orderSnapshot.docs.isNotEmpty) {
        latestId = orderSnapshot.docs.first.id; // เก็บ ID ออเดอร์ล่าสุดไว้
        
        // นับจำนวนสถานะต่างๆ
        for (var doc in orderSnapshot.docs) {
          final status = doc.data()['status'] as String?;
          if (status == 'to_pay') pay++;
          else if (status == 'to_ship') ship++;
          else if (status == 'to_receive') receive++;
          else if (status == 'completed') rate++;
        }
      }

      if (mounted) {
        setState(() {
          _user = user;
          _toPayCount = pay;
          _toShipCount = ship;
          _toReceiveCount = receive;
          _toRateCount = rate;
          _latestOrderId = latestId; // อัปเดต ID ล่าสุด
        });
      }
    } catch (e) {
      print('Error fetching orders: $e');
      if (mounted) setState(() => _user = user);
    }
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

            // 🛒 แผงแสดงสถานะออเดอร์ (สไตล์ Shopee)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('My Purchases', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        GestureDetector(
                          onTap: () {
                            // 🔥 1. เปลี่ยนให้เด้งไปหน้า Purchase History แท็บ All (index 0)
                            context.push(RouteNames.purchaseHistory.path, extra: 0);
                          },
                          child: Row(
                            children: const [
                              Text('View Purchase History', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                              Icon(Icons.chevron_right, size: 16, color: AppTheme.textMuted),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _OrderStatusIcon(
                          icon: Icons.account_balance_wallet_outlined, 
                          label: 'To Pay', 
                          count: _toPayCount, 
                          // 🔥 2. ส่ง index 1 ไปเปิดแท็บ To Pay
                          onTap: () => context.push(RouteNames.purchaseHistory.path, extra: 1),
                        ),
                        _OrderStatusIcon(
                          icon: Icons.inventory_2_outlined, 
                          label: 'To Ship', 
                          count: _toShipCount, 
                          // 🔥 3. ส่ง index 2 ไปเปิดแท็บ To Ship
                          onTap: () => context.push(RouteNames.purchaseHistory.path, extra: 2),
                        ),
                        _OrderStatusIcon(
                          icon: Icons.local_shipping_outlined, 
                          label: 'To Receive', 
                          count: _toReceiveCount, 
                          // 🔥 4. ส่ง index 3 ไปเปิดแท็บ To Receive
                          onTap: () => context.push(RouteNames.purchaseHistory.path, extra: 3),
                        ),
                        _OrderStatusIcon(
                          icon: Icons.star_border, 
                          label: 'To Rate', 
                          count: _toRateCount, 
                          // 🔥 5. ส่ง index 4 ไปเปิดแท็บ To Rate
                          onTap: () => context.push(RouteNames.purchaseHistory.path, extra: 4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24), 

             SectionLabel( 'ACCOUNT'),
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


// ─── Widget สำหรับสร้างไอคอนสถานะ + ตัวเลขแจ้งเตือน (Badge) ────────────────
class _OrderStatusIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  const _OrderStatusIcon({
    required this.icon,
    required this.label,
    this.count = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: AppTheme.textPrimary, size: 28),
              // ถ้ามีตัวเลข (มากกว่า 0) ถึงจะโชว์วงกลมสีแดง
              if (count > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppTheme.danger, // ใช้สีแดงใน Theme ของคุณ
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.surface, width: 2), // ขอบขาวให้ดูมีมิติ
                    ),
                    child: Text(
                      count > 99 ? '99+' : count.toString(), // ถ้าเกิน 99 ให้โชว์ 99+
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 9, 
                        fontWeight: FontWeight.w900,
                        height: 1, // จัดให้อยู่ตรงกลางวงกลม
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}