import 'package:anigoods/core/router/app_router.dart';
import 'package:anigoods/features/profile/repositories/user_repository.dart';
import 'package:anigoods/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:anigoods/models/user_model.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/features/profile/screens/edit_profile_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  UserModel? _user;
  int unreadMessages = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => _load());
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    
    final user = await ref.read(userRepositoryProvider).getUserProfile(uid);
    
    if (mounted) {
      setState(() {
        _user = user;
      });
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  Row(
                    children: [
                      const CartIconButton(),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () => context.push(RouteNames.chat.path, extra: 'Chat List'),
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.sms_outlined, color: AppTheme.textPrimary, size: 24),
                            if (unreadMessages > 0)
                              Positioned(
                                right: -2, top: -2,
                                child: Container(
                                  width: 10, height: 10,
                                  decoration: BoxDecoration(color: AppTheme.danger, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 👤 ส่วนข้อมูล User 
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 88, height: 88,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppTheme.accent, AppTheme.accentDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.accent.withOpacity(0.3), width: 3),
                        boxShadow: [BoxShadow(color: AppTheme.accent.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 4))],
                      ),
                      child: _user?.profileImageUrl != null
                          ? ClipOval(child: Image.network(_user!.profileImageUrl!, fit: BoxFit.cover))
                          : const Center(child: Icon(Icons.person, size: 38, color: AppTheme.border)),
                    ),
                    const SizedBox(height: 12),
                    Text(_user?.name ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    const SizedBox(height: 4),
                    Text(_user?.username != null && _user!.username.isNotEmpty ? '@${_user!.username}' : '',
                        style: const TextStyle(fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 🛒 แผงสถานะออเดอร์
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('My Purchases', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        GestureDetector(
                          onTap: () => context.push(RouteNames.purchaseHistory.path, extra: 0),
                          child: Row(children: const [
                            Text('View Purchase History', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                            Icon(Icons.chevron_right, size: 16, color: AppTheme.textMuted),
                          ]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('orders')
                          .where('buyerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                          .where('status', whereIn: [
                            OrderStatus.toPay.name,
                            OrderStatus.toShip.name,
                            OrderStatus.toReceive.name,
                            OrderStatus.completed.name
                          ]).snapshots(),
                      builder: (context, snapshot) {
                        int pay = 0, ship = 0, receive = 0, rate = 0;
                        if (snapshot.hasData) {
                          for (var doc in snapshot.data!.docs) {
                            final status = doc.get('status') as String?;
                            if (status == OrderStatus.toPay.name) pay++;
                            else if (status == OrderStatus.toShip.name) ship++;
                            else if (status == OrderStatus.toReceive.name) receive++;
                            else if (status == OrderStatus.completed.name) rate++;
                          }
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _OrderStatusIcon(icon: Icons.account_balance_wallet_outlined, label: 'To Pay', count: pay, onTap: () => context.push(RouteNames.purchaseHistory.path, extra: 1)),
                            _OrderStatusIcon(icon: Icons.inventory_2_outlined, label: 'To Ship', count: ship, onTap: () => context.push(RouteNames.purchaseHistory.path, extra: 2)),
                            _OrderStatusIcon(icon: Icons.local_shipping_outlined, label: 'To Receive', count: receive, onTap: () => context.push(RouteNames.purchaseHistory.path, extra: 3)),
                            _OrderStatusIcon(icon: Icons.star_border, label: 'To Rate', count: rate, onTap: () => context.push(RouteNames.purchaseHistory.path, extra: 4)),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ACCOUNT Section
              const SectionLabel('ACCOUNT'),
              const SizedBox(height: 8),
              SettingsRow(
                icon: Icons.person_outline,
                label: 'Personal Information',
                onTap: () async {
                  await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => EditProfileScreen(user: _user)));
                  _load();
                },
              ),
              SettingsRow(icon: Icons.inventory_2_outlined, label: 'My Listings', onTap: () => context.push(RouteNames.myListings.path)),
              SettingsRow(icon: Icons.storefront_outlined, label: 'Switch Role', onTap: () {}),
              SettingsRow(icon: Icons.settings_outlined, label: 'Settings', onTap: () => context.push(RouteNames.settings.path)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderStatusIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  const _OrderStatusIcon({required this.icon, required this.label, this.count = 0, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: AppTheme.textPrimary, size: 28),
              if (count > 0)
                Positioned(
                  right: -6, top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: AppTheme.danger, shape: BoxShape.circle, border: Border.all(color: AppTheme.surface, width: 2)),
                    child: Text(count > 99 ? '99+' : count.toString(), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, height: 1)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}