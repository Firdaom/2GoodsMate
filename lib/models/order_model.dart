import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String itemId;
  final String buyerId;
  final String sellerId;
  final String status; // 'to_pay', 'to_ship', 'to_receive', 'completed'
  final double totalPrice;
  final Map<String, dynamic> shippingAddress;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.itemId,
    required this.buyerId,
    required this.sellerId,
    required this.status,
    required this.totalPrice,
    required this.shippingAddress,
    required this.createdAt,
  });

  // ฟังก์ชันสำหรับแปลงข้อมูลจาก Firestore มาเป็น Model
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return OrderModel(
      id: doc.id,
      itemId: data['itemId'] ?? '',
      buyerId: data['buyerId'] ?? '',
      sellerId: data['sellerId'] ?? '',
      status: data['status'] ?? 'to_pay',
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      shippingAddress: data['shippingAddress'] ?? {},
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // ฟังก์ชันสำหรับเตรียมข้อมูลส่งกลับไปเซฟที่ Firestore
  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'status': status,
      'totalPrice': totalPrice,
      'shippingAddress': shippingAddress,
      'createdAt': FieldValue.serverTimestamp(), // ใช้เวลาของ Server
    };
  }
}