import 'package:anigoods/core/constants/firebase_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/features/cart/repositories/cart_repository.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async'; 


final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// (watch) authStateProvider
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
  
  
  bool _isLoading = true;
  StreamSubscription? _itemsSubscription;

  CartNotifier(this._repository, this._uid) : super([]) {
    if (_uid != null) {
      loadCart();
    } else {
      _isLoading = false; 
    }
  }

  @override
  void dispose() {
    _itemsSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadCart() async {
    if (_uid == null) return;
    
    _isLoading = true; 
    
    try {
      final itemIds = await _repository.getCartItemIds(_uid!);
      
      if (itemIds.isEmpty) {
        state = [];
        _isLoading = false;
      } else {
        final limitedIds = itemIds.take(30).toList();
        
        _itemsSubscription?.cancel(); 
        _itemsSubscription = _firestore
            .collection(FirebaseCollections.items)
            .where(FieldPath.documentId, whereIn: limitedIds)
            .snapshots()
            .listen((snapshot) {
          
          // แปลงข้อมูลที่ได้มาเป็น ItemModel
          final latestItems = snapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList();
          
          // (isAvailable == true)
          final availableItems = latestItems.where((item) => item.isAvailable).toList();
          
          
          state = availableItems;
          
         
          if (latestItems.length != availableItems.length) {
            _syncToFirebase();
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      state = [];
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