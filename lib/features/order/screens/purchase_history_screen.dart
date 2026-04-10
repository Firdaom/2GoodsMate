import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/router/app_router.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  final int initialIndex; // รับค่าว่าจะให้เปิดแท็บไหนเป็นค่าเริ่มต้น

  const PurchaseHistoryScreen({super.key, this.initialIndex = 0});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  // ฟังก์ชันดึงออเดอร์จาก Firebase
  Future<List<QueryDocumentSnapshot>> _fetchOrders() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('buyerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    // ใช้ DefaultTabController เพื่อสร้างระบบ 5 แท็บ
    return DefaultTabController(
      length: 5,
      initialIndex: widget.initialIndex, // เปิดมาให้เด้งไปแท็บที่กดมาจากหน้า Profile
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Purchases'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
         bottom: const TabBar(
            isScrollable: true, // เลื่อนซ้ายขวาได้
            tabAlignment: TabAlignment.start, // 🔥 บังคับให้เริ่มเรียงจากขอบซ้าย (ไม่ให้มันไปกระจุกตรงกลาง)
            labelPadding: EdgeInsets.symmetric(horizontal: 16.0), // 🔥 เพิ่มระยะห่างซ้ายขวาให้ตัวหนังสือไม่เบียดกัน
            labelColor: AppTheme.accent,
            unselectedLabelColor: AppTheme.textMuted,
            indicatorColor: AppTheme.accent,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'To Pay'),
              Tab(text: 'To Ship'),
              Tab(text: 'To Receive'),
              Tab(text: 'To Rate'),
            ],
          ),
        ),
        body: FutureBuilder<List<QueryDocumentSnapshot>>(
          future: _fetchOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong.'));
            }

            final orders = snapshot.data ?? [];

            // ถ้าไม่มีออเดอร์เลยสักชิ้นเดียว
            if (orders.isEmpty) {
              return const Center(
                child: Text(
                  'No purchase history yet.',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                ),
              );
            }

            // ถ้ามีออเดอร์ ให้ส่งไปกรองแยกตามแท็บ
            return TabBarView(
              children: [
                _buildOrderList(orders, 'all'),
                _buildOrderList(orders, 'to_pay'),
                _buildOrderList(orders, 'to_ship'),
                _buildOrderList(orders, 'to_receive'),
                _buildOrderList(orders, 'completed'), // To Rate
              ],
            );
          },
        ),
      ),
    );
  }

  // สร้าง List แสดงออเดอร์แต่ละแท็บ
  Widget _buildOrderList(List<QueryDocumentSnapshot> allOrders, String statusFilter) {
    // กรองเอาเฉพาะออเดอร์ที่ตรงกับสถานะของแท็บนั้นๆ (ถ้าเป็น all ก็เอาหมด)
    final filteredOrders = allOrders.where((doc) {
      if (statusFilter == 'all') return true;
      return doc.data().toString().contains('status: $statusFilter') || 
             (doc.data() as Map<String, dynamic>)['status'] == statusFilter;
    }).toList();

    if (filteredOrders.isEmpty) {
      return const Center(
        child: Text(
          'No orders in this status.',
          style: TextStyle(color: AppTheme.textMuted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final orderData = filteredOrders[index].data() as Map<String, dynamic>;
        final orderId = filteredOrders[index].id;
        final status = orderData['status'] ?? 'Unknown';
        final price = orderData['totalPrice'] ?? 0.0;
        final itemId = orderData['itemId'] ?? ''; // 🔥 ดึงรหัสสินค้ามา

        return GestureDetector(
          onTap: () {
            // กดที่การ์ดออเดอร์ ให้วิ่งไปหน้า Order Status
            context.push(RouteNames.orderStatus.path, extra: orderId);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 ส่วนหัว: Order ID และ สถานะ
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order ID: #${orderId.substring(0, 8).toUpperCase()}', 
                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(status.toUpperCase().replaceAll('_', ' '), 
                         style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 25),

                // 🔹 ส่วนกลาง: โชว์รูปและชื่อสินค้า (ดึงข้อมูลจากตาราง items)
               if (itemId.isNotEmpty)
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('items').doc(itemId).get(),
                    builder: (context, itemSnapshot) {
                      if (itemSnapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent)),
                        );
                      }
                      
                      if (!itemSnapshot.hasData || !itemSnapshot.data!.exists) {
                        return const Text('Item details not found.', style: TextStyle(color: AppTheme.textMuted));
                      }

                      final itemData = itemSnapshot.data!.data() as Map<String, dynamic>;
                      final title = itemData['title'] ?? 'Unknown Item';
                      
                      // 🔥 โค้ดส่วนที่แก้ใหม่: นักสืบหารูปภาพ!
                      String displayImageUrl = '';
                      
                      // 1. ลองหาแบบ List (หลายรูป) ก่อน ถ้ามี ให้ดึงรูปตำแหน่งที่ 0 มา
                      if (itemData['imageUrls'] != null && itemData['imageUrls'] is List && (itemData['imageUrls'] as List).isNotEmpty) {
                        displayImageUrl = itemData['imageUrls'][0].toString();
                      } 
                      // 2. ถ้าไม่มีแบบ List ลองหาแบบ String (รูปเดียว) ดั้งเดิม
                      else if (itemData['imageUrl'] != null && itemData['imageUrl'] is String) {
                        displayImageUrl = itemData['imageUrl'];
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🖼️ รูปสินค้า
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            // 🔥 เปลี่ยนมาใช้ตัวแปร displayImageUrl ที่เราหามาได้
                            child: displayImageUrl.isNotEmpty
                                ? Image.network(
                                    displayImageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 60,
                                    height: 60,
                                    color: AppTheme.border,
                                    child: const Icon(Icons.image_not_supported, color: AppTheme.textMuted),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          // 📝 ชื่อสินค้า
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                
                const Divider(height: 24),

                // 🔹 ส่วนล่าง: ราคารวม
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    Text('฿${price.toStringAsFixed(0)}', 
                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}