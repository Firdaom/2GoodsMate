import 'package:anigoods/core/constants/firebase_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/features/cart/repositories/cart_repository.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

// 1. สร้าง Provider เพื่อดึงสถานะการ Login แบบ Real-time
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// 2. ปรับปรุง cartProvider ให้ "เฝ้าดู" (watch) authStateProvider
final cartProvider = StateNotifierProvider.autoDispose<CartNotifier, List<ItemModel>>((ref) {
  final repo = CartRepository(firestore: FirebaseFirestore.instance);
  

  final authState = ref.watch(authStateProvider);
  final user = authState.value; 
  
  return CartNotifier(repo, user?.uid);
});

class CartNotifier extends StateNotifier<List<ItemModel>> {
  final CartRepository _repository;
  final String? _uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // 🔥 เพิ่มตัวแปรเช็กสถานะ
  bool _isLoading = true;

  CartNotifier(this._repository, this._uid) : super([]) {
    if (_uid != null) {
      loadCart();
    } else {
      _isLoading = false; 
    }
  }

  Future<void> loadCart() async {
    if (_uid == null) return;
    
    _isLoading = true; 
    
    try {
      final itemIds = await _repository.getCartItemIds(_uid!);
      
      if (itemIds.isEmpty) {
        state = [];
      } else {
        final limitedIds = itemIds.take(30).toList();
        final itemsSnapshot = await _firestore
            .collection(FirebaseCollections.items)
            .where(FieldPath.documentId, whereIn: limitedIds)
            .get();

        state = itemsSnapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList();
      }
    } catch (e) {
      state = [];
    } finally {
      _isLoading = false; 
    }
  }

  void addItem(ItemModel item) {
    if (!state.any((i) => i.id == item.id)) {
      state = [...state, item];
      _syncToFirebase();
    }
  }

  void removeFromCart(String itemId) {
    state = state.where((i) => i.id != itemId).toList();
    _syncToFirebase();
  }

  void clearCart() {
    state = [];
    _syncToFirebase();
  }

  Future<void> _syncToFirebase() async {
    if (_uid == null || _isLoading) return; 

    try {
      await _repository.updateCart(_uid!, state.map((i) => i.id).toList());
    } catch (e) {
      print(" Sync Error: $e");
    }
  }
}