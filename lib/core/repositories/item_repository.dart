import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/core/services/storage_service.dart';
import 'package:anigoods/core/constants/app_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:anigoods/core/services/moderation_service.dart';

class ItemRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();

  /// Create new item with optional image
  Future<String> createItem({
    required String title,
    required String series,
    required String category,
    required String rarity,
    required double price,
    required String condition,
    required String description,
    required List<String> tags,
    required List<ContactLink> contactLinks,
    List<XFile>? imageFiles,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get seller name and verified status
    final userDoc = await _firestore
        .collection(FirebaseCollections.users)
        .doc(user.uid)
        .get();
    final sellerName = userDoc.exists
        ? (userDoc[UserFields.name] ?? user.email ?? '')
        : (user.email ?? '');
    final sellerVerified = userDoc.exists
        ? (userDoc[UserFields.isVerified] ?? false)
        : false;

    // Create document reference first to get ID
    final docRef = _firestore.collection(FirebaseCollections.items).doc();

    // Upload images if provided
    List<String> imageUrls = [];
    if (imageFiles != null && imageFiles.isNotEmpty) {
      for (int i = 0; i < imageFiles.length; i++) {
        final imageUrl = await _storageService
            .uploadItemImage(
              itemId: '${docRef.id}_$i', // Add index to make unique
              imageFile: imageFiles[i],
            )
            .timeout(
              AppConstants.imageUploadTimeout,
              onTimeout: () => throw Exception('Image upload timeout'),
            );
        imageUrls.add(imageUrl);
      }
    }

    // Create item model
    final item = ItemModel(
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
      contactLinks: contactLinks,
      postedAt: DateTime.now(),
      moderationStatus: ModerationStatus.pending,
      qualityScore: 0,
      reportCount: null,
      flaggedAt: null,
    );

    // Save to Firestore
    await docRef
        .set(item.toFirestore())
        .timeout(
          AppConstants.firestoreSaveTimeout,
          onTimeout: () => throw Exception('Failed to save item'),
        );

    return docRef.id;
  }

  /// Update existing item
  Future<void> updateItem(String itemId, Map<String, dynamic> updates) async {
    await _firestore.collection(FirebaseCollections.items).doc(itemId).update(updates);
  }

  /// Delete item
  Future<void> deleteItem(String itemId) async {
    await _firestore.collection(FirebaseCollections.items).doc(itemId).delete();
    await _storageService.deleteItemImage(itemId);
  }

  /// Get item by ID
  Future<ItemModel?> getItem(String itemId) async {
    final doc = await _firestore.collection(FirebaseCollections.items).doc(itemId).get();
    if (!doc.exists) return null;
    return ItemModel.fromFirestore(doc);
  }
}
