import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anigoods/core/services/moderation_service.dart';
import 'package:anigoods/core/constants/firebase_constants.dart';


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
  final DateTime postedAt;
  final bool isAvailable;
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
    required this.postedAt,
    this.isAvailable = true,
    required this.moderationStatus,
    required this.qualityScore,
    required this.reportCount,
    this.flaggedAt,
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
      imageUrls: List<String>.from(data[ItemFields.imageUrls] ?? []),
      sellerId: data[ItemFields.sellerId] ?? '',
      sellerName: data[ItemFields.sellerName] ?? '',
      sellerVerified: data[ItemFields.sellerVerified] ?? false,
      description: data[ItemFields.description] ?? '',
      tags: List<String>.from(data[ItemFields.tags] ?? []),
      postedAt:
          (data[ItemFields.postedAt] as Timestamp?)?.toDate() ?? DateTime.now(),
      isAvailable: data['isAvailable'] ?? true,
      moderationStatus: ModerationStatus.values.firstWhere(
        (e) => e.name == (data[ItemFields.moderationStatus] ?? 'pending'),
        orElse: () => ModerationStatus.pending,
      ),
      qualityScore: data[ItemFields.qualityScore] ?? 0,
      reportCount: data[ItemFields.reportCount],
      flaggedAt: (data[ItemFields.flaggedAt] as Timestamp?)?.toDate(),
    );
  }

  
  Map<String, dynamic> toFirestore() => {
    ItemFields.title: title,
    ItemFields.series: series,
    ItemFields.category: category,
    ItemFields.rarity: rarity,
    ItemFields.price: price,
    ItemFields.condition: condition,
    ItemFields.imageUrls: imageUrls,
    ItemFields.sellerId: sellerId,
    ItemFields.sellerName: sellerName,
    ItemFields.sellerVerified: sellerVerified,
    ItemFields.description: description,
    ItemFields.tags: tags,
    ItemFields.postedAt: Timestamp.fromDate(postedAt),
    'isAvailable': isAvailable,
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

  ItemModel copyWith({
    String? id,
    String? title,
    String? series,
    String? category,
    String? rarity,
    double? price,
    String? condition,
    List<String>? imageUrls,
    String? sellerId,
    String? sellerName,
    bool? sellerVerified,
    String? description,
    List<String>? tags,
    DateTime? postedAt,
    bool? isAvailable,
    ModerationStatus? moderationStatus,
    int? qualityScore,
    int? reportCount,
    DateTime? flaggedAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      series: series ?? this.series,
      category: category ?? this.category,
      rarity: rarity ?? this.rarity,
      price: price ?? this.price,
      condition: condition ?? this.condition,
      imageUrls: imageUrls ?? this.imageUrls,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerVerified: sellerVerified ?? this.sellerVerified,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      postedAt: postedAt ?? this.postedAt,
      isAvailable: isAvailable ?? this.isAvailable,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      qualityScore: qualityScore ?? this.qualityScore,
      reportCount: reportCount ?? this.reportCount,
      flaggedAt: flaggedAt ?? this.flaggedAt,
    );
  }
}
