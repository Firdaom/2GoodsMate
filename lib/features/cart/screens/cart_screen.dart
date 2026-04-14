import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:go_router/go_router.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/core/router/app_router.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/features/cart/providers/cart_provider.dart'; 

class CartScreen extends ConsumerWidget { 
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { 
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: cartItems.isEmpty
          ? const EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              subtitle: 'Looks like you haven\'t added any items yet.',
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(context, ref, item);
                    },
                  ),
                ),
                _buildCheckoutSection(context, ref, cartItems),
              ],
            ),
    );
  }

  // Widget ย่อยสำหรับแสดงสินค้าแต่ละชิ้น
  Widget _buildCartItem(BuildContext context, WidgetRef ref, ItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          ItemImage(imageUrls: item.imageUrls, size: 60, radius: 10),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  '฿${item.price.toStringAsFixed(0)}',
                  style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ref.read(cartProvider.notifier).removeFromCart(item.id);
            },
            icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 22),
          ),
        ],
      ),
    );
  }

  // ส่วนสรุปราคาและปุ่ม Checkout
  Widget _buildCheckoutSection(BuildContext context, WidgetRef ref, List<ItemModel> cartItems) {
    // คำนวณราคาทั้งหมดจาก cartItems ในปัจจุบัน
    final double total = cartItems.fold(0, (sum, item) => sum + item.price);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(top: BorderSide(color: AppTheme.border)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                Text(
                  '฿${total.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.accent),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Checkout Now (${cartItems.length} items)',
              onTap: () {
                if (cartItems.isNotEmpty) {
                  context.push(RouteNames.order.path, extra: {
                    'items': cartItems,
                    'isFromCart': true,
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}