import 'package:anigoods/core/router/app_router.dart';
import 'package:anigoods/core/widgets/item_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anigoods/models/order_model.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/core/constants/firebase_constants.dart';
import 'status_step.dart';

class OrderStatusScreen extends StatefulWidget {
  final String orderId;
  const OrderStatusScreen({super.key, required this.orderId});

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  OrderModel? _order;
  ItemModel? _item;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOrderData();
  }

  Future<void> _fetchOrderData() async {
    try {
      final db = FirebaseFirestore.instance;

      // 1. ดึงออเดอร์ (ใช้ Constant)
      final orderDoc = await db
          .collection(FirebaseCollections.orders)
          .doc(widget.orderId)
          .get();
      if (!orderDoc.exists) throw Exception('Order not found');

      final order = OrderModel.fromFirestore(orderDoc);

      // 2. ดึงข้อมูลสินค้า
      final itemDoc = await db
          .collection(FirebaseCollections.items)
          .doc(order.itemId)
          .get();
      if (!itemDoc.exists) throw Exception('Item not found');

      final itemData = itemDoc.data() as Map<String, dynamic>;

      List<String> parsedImageUrls = [];
      if (itemData[ItemFields.imageUrls] != null &&
          itemData[ItemFields.imageUrls] is List) {
        parsedImageUrls = List<String>.from(itemData[ItemFields.imageUrls]);
      }

      setState(() {
        _order = order;
        _item = ItemModel.fromFirestore(itemDoc);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int stateIndex = -2; // Default
    if (_order != null) {
      switch (_order!.status) {
        case OrderStatus.toPay:
          stateIndex = 0;
          break;
        case OrderStatus.toShip:
          stateIndex = 1;
          break;
        case OrderStatus.toReceive:
          stateIndex = 2;
          break;
        case OrderStatus.completed:
          stateIndex = 3;
          break;
        case OrderStatus.cancelled:
          stateIndex = -1;
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Status',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.canPop(context)
              ? Navigator.pop(context)
              : context.go(RouteNames.home.path),
        ),
      ),
      body: _buildBody(stateIndex),
      bottomNavigationBar: _buildBottomAction(stateIndex),
    );
  }

  //  จัดการปุ่มด้านล่าง
  Widget? _buildBottomAction(int stateIndex) {
    if (_order == null || stateIndex == -1 || stateIndex == 3) return null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // ปุ่มยกเลิก (โชว์เฉพาะยังไม่ส่ง)
            if (stateIndex <= 1) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showCancelDialog(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: AppTheme.danger),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel Order',
                    style: TextStyle(
                      color: AppTheme.danger,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: SafeArea(
                child: SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Contact Seller',
                    onTap: () => context.push(
                      RouteNames.chat.path,
                      extra: _item?.sellerName,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  ฟังก์ชันกดยกเลิกออเดอร์
  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() => _isLoading = true);
              try {
                await FirebaseFirestore.instance
                    .collection(FirebaseCollections.orders)
                    .doc(widget.orderId)
                    .update({
                      OrderFields.status: OrderStatus.cancelled.name,
                    }); // ✅ อัปเดตด้วย Enum.name

                _fetchOrderData(); // โหลดข้อมูลใหม่เพื่อโชว์สถานะยกเลิก
              } catch (e) {
                setState(() => _isLoading = false);
              }
            },
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(int stateIndex) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accent),
      );
    }
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          'Error: $_errorMessage',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (_order == null || _item == null) {
      return const Center(child: Text('Order details not found.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // การ์ดแสดงข้อมูลสินค้า
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Order ID',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '#${_order!.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accent,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    ItemImage(imageUrls: _item!.imageUrls, size: 50, radius: 8),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _item!.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Seller: ${_item!.sellerName}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          const SectionLabel('TRACKING HISTORY'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                if (stateIndex == -1)
                  const StatusStep(
                    icon: Icons.cancel_outlined,
                    title: 'Order Cancelled',
                    subtitle: 'This order has been cancelled.',
                    time: 'Cancelled',
                    isActive: false,
                    isPending: false,
                    isLast: true,
                    isError: true,
                  )
                else ...[
                  StatusStep(
                    icon: Icons.inventory_2_outlined,
                    title: 'Order Placed',
                    subtitle: 'Waiting for seller to confirm.',
                    time: stateIndex >= 0 ? 'Completed' : 'Pending',
                    isActive: stateIndex == 0,
                    isPending: stateIndex < 0,
                    isLast: false,
                  ),
                  StatusStep(
                    icon: Icons.payments_outlined,
                    title: 'Payment Confirmed',
                    subtitle: 'Payment has been verified.',
                    time: stateIndex >= 1 ? 'Completed' : 'Pending',
                    isActive: stateIndex == 1,
                    isPending: stateIndex < 1,
                    isLast: false,
                  ),
                  StatusStep(
                    icon: Icons.local_shipping_outlined,
                    title: 'Shipped',
                    subtitle: 'Seller has shipped the package.',
                    time: stateIndex >= 2 ? 'Completed' : 'Pending',
                    isActive: stateIndex == 2,
                    isPending: stateIndex < 2,
                    isLast: false,
                  ),
                  StatusStep(
                    icon: Icons.home_outlined,
                    title: 'Delivered',
                    subtitle: 'Package arrived at destination.',
                    time: stateIndex == 3 ? 'Completed' : 'Pending',
                    isActive: stateIndex == 3,
                    isPending: stateIndex < 3,
                    isLast: true,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
