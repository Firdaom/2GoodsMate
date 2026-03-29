import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../exceptions/app_exception.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload item image and return download URL
  Future<String> uploadItemImage({
    required String itemId,
    required XFile imageFile,
  }) async {
    try {
      final ref = _storage.ref().child('items/$itemId.jpg');

      debugPrint('📤 Uploading image to: items/$itemId.jpg');

      // Upload based on platform
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        debugPrint('   File size: ${bytes.length} bytes');
        await ref.putData(bytes);
      } else {
        final file = File(imageFile.path);
        final fileSize = await file.length();
        debugPrint('   File size: $fileSize bytes');
        await ref.putFile(file);
      }

      final downloadUrl = await ref.getDownloadURL();
      debugPrint('✅ Upload successful, URL: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint('❌ Upload failed: $e');
      throw AppException(
        message: _getUserMessage(e.code),
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

  /// Delete item image
  Future<void> deleteItemImage(String itemId) async {
    try {
      final ref = _storage.ref().child('items/$itemId.jpg');
      await ref.delete();
      debugPrint('🗑️ Deleted image: items/$itemId.jpg');
    } on FirebaseException catch (e) {
      // If object-not-found, it's okay (already deleted)
      if (e.code == 'object-not-found') {
        debugPrint('ℹ️ Image not found (already deleted): items/$itemId.jpg');
        return;
      }
      // For other errors, log but don't throw (deletion is not critical)
      debugPrint('⚠️ Failed to delete image: $e');
    } catch (e) {
      debugPrint('⚠️ Failed to delete image: $e');
    }
  }

  /// Get user-friendly error message from Firebase error code
  String _getUserMessage(String errorCode) {
    switch (errorCode) {
      case 'storage/unauthorized':
        return 'You do not have permission to upload images';
      case 'storage/canceled':
        return 'Upload was cancelled';
      case 'storage/unknown':
        return 'An unknown error occurred while uploading';
      case 'storage/object-not-found':
        return 'File not found';
      case 'storage/quota-exceeded':
        return 'Storage quota exceeded';
      case 'storage/unauthenticated':
        return 'Please sign in to upload images';
      case 'storage/retry-limit-exceeded':
        return 'Upload timeout. Please try again';
      default:
        return 'Failed to upload image';
    }
  }
}