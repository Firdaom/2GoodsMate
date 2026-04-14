import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anigoods/core/constants/firebase_constants.dart';
import 'package:anigoods/core/exceptions/app_exception.dart';
import 'package:anigoods/models/user_model.dart'; 

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _createUserProfile(credential.user!);
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw AppException(
        message: _getAuthMessage(e.code),
        code: e.code,
        originalError: e,
      );
    }
  }

  // ─── Sign In with Email & Password ─────────────────
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _firestore
          .collection(FirebaseCollections.users)
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _createUserProfile(credential.user!);
      }

      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw AppException(
        message: _getAuthMessage(e.code),
        code: e.code,
        originalError: e,
      );
    }
  }

  // ─── Create User Profile in Firestore ─────────────────
  Future<void> _createUserProfile(User user) async {
    final email = user.email ?? '';
    final username = email.split('@')[0];

    // สร้าง Object จาก UserModel ไปเลย! 
    final newUser = UserModel(
      uid: user.uid,
      name: username,
      username: username,
      email: email,
      profileImageUrl: null, 
      cart: [],
      watchlist: [],
      notificationKeywords: [],
      isVerified: false, 
      createdAt: DateTime.now(), 
    );

    // สั่งเซฟด้วย 
    await _firestore
        .collection(FirebaseCollections.users)
        .doc(user.uid)
        .set(newUser.toFirestore());
  }

  // ─── Sign Out ───────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ─── Get Current User ───────────────────────────────
  User? get currentUser => _auth.currentUser;

  // ─── Auth State Stream ──────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Convert Firebase Auth errors to user-friendly messages ───
  String _getAuthMessage(String code) {
    switch (code) {
      case AuthErrorCodes.userNotFound:
      case AuthErrorCodes.wrongPassword:
      case AuthErrorCodes.invalidCredential:
      case AuthErrorCodes.invalidEmail:
        return 'Invalid email or password';
      case AuthErrorCodes.emailAlreadyInUse:
        return 'Email is already in use';
      case AuthErrorCodes.weakPassword:
        return 'Password is too weak';
      case AuthErrorCodes.tooManyRequests:
        return 'Too many login attempts. Please try again later';
      case AuthErrorCodes.userDisabled: 
        return 'This account has been disabled';
      case AuthErrorCodes.operationNotAllowed:
        return 'Email/password registration is disabled';
      case AuthErrorCodes.networkRequestFailed:
        return 'Network error. Please check your connection';
      default:
        return 'Authentication failed ($code)'; // แนะนำให้ต่อ $code ท้ายข้อความ จะได้รู้เวลา Debug
    }
  }
}