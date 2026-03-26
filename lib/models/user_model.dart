import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anigoods/core/constants/app_constants.dart';

class UserModel {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String avatar;
  final String? profileImageUrl;
  final List<String> watchlist;
  final List<String> notificationKeywords;
  final bool isVerified;

  UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    required this.avatar,
    this.profileImageUrl,
    required this.watchlist,
    required this.notificationKeywords,
    required this.isVerified,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data[UserFields.name] ?? '',
      username: data[UserFields.username] ?? '',
      email: data[UserFields.email] ?? '',
      avatar: data[UserFields.avatar] ?? '🎨',
      profileImageUrl: data[UserFields.profileImageUrl],
      watchlist: List<String>.from(data[UserFields.watchlist] ?? []),
      notificationKeywords: List<String>.from(
        data[UserFields.notificationKeywords] ?? [],
      ),
      isVerified: data[UserFields.isVerified] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
    UserFields.name: name,
    UserFields.username: username,
    UserFields.email: email,
    UserFields.avatar: avatar,
    UserFields.profileImageUrl: profileImageUrl,
    UserFields.watchlist: watchlist,
    UserFields.notificationKeywords: notificationKeywords,
    UserFields.isVerified: isVerified,
  };

  UserModel copyWith({
    String? name,
    String? username,
    String? avatar,
    String? profileImageUrl,
    List<String>? watchlist,
    List<String>? notificationKeywords,
    bool? isVerified,
  }) => UserModel(
    uid: uid,
    name: name ?? this.name,
    username: username ?? this.username,
    email: email,
    avatar: avatar ?? this.avatar,
    profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    watchlist: watchlist ?? this.watchlist,
    notificationKeywords: notificationKeywords ?? this.notificationKeywords,
    isVerified: isVerified ?? this.isVerified,
  );
}
