import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload item image and return download URL
  Future<String> uploadItemImage({
    required String itemId,
    required XFile imageFile,
  }) async {
    final ref = _storage.ref().child('items/$itemId.jpg');
    
    // Upload based on platform
    if (kIsWeb) {
      final bytes = await imageFile.readAsBytes();
      await ref.putData(bytes);
    } else {
      await ref.putFile(File(imageFile.path));
    }
    
    return await ref.getDownloadURL();
  }

  /// Delete item image
  Future<void> deleteItemImage(String itemId) async {
    try {
      final ref = _storage.ref().child('items/$itemId.jpg');
      await ref.delete();
    } catch (e) {
      // Image might not exist, ignore error
    }
  }
}