import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anigoods/core/constants/firebase_constants.dart';

enum OrderStatus {
  toPay,
  toShip,
  toReceive,
  completed,
  cancelled; 
}

class OrderModel {
  final String id;
  final String itemId;
  final String buyerId;
  final String sellerId;
  final OrderStatus status;
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


  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>; 
    
    return OrderModel(
      id: doc.id,
      itemId: data[OrderFields.itemId] ?? '',
      buyerId: data[OrderFields.buyerId] ?? '',
      sellerId: data[OrderFields.sellerId] ?? '',
      status: OrderStatus.values.firstWhere(
        (e) => e.name == data[OrderFields.status],
        orElse: () => OrderStatus.toPay, // ค่า Default ถ้าหาไม่เจอ
      ),
      totalPrice: (data[OrderFields.totalPrice] ?? 0.0).toDouble(),
      shippingAddress: data[OrderFields.shippingAddress] ?? {},
      createdAt: (data[OrderFields.createdAt] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      OrderFields.itemId: itemId,
      OrderFields.buyerId: buyerId,
      OrderFields.sellerId: sellerId,
      OrderFields.status: status.name, 
      OrderFields.totalPrice: totalPrice,
      OrderFields.shippingAddress: shippingAddress,
      OrderFields.createdAt: Timestamp.fromDate(createdAt), 
    };
  }

  OrderModel copyWith({
    String? id,
    String? itemId,
    String? buyerId,
    String? sellerId,
    OrderStatus? status,
    double? totalPrice,
    Map<String, dynamic>? shippingAddress,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}