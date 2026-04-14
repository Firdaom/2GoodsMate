import 'package:anigoods/features/cart/providers/cart_provider.dart';
import 'package:anigoods/features/cart/services/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/core/router/app_router.dart';
import 'package:anigoods/models/order_model.dart';
import 'package:anigoods/features/order/services/order_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anigoods/features/order/services/order_service.dart';

class OrderScreen extends ConsumerWidget {
  final List<ItemModel> items;
  final bool isFromCart;

  const OrderScreen({super.key, required this.items, this.isFromCart = false});

  String _formatPrice(double price) => price
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double deliveryFee = 50.0;
    final double subtotal = items.fold(0, (sum, item) => sum + item.price);
    final double totalPrice = subtotal + deliveryFee;

    // จำลองที่อยู่ (ในอนาคตควรดึงจาก ProfileProvider)
    final Map<String, dynamic> currentAddress = {
      'name': 'John Doe',
      'phone': '+66 81 234 5678',
      'detail': '123 Anime Street, Bangkok 10110',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('SHIPPING ADDRESS'),
            const SizedBox(height: 8),
            _buildInfoCard(
              icon: Icons.location_on_outlined,
              title: '${currentAddress['name']} (${currentAddress['phone']})',
              subtitle: currentAddress['detail'],
              actionIcon: Icons.edit_outlined,
              onTap: () {},
            ),
            const SizedBox(height: 24),

            const SectionLabel('ITEM SUMMARY'),
            const SizedBox(height: 8),
            _buildItemSummaryList(),
            const SizedBox(height: 24),

            const SectionLabel('PAYMENT METHOD'),
            const SizedBox(height: 8),
            _buildInfoCard(
              icon: Icons.credit_card_outlined,
              title: 'Mobile Banking / QR PromptPay',
              subtitle: 'Tap to change payment method',
              actionIcon: Icons.chevron_right,
              onTap: () {},
            ),
            const SizedBox(height: 32),
            _buildPriceDetails(subtotal, deliveryFee, totalPrice),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(
        context,
        ref,
        totalPrice,
        currentAddress,
      ),
    );
  }

  //  ส่วนบันทึกออเดอร์
  Widget _buildBottomBar(
    BuildContext context,
    WidgetRef ref,
    double totalPrice,
    Map<String, dynamic> address,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        child: SizedBox(
              height: 52,
              width: double.infinity,
              child: PrimaryButton(
                label: 'Place Order • ฿${_formatPrice(totalPrice)}',
              onTap: () async {
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser == null) return;

                // แสดง Loading
                _showLoadingDialog(context);

                try {
                  final orderService = ref.read(orderServiceProvider);

                  //  บันทึกออเดอร์ทีละชิ้น
                  for (var item in items) {
                    final newOrder = OrderModel(
                      id: '',
                      itemId: item.id,
                      buyerId: currentUser.uid,
                      sellerId: item.sellerId,
                      status: OrderStatus.toShip,
                      totalPrice: item.price,
                      shippingAddress: address,
                      createdAt: DateTime.now(),
                    );
                    await orderService.createOrder(newOrder);
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    _showSuccessDialog(context);

                    //ล้างตะกร้า
                    if (isFromCart) {
                      ref.read(cartProvider.notifier).clearCart();
                    }
                  }
                } catch (e) {
                  if (context.mounted) Navigator.pop(context);
                  _showErrorSnackBar(context, e);
                }
              },
            ),
          ),
        ),
    );
  }

  // --- Helper Widgets (UI) ---

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppTheme.accent),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(' Order Placed!'),
        content: const Text('Your collectibles are on the way.'),
        actions: [
          TextButton(
            onPressed: () => context.go(RouteNames.profile.path),
            child: const Text(
              'View Purchases',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, dynamic e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: AppTheme.danger,
      ),
    );
  }

  Widget _buildItemSummaryList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ItemImage(imageUrls: item.imageUrls, size: 50, radius: 8),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '฿${_formatPrice(item.price)}',
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildPriceDetails(double subtotal, double fee, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', subtotal),
          const SizedBox(height: 12),
          _buildPriceRow('Delivery Fee', fee),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Payment',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '฿${_formatPrice(total)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: AppTheme.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        Text(
          '฿${_formatPrice(amount)}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required IconData actionIcon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accentLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.accent, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(actionIcon, color: AppTheme.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
