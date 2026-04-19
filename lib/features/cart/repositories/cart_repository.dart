import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anigoods/core/constants/firebase_constants.dart';

class CartRepository {

  
  final FirebaseFirestore _firestore;

  CartRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  // ดึง ID สินค้าที่อยู่ในตะกร้าจาก User Collection
  Future<List<String>> getCartItemIds(String uid) async {
    final doc = await _firestore.collection(FirebaseCollections.users).doc(uid).get();
    if (doc.exists) {
      return List<String>.from(doc.data()?[UserFields.cart] ?? []);
    }
    return [];
  }

  // อัปเดตรายการสินค้าในตะกร้าทั้งหมด
  Future<void> updateCart(String uid, List<String> itemIds) async {
    await _firestore.collection(FirebaseCollections.users).doc(uid).update({
      UserFields.cart: itemIds,
    });
  }
}