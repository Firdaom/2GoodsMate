import 'package:anigoods/core/services/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/core/router/app_router.dart';
import 'package:anigoods/models/order_model.dart';
import 'package:anigoods/features/order/services/order_service.dart';

class OrderScreen extends StatelessWidget {
  final List<ItemModel> items;

  const OrderScreen({super.key, required this.items});

  String _formatPrice(double price) => price
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    const double deliveryFee = 50.0;
    final double subtotal = items.fold(0, (sum, item) => sum + item.price);
    final double totalPrice = subtotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
              title: 'John Doe (+66 81 234 5678)',
              subtitle:
                  '123 Anime Street, Otaku District\nBangkok, Thailand 10110',
              actionIcon: Icons.edit_outlined,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit address coming soon!')),
                );
              },
            ),
            const SizedBox(height: 24),

            const SectionLabel('ITEM SUMMARY'),
            const SizedBox(height: 8),

            // 🔥 3. แสดงรายการสินค้าทุกชิ้นในตะกร้า
            Container(
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
                            ItemImage(
                              imageUrls: item.imageUrls,
                              size: 60,
                              radius: 8,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '฿${_formatPrice(item.price)}',
                                    style: const TextStyle(
                                      color: AppTheme.accent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(), // วนลูปโชว์ของทุกชิ้น
              ),
            ),
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

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  _buildPriceRow('Subtotal', subtotal), // โชว์ราคาของรวมทั้งหมด
                  const SizedBox(height: 12),
                  _buildPriceRow('Delivery Fee', deliveryFee),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Payment',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '฿${_formatPrice(totalPrice)}',
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
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.background,
          border: const Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: PrimaryButton(
                  label: 'Place Order',
                  onTap: () async {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please login to place an order.'),
                        ),
                      );
                      return;
                    }

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.accent,
                        ),
                      ),
                    );

                    try {
                      // 🔥 4. วนลูปบันทึกออเดอร์ลง Firebase ทีละชิ้น
                      for (var item in items) {
                        final newOrder = OrderModel(
                          id: '',
                          itemId: item.id,
                          buyerId: currentUser.uid,
                          sellerId: item.sellerId,
                          status: 'to_ship',
                          totalPrice: item.price, // บันทึกราคาแยกแต่ละชิ้น
                          shippingAddress: {
                            'name': 'John Doe',
                            'phone': '+66 81 234 5678',
                            'detail': '123 Anime Street, Bangkok 10110',
                          },
                          createdAt: DateTime.now(),
                        );
                        await OrderService().createOrder(newOrder);
                      }

                      if (context.mounted)
                        Navigator.pop(context); // ปิดหน้าต่าง Loading

                      // ล้างตะกร้าเมื่อสั่งซื้อสำเร็จ
                      CartService().clearCart();

                      if (context.mounted) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => AlertDialog(
                            title: const Text(' Order Placed'),
                            content: const Text(
                              'Your order has been placed successfully.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // วาร์ปกลับไปหน้าประวัติการสั่งซื้อ หรือ หน้าแรก
                                  context.go('/home');
                                },
                                child: const Text(
                                  'Back to Home',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted)
                        Navigator.pop(context); // ปิด Loading
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Failed to place order. Please try again.',
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันวาด UI ย่อย (ดึงมาจากโค้ดเดิมของคุณ)
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
              child: Icon(icon, color: AppTheme.accent, size: 24),
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
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(actionIcon, color: AppTheme.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        Text(
          '฿${_formatPrice(amount)}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }
}
