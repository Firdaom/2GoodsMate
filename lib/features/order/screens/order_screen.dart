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
  final ItemModel item;

  const OrderScreen({super.key, required this.item});

  String _formatPrice(double price) => price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );

  @override
  Widget build(BuildContext context) {
    const double deliveryFee = 50.0;
    final double totalPrice = item.price + deliveryFee;

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
              subtitle: '123 Anime Street, Otaku District\nBangkok, Thailand 10110',
              actionIcon: Icons.edit_outlined,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit address coming soon!')));
              },
            ),
            const SizedBox(height: 24),

            const SectionLabel('ITEM SUMMARY'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  ItemImage(imageUrls: item.imageUrls, size: 72, radius: 12),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        ConditionWithRarity(condition: item.condition, rarity: item.rarity),
                        const SizedBox(height: 8),
                        Text(
                          '฿${_formatPrice(item.price)}',
                          style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
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
                  _buildPriceRow('Subtotal', item.price),
                  const SizedBox(height: 12),
                  _buildPriceRow('Delivery Fee', deliveryFee),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        '฿${_formatPrice(totalPrice)}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppTheme.accent),
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
                  // 🔥 3. อัปเกรด onTap ให้เชื่อม Database
                  onTap: () async {
                    // เช็คก่อนว่าล็อกอินหรือยัง
                    final currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please login to place an order.')),
                      );
                      return;
                    }

                    // โชว์วงกลม Loading หมุนๆ ระหว่างบันทึกข้อมูล
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.accent)),
                    );

                    // สร้างก้อนข้อมูล Order ตาม Model ที่เราออกแบบไว้
                    final newOrder = OrderModel(
                      id: '', // ปล่อยว่างให้ Firebase จัดการ
                      itemId: item.id,
                      buyerId: currentUser.uid,
                      sellerId: item.sellerId,
                      status: 'to_ship', // สมมติว่าชำระเงินเรียบร้อย รอแม่ค้าส่งของ
                      totalPrice: totalPrice,
                      shippingAddress: {
                        'name': 'John Doe',
                        'phone': '+66 81 234 5678',
                        'detail': '123 Anime Street, Bangkok 10110',
                      },
                      createdAt: DateTime.now(),
                    );

                    // ยิงข้อมูลไปที่ Firebase ผ่าน OrderService
                    final orderId = await OrderService().createOrder(newOrder);

                    // ปิดหน้าจอ Loading
                    if (context.mounted) Navigator.pop(context);

                    if (orderId != null && context.mounted) {

                      CartService().clearCart(); 
       
                      // ถ้าสำเร็จ โชว์ Dialog สวยๆ
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                          title: const Text('🎉 Order Placed!'),
                          content: const Text('Your order has been saved to database successfully.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // ปิด Dialog
                                // 🚀 ไปหน้า Order Status 
                                context.go(RouteNames.orderStatus.path, extra: orderId!);
                              },
                              child: const Text('View Order Status', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    } else if (context.mounted) {
                      // ถ้าพัง โชว์แจ้งเตือนด้านล่าง
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to place order. Please try again.')),
                      );
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
              decoration: BoxDecoration(color: AppTheme.accentLight, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: AppTheme.accent, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, height: 1.4)),
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
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        Text('฿${_formatPrice(amount)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}