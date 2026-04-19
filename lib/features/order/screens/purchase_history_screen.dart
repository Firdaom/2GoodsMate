import 'package:anigoods/core/constants/firebase_constants.dart';
import 'package:anigoods/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/router/app_router.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  final int initialIndex;

  const PurchaseHistoryScreen({super.key, this.initialIndex = 0});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  // ฟังก์ชันดึงออเดอร์
  Future<List<QueryDocumentSnapshot>> _fetchOrders() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection(FirebaseCollections.orders)
        .where(OrderFields.buyerId, isEqualTo: uid)
        .orderBy(OrderFields.createdAt, descending: true)
        .get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    // ย้าย FutureBuilder มาคลุมรอบนอกสุด
    return FutureBuilder<List<QueryDocumentSnapshot>>(
      future: _fetchOrders(),
      builder: (context, snapshot) {
        // ระหว่างรอข้อมูล ให้โชว์ Loading กลางจอ
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            ),
          );
        }
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Something went wrong.')),
          );
        }

        final orders = snapshot.data ?? [];

        return DefaultTabController(
          length: 5,
          initialIndex: widget.initialIndex,
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'My Purchases',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              centerTitle: true,
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
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
            body: orders.isEmpty
                ? const Center(
                    child: Text(
                      'No purchase history yet.',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  )
                : TabBarView(
                    children: [
                      _buildOrderList(orders, 'all'),
                      _buildOrderList(orders, OrderStatus.toPay.name),
                      _buildOrderList(orders, OrderStatus.toShip.name),
                      _buildOrderList(orders, OrderStatus.toReceive.name),
                      _buildOrderList(orders, OrderStatus.completed.name),
                    ],
                  ),
          ),
        );
      },
    );
  }

  // สร้าง List แสดงออเดอร์แยกตามแท็บ
  Widget _buildOrderList(
    List<QueryDocumentSnapshot> allOrders,
    String tabFilter,
  ) {
    final filteredOrders = allOrders.where((doc) {
      if (tabFilter == 'all') return true;
      final orderData = doc.data() as Map<String, dynamic>;
      final dbStatus = orderData[OrderFields.status]?.toString() ?? '';

      if (tabFilter == OrderStatus.toReceive.name) {
        return dbStatus == OrderStatus.toReceive.name || dbStatus == 'shipped';
      }
      return dbStatus == tabFilter;
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
        final orderDoc = filteredOrders[index];
        return _buildOrderCard(
          context,
          orderDoc.id,
          orderDoc.data() as Map<String, dynamic>,
        );
      },
    );
  }

  //  Widget การ์ดออเดอร์ย่อย
  Widget _buildOrderCard(
    BuildContext context,
    String orderId,
    Map<String, dynamic> orderData,
  ) {
    final status = orderData[OrderFields.status] ?? 'Unknown';
    final price = (orderData[OrderFields.totalPrice] ?? 0.0).toDouble();
    final itemId = orderData[OrderFields.itemId] ?? '';

    return GestureDetector(
      onTap: () async {
        await context.push(RouteNames.orderStatus.path, extra: orderId);
        if (mounted) setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: #${orderId.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  status.toString().toUpperCase().replaceAll('_', ' '),
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildItemDetails(itemId),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                Text(
                  '฿${price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDetails(String itemId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection(FirebaseCollections.items)
          .doc(itemId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );

        final itemData = snapshot.data!.data() as Map<String, dynamic>?;
        if (itemData == null) return const Text('Item details missing');

        String displayUrl = '';
        if (itemData[ItemFields.imageUrls] != null &&
            (itemData[ItemFields.imageUrls] as List).isNotEmpty) {
          displayUrl = itemData[ItemFields.imageUrls][0];
        } else {
          displayUrl = itemData['imageUrl'] ?? '';
        }

        return Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: displayUrl.isNotEmpty
                  ? Image.network(
                      displayUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      color: AppTheme.border,
                      child: const Icon(Icons.image_not_supported),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                itemData[ItemFields.title] ?? 'Unknown Item',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
