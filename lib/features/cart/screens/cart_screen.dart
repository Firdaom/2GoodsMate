import 'package:flutter/material.dart';
import 'package:anigoods/core/services/cart_service.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/core/router/app_router.dart';
import 'package:go_router/go_router.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      // ครอบ Body ด้วย ListenableBuilder เพื่อให้หน้าจออัปเดตตอนกดลบของ
      body: ListenableBuilder(
        listenable: CartService(),
        builder: (context, child) {
          final cartItems = CartService().items;

          if (cartItems.isEmpty) {
            return const EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              subtitle: 'Looks like you haven\'t added any items yet.',
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
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
                          ItemImage(imageUrls: item.imageUrls, size: 60),
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
                                  ),
                                ),
                                Text(
                                  '฿${item.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: AppTheme.accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // ลบของออก เดี๋ยวมันวาดหน้าใหม่เอง ไม่ต้องใช้ setState
                              CartService().removeFromCart(item);
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppTheme.danger,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              _buildCheckoutSection(context, cartItems),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context, List cartItems) {
    final total = CartService().totalPrice;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  '฿${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Checkout Now',
              onTap: () {
                if (cartItems.isNotEmpty) {
                  final itemToOrder = cartItems.first;
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  context.push(RouteNames.order.path, extra: itemToOrder);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
