import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anigoods/models/order_model.dart';
import 'package:anigoods/core/constants/firebase_constants.dart';
import 'package:anigoods/core/exceptions/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderServiceProvider = Provider(
  (ref) => OrderService(firestore: FirebaseFirestore.instance),
);

class OrderService {
  final FirebaseFirestore _firestore;

  OrderService({required FirebaseFirestore firestore}) : _firestore = firestore;

  Future<String> createOrder(OrderModel order) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(FirebaseCollections.orders)
          .add(order.toFirestore());

      // 2. คืนค่า ID กลับไป
      return docRef.id;
    } on FirebaseException catch (e) {
      // 3. จัดการ Error แบบมือโปร
      throw AppException(
        message: e.message ?? 'Failed to place order. Please try again.',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw AppException(
        message: 'Something went wrong while creating order',
        code: 'unknown', 
      );
    }
  }
}
