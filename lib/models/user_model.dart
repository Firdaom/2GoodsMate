import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String avatar;
  final String? profileImageUrl;
  final List<String> watchlist;
  final List<String> notificationKeywords;

  UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    required this.avatar,
    this.profileImageUrl,
    required this.watchlist,
    required this.notificationKeywords,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: d['name'] ?? '',
      username: d['username'] ?? '',
      email: d['email'] ?? '',
      avatar: d['avatar'] ?? '🎨',
      profileImageUrl: d['profileImageUrl'],
      watchlist: List<String>.from(d['watchlist'] ?? []),
      notificationKeywords: List<String>.from(d['notificationKeywords'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'username': username,
        'email': email,
        'avatar': avatar,
        'profileImageUrl': profileImageUrl,
        'watchlist': watchlist,
        'notificationKeywords': notificationKeywords,
      };

  UserModel copyWith({
    String? name,
    String? username,
    String? avatar,
    String? profileImageUrl,
    List<String>? watchlist,
    List<String>? notificationKeywords,
  }) =>
      UserModel(
        uid: uid,
        name: name ?? this.name,
        username: username ?? this.username,
        email: email,
        avatar: avatar ?? this.avatar,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
        watchlist: watchlist ?? this.watchlist,
        notificationKeywords: notificationKeywords ?? this.notificationKeywords,
      );
}
