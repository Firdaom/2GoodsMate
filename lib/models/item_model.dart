import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anigoods/core/services/moderation_service.dart';
import 'package:anigoods/core/constants/app_constants.dart';

class ContactLink {
  final String platform;
  final String url;

  ContactLink({required this.platform, required this.url});

  factory ContactLink.fromMap(Map<String, dynamic> map) =>
      ContactLink(platform: map['platform'] ?? '', url: map['url'] ?? '');

  Map<String, dynamic> toMap() => {'platform': platform, 'url': url};
}

class ItemModel {
  final String id;
  final String title;
  final String series;
  final String category;
  final String rarity;
  final double price;
  final String condition;
  final List<String> imageUrls;
  final String sellerId;
  final String sellerName;
  final bool sellerVerified;
  final String description;
  final List<String> tags;
  final List<ContactLink> contactLinks;
  final DateTime postedAt;
  final ModerationStatus moderationStatus;
  final int qualityScore;
  final int? reportCount;
  final DateTime? flaggedAt;

  ItemModel({
    required this.id,
    required this.title,
    required this.series,
    required this.category,
    required this.rarity,
    required this.price,
    required this.condition,
    required this.imageUrls,
    required this.sellerId,
    required this.sellerName,
    required this.sellerVerified,
    required this.description,
    required this.tags,
    required this.contactLinks,
    required this.postedAt,
    required this.moderationStatus,
    required this.qualityScore,
    required this.reportCount,
    required this.flaggedAt,
  });

  factory ItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemModel(
      id: doc.id,
      title: data[ItemFields.title] ?? '',
      series: data[ItemFields.series] ?? '',
      category: data[ItemFields.category] ?? '',
      rarity: data[ItemFields.rarity] ?? 'Common',
      price: (data[ItemFields.price] ?? 0).toDouble(),
      condition: data[ItemFields.condition] ?? 'Good',
      imageUrls: _parseImageUrls(data[ItemFields.imageUrls], data[ItemFields.imageUrl]),
      sellerId: data[ItemFields.sellerId] ?? '',
      sellerName: data[ItemFields.sellerName] ?? '',
      sellerVerified: data[ItemFields.sellerVerified] ?? false,
      description: data[ItemFields.description] ?? '',
      tags: List<String>.from(data[ItemFields.tags] ?? []),
      contactLinks: (data[ItemFields.contactLinks] as List<dynamic>? ?? [])
          .map((linkMap) => ContactLink.fromMap(linkMap))
          .toList(),
      postedAt:
          (data[ItemFields.postedAt] as Timestamp?)?.toDate() ?? DateTime.now(),
      moderationStatus: ModerationStatus.values.firstWhere(
        (e) => e.name == (data[ItemFields.moderationStatus] ?? 'pending'),
        orElse: () => ModerationStatus.pending,
      ),
      qualityScore: data[ItemFields.qualityScore] ?? 0,
      reportCount: data[ItemFields.reportCount],
      flaggedAt: (data[ItemFields.flaggedAt] as Timestamp?)?.toDate(),
    );
  }

  /// Helper method to parse imageUrls with backward compatibility
  static List<String> _parseImageUrls(dynamic imageUrlsData, dynamic imageUrlData) {
    // ถ้ามี imageUrls (array) ใช้ตัวนี้
    if (imageUrlsData != null && imageUrlsData is List) {
      return List<String>.from(imageUrlsData);
    }
    // ถ้าไม่มี แต่มี imageUrl (string เดี่ยว) ให้แปลงเป็น array
    if (imageUrlData != null && imageUrlData is String && imageUrlData.isNotEmpty) {
      return [imageUrlData];
    }
    // ถ้าไม่มีทั้งสอง return empty list
    return [];
  }

  Map<String, dynamic> toFirestore() => {
    ItemFields.title: title,
    ItemFields.series: series,
    ItemFields.category: category,
    ItemFields.rarity: rarity,
    ItemFields.price: price,
    ItemFields.condition: condition,
    ItemFields.imageUrls: imageUrls,
    ItemFields.imageUrl: imageUrls.isNotEmpty ? imageUrls[0] : '', // Keep for backward compatibility
    ItemFields.sellerId: sellerId,
    ItemFields.sellerName: sellerName,
    ItemFields.sellerVerified: sellerVerified,
    ItemFields.description: description,
    ItemFields.tags: tags,
    ItemFields.contactLinks: contactLinks.map((link) => link.toMap()).toList(),
    ItemFields.postedAt: Timestamp.fromDate(postedAt),
    ItemFields.moderationStatus: moderationStatus.name,
    ItemFields.qualityScore: qualityScore,
    ItemFields.reportCount: reportCount,
    ItemFields.flaggedAt: flaggedAt != null
        ? Timestamp.fromDate(flaggedAt!)
        : null,
  };

  bool matchesQuery(String query) {
    final lowercaseQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowercaseQuery) ||
        series.toLowerCase().contains(lowercaseQuery) ||
        tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
  }
}
