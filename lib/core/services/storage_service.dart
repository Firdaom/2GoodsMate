import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:anigoods/core/exceptions/app_exception.dart';
import 'package:anigoods/core/constants/firebase_constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload item image and return download URL
  Future<String> uploadItemImage({
    required String itemId,
    required XFile imageFile,
  }) async {
    try {
      //  สร้างชื่อไฟล์ที่ไม่ซ้ำกันด้วย Timestamp 
      final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      //  ใช้ Constants และจัดเก็บแบบโฟลเดอร์: items/itemId/161234567.jpg
      final path = '${StoragePaths.itemImages}/$itemId/$uniqueFileName';
      final ref = _storage.ref().child(path);

      debugPrint('📤 Uploading image to: $path');

      // Upload based on platform
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        await ref.putData(bytes);
      } else {
        final file = File(imageFile.path);
        await ref.putFile(file);
      }

      final downloadUrl = await ref.getDownloadURL();
      debugPrint('✅ Upload successful, URL: $downloadUrl');
      return downloadUrl;

    } on FirebaseException catch (e) {
      debugPrint('❌ Upload failed: $e');
      throw AppException(
        message: e.message ?? 'Storage error occurred', 
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      debugPrint('❌ Upload failed: $e');
      throw AppException(
        message: 'Failed to upload image',
        code: 'unknown_error',
        originalError: e,
      );
    }
  }

  /// Delete ALL item images (เมื่อผู้ใช้ลบโพสต์สินค้า)
  Future<void> deleteItemImages(String itemId) async {
    try {
      // ✅ 5. อ้างอิงไปที่ "โฟลเดอร์" ของสินค้านั้นๆ
      final folderRef = _storage.ref().child('${StoragePaths.itemImages}/$itemId');
      
      // ดึงรายชื่อไฟล์ทั้งหมดในโฟลเดอร์นี้
      final listResult = await folderRef.listAll();
      
      // วนลูปสั่งลบทีละไฟล์ (เพราะ Firebase Storage สั่งลบโฟลเดอร์ตรงๆ ไม่ได้)
      for (var item in listResult.items) {
        await item.delete();
      }
      
      debugPrint('🗑️ Deleted all images for item: $itemId');
    } on FirebaseException catch (e) {
      if (e.code == StorageErrorCodes.objectNotFound) {
        debugPrint('ℹ️ Image folder not found (already deleted)');
        return;
      }
      debugPrint('⚠️ Failed to delete images: $e');
    } catch (e) {
      debugPrint('⚠️ Failed to delete images: $e');
    }
  }
}