import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:anigoods/models/user_model.dart';
import 'package:anigoods/core/constants/firebase_constants.dart'; 
import 'package:anigoods/core/exceptions/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRepositoryProvider = Provider((ref) => UserRepository(
  firestore: FirebaseFirestore.instance,
  storage: FirebaseStorage.instance,
));

class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  UserRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  /// Get user profile by UID
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } on FirebaseException catch (e) {
      throw AppException(
        message: _getFirestoreUserMessage(e.code),
        code: e.code, 
        originalError: e,
      );
    }
  }

  /// Upload profile image to Firebase Storage
  Future<String> uploadProfileImage({
    required String uid,
    required XFile image,
  }) async {
    try {
      final ref = _storage
          .ref()
          .child(StoragePaths.profileImages)
          .child('$uid.jpg');

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        await ref.putData(bytes);
      } else {
        await ref.putFile(File(image.path));
      }

      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw AppException(
        message: _getStorageUserMessage(e.code),
        code: e.code,
        originalError: e,
      );
    }
  }

  /// Update user profile data
  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String username,
    String? profileImageUrl,
  }) async {
    try {
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .set(
        {
          UserFields.name: name,
          UserFields.username: username,
          if (profileImageUrl != null) UserFields.profileImageUrl: profileImageUrl,
        },
        SetOptions(merge: true),
      );
    } on FirebaseException catch (e) {
      throw AppException(
        message: _getFirestoreUserMessage(e.code),
        code: e.code,
        originalError: e,
      );
    }
  }

  // --- Error Message Helpers ---

  String _getFirestoreUserMessage(String code) {
    switch (code) {
      case 'permission-denied': return 'Permission denied. Please sign in again';
      case 'not-found': return 'User profile not found';
      case 'unauthenticated': return 'Please sign in to continue';
      default: return 'Failed to update profile. Please try again';
    }
  }

  String _getStorageUserMessage(String code) {
    switch (code) {
      case 'permission-denied': return 'Access denied. Check your permissions';
      case 'quota-exceeded': return 'Storage full. Please contact support';
      default: return 'Failed to upload image. Please try again';
    }
  }
}