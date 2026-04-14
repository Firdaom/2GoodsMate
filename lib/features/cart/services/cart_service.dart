import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anigoods/core/constants/firebase_constants.dart';
import 'package:flutter/foundation.dart';

class CartRepository {
  final FirebaseFirestore _firestore;

  CartRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  // ดึง ID สินค้าในตะกร้าจาก Firebase
  Future<List<String>> getCartIds(String uid) async {
    final doc = await _firestore.collection(FirebaseCollections.users).doc(uid).get();
    return List<String>.from(doc.data()?[UserFields.cart] ?? []);
  }

  // อัปเดตตะกร้า (เพิ่ม/ลบ/ล้าง)
  Future<void> updateCart(String uid, List<String> itemIds) async {
    await _firestore.collection(FirebaseCollections.users).doc(uid).update({
      UserFields.cart: itemIds,
    });
  }
}