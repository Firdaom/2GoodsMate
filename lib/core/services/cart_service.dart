import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anigoods/models/item_model.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  List<ItemModel> _items = [];
  List<ItemModel> get items => _items;

  // 📥 1. ฟังก์ชันโหลดตะกร้าจาก Firebase (เรียกตอน Login)
  Future<void> loadCart() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      // ดึง Array ของไอดีสินค้าที่เคยอยู่ในตะกร้า
      final cartIds = List<String>.from(userDoc.data()?['cart'] ?? []);

      if (cartIds.isNotEmpty) {
        // ดึงข้อมูลสินค้าจริงๆ จากคอลเลกชัน items
        final itemsSnapshot = await FirebaseFirestore.instance
            .collection('items') 
            .where(FieldPath.documentId, whereIn: cartIds)
            .get();

        _items = itemsSnapshot.docs.map((d) => ItemModel.fromFirestore(d)).toList();
      } else {
        _items = [];
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  // ➕ 2. เพิ่มลงตะกร้า (เซฟลง Firebase ด้วย)
  Future<void> addToCart(ItemModel item) async {
    // กันไม่ให้แอดของชิ้นเดิมซ้ำ
    if (!_items.any((element) => element.id == item.id)) {
      _items.add(item);
      notifyListeners();

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'cart': FieldValue.arrayUnion([item.id])
        }, SetOptions(merge: true));
      }
    }
  }

  // ➖ 3. ลบออกจากตะกร้า
  Future<void> removeFromCart(ItemModel item) async {
    _items.removeWhere((element) => element.id == item.id);
    notifyListeners();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'cart': FieldValue.arrayRemove([item.id])
      }, SetOptions(merge: true));
    }
  }

  // 🗑️ 4. เคลียร์ตะกร้าตอนจ่ายเงินสำเร็จ
  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'cart': [] // ล้างข้อมูลใน Firebase ให้เป็น Array ว่าง
      }, SetOptions(merge: true));
    }
  }

  // 🧹 5. เคลียร์ตะกร้าออกจากหน้าจอเฉยๆ (เอาไว้เรียกตอน Logout)
  void clearLocalCart() {
    _items.clear();
    notifyListeners();
  }

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.price);
}