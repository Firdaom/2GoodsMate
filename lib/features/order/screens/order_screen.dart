import 'package:anigoods/core/constants/firebase_constants.dart';
import 'package:anigoods/core/widgets/item_image.dart';
import 'package:anigoods/features/cart/providers/cart_provider.dart';
import 'package:anigoods/features/order/screens/address_card.dart';
import 'package:anigoods/features/watchlist/providers/watchlist_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/core/router/app_router.dart';
import 'package:anigoods/models/order_model.dart';
import 'package:anigoods/core/services/order_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anigoods/features/home/providers/home_provider.dart';
import 'package:anigoods/features/item_detail/providers/item_detail_provider.dart';

class OrderScreen extends ConsumerStatefulWidget {
  final List<ItemModel> items;
  final bool isFromCart;

  const OrderScreen({super.key, required this.items, this.isFromCart = false});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  // 🌟 เก็บที่อยู่ไว้แค่ตัวแปรเดียว เพื่อเอาไว้ส่งเข้า Firebase ตอนกดสั่งซื้อ
  Map<String, dynamic> _finalAddress = {
    'name': '',
    'phone': '',
    'detail': '',
  };

  bool get _hasAddress => 
      _finalAddress['name'].isNotEmpty && 
      _finalAddress['phone'].isNotEmpty && 
      _finalAddress['detail'].isNotEmpty;

  String _formatPrice(double price) => price
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    const double deliveryFee = 50.0;
    final double subtotal = widget.items.fold(0, (sum, item) => sum + item.price);
    final double totalPrice = subtotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AddressManagerCard(
              onAddressUpdated: (newAddress) {
                setState(() {
                  _finalAddress = newAddress;
                });
              },
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
      bottomNavigationBar: _buildBottomBar(context, ref, totalPrice, _finalAddress),
    );
  }

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
              
              if (!_hasAddress) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please tap on "Shipping Address" to add your details first.'),
                    backgroundColor: AppTheme.danger,
                  ),
                );
                return; 
              }

              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser == null) return;

              // แสดง Loading
              _showLoadingDialog(context);

              try {
                final orderService = ref.read(orderServiceProvider);

                // บันทึกออเดอร์ทีละชิ้น
                for (var item in widget.items) {
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

                  ref.invalidate(itemDetailProvider(item.id));
                }

                if (context.mounted) {
                  Navigator.pop(context); 
                  _showSuccessDialog(context); 

                  for (var item in widget.items) {
                    ref.read(cartProvider.notifier).removeFromCart(item.id); 
                  }

                  // ล้างตะกร้า
                  if (widget.isFromCart) {
                    ref.read(cartProvider.notifier).clearCart();
                  }

                  ref.invalidate(homeItemsProvider);

                  ref.invalidate(watchlistItemsProvider);

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
        children: widget.items
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