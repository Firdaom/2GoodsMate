import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anigoods/core/constants/app_constants.dart';
import 'package:anigoods/core/exceptions/app_exception.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Register with Email & Password ─────────────────
  Future<User> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile
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

      // Check if user profile exists, if not create it
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

    await _firestore.collection(FirebaseCollections.users).doc(user.uid).set({
      UserFields.email: email,
      UserFields.name: username,
      UserFields.username: username,
      UserFields.avatar: '🎨',
      UserFields.watchlist: [],
      UserFields.notificationKeywords: [],
      UserFields.createdAt: FieldValue.serverTimestamp(),
    });
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
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-email':
        return 'Invalid email or password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later';
      case 'weak-password':
        return 'Password is too weak';
      case 'email-already-in-use':
        return 'Email is already in use';
      case 'operation-not-allowed':
        return 'Email/password registration is disabled';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'Authentication failed';
    }
  }
}
