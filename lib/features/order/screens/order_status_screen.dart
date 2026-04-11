import 'package:anigoods/core/router/app_router.dart';
import 'package:anigoods/core/services/moderation_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anigoods/models/order_model.dart';
import 'package:anigoods/models/item_model.dart';

// 🔥 เปลี่ยนให้รับแค่ orderId
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

  // 🚀 ฟังก์ชันดึงข้อมูลจาก Firebase
  Future<void> _fetchOrderData() async {
    try {
      final db = FirebaseFirestore.instance;

      // 1. ดึงออเดอร์
      final orderDoc = await db.collection('orders').doc(widget.orderId).get();
      if (!orderDoc.exists) throw Exception('Order not found');

      final order = OrderModel.fromFirestore(orderDoc);

      // 2. ดึงข้อมูลสินค้าที่ผูกกับออเดอร์นี้
      final itemDoc = await db.collection('items').doc(order.itemId).get();
      if (!itemDoc.exists) throw Exception('Item not found');

      final itemData = itemDoc.data() as Map<String, dynamic>; // ดึง Data มาเก็บไว้ก่อน

      // 🔥 โค้ดนักสืบหารูปภาพแบบเดียวกับหน้า My Purchases!
      List<String> parsedImageUrls = [];
      if (itemData['imageUrls'] != null && itemData['imageUrls'] is List && (itemData['imageUrls'] as List).isNotEmpty) {
        // ถ้ามีแบบ List ให้ดึงมาใส่
        parsedImageUrls = (itemData['imageUrls'] as List).map((e) => e.toString()).toList();
      } else if (itemData['imageUrl'] != null && itemData['imageUrl'] is String) {
        // ถ้ามีแบบรูปเดียวดั้งเดิม ให้จับใส่ List
        parsedImageUrls = [itemData['imageUrl']];
      }

      // นำข้อมูลมาสร้าง ItemModel
      final item = ItemModel(
        id: itemDoc.id,
        series: itemData['series'] ?? '',
        sellerId: itemData['sellerId'] ?? '',
        sellerName: itemData['sellerName'] ?? 'Unknown',
        title: itemData['title'] ?? 'Unknown Item',
        description: itemData['description'] ?? '',
        price: (itemData['price'] ?? 0.0).toDouble(),
        
        imageUrls: parsedImageUrls, 
        
        category: itemData['category'] ?? '',
        condition: itemData['condition'] ?? '',
        rarity: itemData['Rarity'] ?? '',
        tags: [],
        contactLinks: [],
        postedAt: DateTime.now(),
        sellerVerified: false,
        moderationStatus: ModerationStatus.approved,
        qualityScore: 100,
        reportCount: 0,
        flaggedAt: null,
      );



      setState(() {
        _order = order;
        _item = item;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Status'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go(RouteNames.home.path);
            }
          },
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: _order != null
          ? Container(
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
                      child: Row(
                        children: [
                          // 🔥 เพิ่มปุ่ม Cancel Order (โชว์เฉพาะตอน To Pay หรือ To Ship)
                          if (_order!.status == 'to_pay' ||
                              _order!.status == 'to_ship') ...[
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _showCancelDialog(
                                  context,
                                ), // เรียกฟังก์ชันกดยกเลิก
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  side: const BorderSide(
                                    color: AppTheme.danger,
                                  ), // ขอบสีแดง
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

                          // ปุ่ม Contact Seller (โชว์ตลอด)
                          Expanded(
                            flex: 2, // ให้ปุ่มแชทกว้างกว่านิดนึง
                            child: PrimaryButton(
                              label: 'Contact Seller',
                              onTap: () {
                                context.push(
                                  RouteNames.chat.path,
                                  extra: _item?.sellerName ?? 'Seller',
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  // 🚀 ฟังก์ชันกดยกเลิกออเดอร์
  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), // ปิด Dialog เฉยๆ
            child: const Text(
              'No, Keep It',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // ปิด Dialog

              // โชว์วงกลมโหลด
              setState(() => _isLoading = true);

              try {
                // อัปเดตสถานะใน Firebase เป็น 'cancelled'
                await FirebaseFirestore.instance
                    .collection('orders')
                    .doc(widget.orderId)
                    .update({'status': 'cancelled'});

                // แจ้งเตือนว่ายกเลิกสำเร็จ
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order cancelled successfully'),
                      backgroundColor: AppTheme.danger,
                    ),
                  );
                  // กลับไปหน้าก่อนหน้า ( Purchase History)
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to cancel order.')),
                  );
                }
              }
            },
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(
                color: AppTheme.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (_errorMessage.isNotEmpty) {
      return Center(child: Text('Error: $_errorMessage', style: const TextStyle(color: Colors.red)));
    }
    if (_order == null || _item == null) {
      return const Center(child: Text('Order details not found.'));
    }

    final status = _order!.status.toLowerCase();

    //1. แปลงชื่อสถานะเป็น "ตัวเลขลำดับ" จะได้คำนวณง่าย
    int stateIndex = 0;
    if (status == 'to_pay') stateIndex = 0;
    else if (status == 'to_ship') stateIndex = 1;
    // รองรับทั้ง 2 คำ เผื่อหลังบ้านบันทึกมาเป็นคำไหนก็รอด!
    else if (status == 'to_receive' || status == 'shipped') stateIndex = 2; 
    else if (status == 'completed') stateIndex = 3;
    else if (status == 'cancelled') stateIndex = -1; // -1 คือสถานะยกเลิก

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // การ์ดแสดงข้อมูลสินค้า (โค้ดส่วนนี้ของคุณถูกต้องอยู่แล้ว)
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
                    const Text('Order ID', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    Text(
                      '#${_order!.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent),
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
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
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
                // 🔥 2. ถ้ากดยกเลิก (stateIndex == -1) โชว์อันนี้อันเดียวเลย
                if (stateIndex == -1)
                  const _StatusStep(
                    icon: Icons.cancel_outlined,
                    title: 'Order Cancelled',
                    subtitle: 'This order has been cancelled.',
                    time: 'Cancelled',
                    isActive: false,
                    isPending: false,
                    isLast: true,
                    isError: true, // สั่งให้ขึ้นสีแดง
                  )
                else ...[
                  // 🔥 3. ถ้าไม่ยกเลิก ก็โชว์ Timeline ปกติ โดยเช็คจากตัวเลขเอา ง่ายกว่าเยอะ!
                  _StatusStep(
                    icon: Icons.inventory_2_outlined,
                    title: 'Order Placed',
                    subtitle: 'Waiting for seller to confirm.',
                    time: stateIndex > 0 ? 'Completed' : 'Pending',
                    isActive: stateIndex == 0,
                    isPending: stateIndex < 0,
                    isLast: false,
                  ),
                  _StatusStep(
                    icon: Icons.payments_outlined,
                    title: 'Payment Confirmed',
                    subtitle: 'Payment has been verified.',
                    time: stateIndex > 1 ? 'Completed' : 'Pending',
                    isActive: stateIndex == 1,
                    isPending: stateIndex < 1,
                    isLast: false,
                  ),
                  _StatusStep(
                    icon: Icons.local_shipping_outlined,
                    title: 'Shipped',
                    subtitle: 'Seller has shipped the package.',
                    time: stateIndex > 2 ? 'Completed' : 'Pending',
                    isActive: stateIndex == 2,
                    isPending: stateIndex < 2,
                    isLast: false,
                  ),
                  _StatusStep(
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

// ─── Widget _StatusStep (อัปเกรดให้รองรับสีแดง)
class _StatusStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final bool isActive;
  final bool isPending;
  final bool isLast;
  final bool isError; // 🔥 เพิ่มตัวแปรรองรับสถานะยกเลิก (สีแดง)

  const _StatusStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    this.isActive = false,
    this.isPending = false,
    required this.isLast,
    this.isError = false, 
  });

  @override
  Widget build(BuildContext context) {
    // กำหนดสีตามสถานะ: ถ้า Error เอาสีแดง, ถ้า Active เอาสีเน้น, นอกนั้นสีเขียว/เทา
    final Color iconColor = isError ? AppTheme.danger : (isActive ? AppTheme.accent : (isPending ? AppTheme.border : AppTheme.success));
    final Color bgColor = isError ? AppTheme.danger.withOpacity(0.1) : (isActive ? AppTheme.accentLight : (isPending ? Colors.transparent : AppTheme.success.withOpacity(0.1)));
    final Color lineColor = isPending ? AppTheme.border : AppTheme.success;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  border: isPending ? Border.all(color: AppTheme.border) : null,
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: lineColor,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: (isActive || isError) ? FontWeight.bold : FontWeight.w600,
                          fontSize: 15,
                          color: isError ? AppTheme.danger : (isPending ? AppTheme.textMuted : AppTheme.textPrimary),
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: isError ? AppTheme.danger : (isPending ? AppTheme.border : AppTheme.textMuted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isPending ? AppTheme.border : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}