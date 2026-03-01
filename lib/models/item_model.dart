import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anigoods/services/moderation_service.dart';

class ContactLink {
  final String platform;
  final String url;

  ContactLink({required this.platform, required this.url});

  factory ContactLink.fromMap(Map<String, dynamic> map) => ContactLink(
        platform: map['platform'] ?? '',
        url: map['url'] ?? '',
      );

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
  final String imageUrl;   // ← URL จาก Firebase Storage
  final String sellerId;
  final String sellerName;
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
    required this.imageUrl,
    required this.sellerId,
    required this.sellerName,
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
    final d = doc.data() as Map<String, dynamic>;
    return ItemModel(
      id: doc.id,
      title: d['title'] ?? '',
      series: d['series'] ?? '',
      category: d['category'] ?? '',
      rarity: d['rarity'] ?? 'Common',
      price: (d['price'] ?? 0).toDouble(),
      condition: d['condition'] ?? 'Good',
      imageUrl: d['imageUrl'] ?? '',
      sellerId: d['sellerId'] ?? '',
      sellerName: d['sellerName'] ?? '',
      description: d['description'] ?? '',
      tags: List<String>.from(d['tags'] ?? []),
      contactLinks: (d['contactLinks'] as List<dynamic>? ?? [])
          .map((e) => ContactLink.fromMap(e))
          .toList(),
      postedAt: (d['postedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      moderationStatus: ModerationStatus.values.firstWhere(
        (e) => e.name == (d['moderationStatus'] ?? 'pending'),
        orElse: () => ModerationStatus.pending,
      ),
      qualityScore: d['qualityScore'] ?? 0,
      reportCount: d['reportCount'],
      flaggedAt: (d['flaggedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'series': series,
        'category': category,
        'rarity': rarity,
        'price': price,
        'condition': condition,
        'imageUrl': imageUrl,
        'sellerId': sellerId,
        'sellerName': sellerName,
        'description': description,
        'tags': tags,
        'contactLinks': contactLinks.map((e) => e.toMap()).toList(),
        'postedAt': Timestamp.fromDate(postedAt),
        'moderationStatus': moderationStatus.name,
        'qualityScore': qualityScore,
        'reportCount': reportCount,
        'flaggedAt': flaggedAt != null ? Timestamp.fromDate(flaggedAt!) : null,
      };

  bool matchesQuery(String query) {
    final q = query.toLowerCase();
    return title.toLowerCase().contains(q) ||
        series.toLowerCase().contains(q) ||
        tags.any((t) => t.toLowerCase().contains(q));
  }
}
