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
    
      final batch = _firestore.batch();

    
      final orderRef = _firestore.collection(FirebaseCollections.orders).doc();
      batch.set(orderRef, order.toFirestore());

     
      final itemRef = _firestore.collection(FirebaseCollections.items).doc(order.itemId);
      batch.update(itemRef, {'isAvailable': false});

      await batch.commit();

     
      return orderRef.id;

    } on FirebaseException catch (e) {
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
