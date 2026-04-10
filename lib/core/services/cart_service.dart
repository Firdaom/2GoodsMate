import 'package:flutter/material.dart';
import 'package:anigoods/models/item_model.dart'; 

// ใส่ ChangeNotifier เพื่อให้มันสามารถตะโกนบอกหน้าจออื่นๆ ได้
class CartService extends ChangeNotifier { 
  // Singleton pattern
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<ItemModel> _items = [];
  List<ItemModel> get items => _items;

  void addToCart(ItemModel item) {
    _items.add(item);
    notifyListeners(); // ตะโกนบอกตอนของเพิ่ม
  }

  void removeFromCart(ItemModel item) {
    _items.remove(item);
    notifyListeners(); // ตะโกนบอกตอนของลด
  }

  void clearCart() {
    _items.clear();
    notifyListeners(); // ตะโกนบอกตอนล้างตะกร้า
  }

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.price);
}