import 'package:anigoods/core/exceptions/app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/core/services/storage_service.dart';
import 'package:anigoods/core/constants/firebase_constants.dart'; 
import 'package:anigoods/core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:anigoods/core/services/moderation_service.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final itemRepositoryProvider = Provider((ref) {
  return ItemRepository();
});

class ItemRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();

  /// Create new item with multiple images
  Future<String> createItem({
    required String title,
    required String series,
    required String category,
    required String rarity,
    required double price,
    required String condition,
    required String description,
    required List<String> tags,
    List<XFile>? imageFiles, 
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw AppException(message: 'User not authenticated', code: 'auth-required');

    // 1. ดึงข้อมูลคนขาย 
    final userDoc = await _firestore
        .collection(FirebaseCollections.users)
        .doc(user.uid)
        .get();
        
    final sellerName = userDoc.exists
        ? (userDoc.data()?[UserFields.name] ?? user.email ?? 'Unknown Seller')
        : (user.email ?? 'Unknown Seller');
    final sellerVerified = userDoc.exists
        ? (userDoc.data()?[UserFields.isVerified] ?? false)
        : false;


    final docRef = _firestore.collection(FirebaseCollections.items).doc();

    // อัปโหลดรูปภาพ  
    List<String> imageUrls = [];
    if (imageFiles != null && imageFiles.isNotEmpty) {
      for (var file in imageFiles) {
        final imageUrl = await _storageService
            .uploadItemImage(
              itemId: docRef.id, 
              imageFile: file,
            )
            .timeout(AppConstants.imageUploadTimeout);
        imageUrls.add(imageUrl);
      }
    }

    //  สร้าง Model เริ่มต้น
    var item = ItemModel(
      id: docRef.id,
      title: title,
      series: series,
      category: category,
      rarity: rarity,
      price: price,
      condition: condition,
      imageUrls: imageUrls,
      sellerId: user.uid,
      sellerName: sellerName,
      sellerVerified: sellerVerified,
      description: description,
      tags: tags,
      postedAt: DateTime.now(),
      moderationStatus: ModerationStatus.pending, 
      qualityScore: 0, 
      reportCount: 0,
    );

    // 4. ตรวจสอบเนื้อหา 
    final modResult = await ModerationService.checkItem(item);
    final score = ModerationService.calculateQualityScore(item);

    if (modResult.status == ModerationStatus.rejected) {
      throw AppException(
        message: modResult.reason ?? 'Item rejected by moderation system.',
        code: 'moderation-rejected',
      );
    }

    //  อัปเดต Model ด้วยผลการตรวจ
    item = item.copyWith(
      moderationStatus: modResult.status,
      qualityScore: score,
    );

    // 6. Save to Firestore
    await docRef
        .set(item.toFirestore())
        .timeout(AppConstants.firestoreSaveTimeout);

    return docRef.id;
  }

  /// Update existing item
  Future<void> updateItem(String itemId, Map<String, dynamic> updates) async {
    await _firestore
        .collection(FirebaseCollections.items)
        .doc(itemId)
        .update(updates);
  }

  /// Delete item and its images
  Future<void> deleteItem(String itemId) async {
    await _firestore.collection(FirebaseCollections.items).doc(itemId).delete();
    await _storageService.deleteItemImages(itemId); 
  }

  /// Get item by ID
  Future<ItemModel?> getItem(String itemId) async {
    final doc = await _firestore.collection(FirebaseCollections.items).doc(itemId).get();
    if (!doc.exists) return null;
    return ItemModel.fromFirestore(doc);
  }
}


