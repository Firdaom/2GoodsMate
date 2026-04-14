import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anigoods/core/constants/firebase_constants.dart';

class UserModel {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String? profileImageUrl;
  final List<String> watchlist;
  final List<String> notificationKeywords;
  final bool isVerified;
  final DateTime createdAt;
  final List<String> cart; 

  UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    this.profileImageUrl,
    required this.watchlist,
    required this.notificationKeywords,
    required this.isVerified,
    required this.createdAt,
    required this.cart,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data[UserFields.name] ?? '',
      username: data[UserFields.username] ?? '',
      email: data[UserFields.email] ?? '',
      profileImageUrl: data[UserFields.profileImageUrl],
      watchlist: List<String>.from(data[UserFields.watchlist] ?? []),
      notificationKeywords: List<String>.from(
        data[UserFields.notificationKeywords] ?? [],
      ),
      isVerified: data[UserFields.isVerified] ?? false,
      createdAt: (data[UserFields.createdAt] as Timestamp?)?.toDate() ?? DateTime.now(),
      cart: List<String>.from(data[UserFields.cart] ?? []), 
    );
  }

  Map<String, dynamic> toFirestore() => {
    UserFields.name: name,
    UserFields.username: username,
    UserFields.email: email,
    UserFields.profileImageUrl: profileImageUrl,
    UserFields.watchlist: watchlist,
    UserFields.notificationKeywords: notificationKeywords,
    UserFields.isVerified: isVerified,
    UserFields.createdAt: Timestamp.fromDate(createdAt),
    UserFields.cart: cart,
  };

  UserModel copyWith({
    String? name,
    String? username,
    String? profileImageUrl,
    List<String>? watchlist,
    List<String>? notificationKeywords,
    bool? isVerified,
    List<String>? cart, 
  }) => UserModel(
    uid: uid, 
    name: name ?? this.name,
    username: username ?? this.username,
    email: email, 
    profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    watchlist: watchlist ?? this.watchlist,
    notificationKeywords: notificationKeywords ?? this.notificationKeywords,
    isVerified: isVerified ?? this.isVerified,
    createdAt: createdAt ?? this.createdAt,
    cart: cart ?? this.cart, 
  );
}