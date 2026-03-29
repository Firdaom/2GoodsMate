import 'package:anigoods/models/item_model.dart';

enum ModerationStatus {
  approved,    // ✅ ผ่าน → แสดงทันที
  pending,     // ⏳ รอ admin review
  flagged,     // ⚠️ มีปัญหา → ส่ง admin
  rejected;    // ❌ ไม่ผ่าน

  String get displayName {
    switch (this) {
      case ModerationStatus.approved:
        return 'Approved';
      case ModerationStatus.pending:
        return 'Pending Review';
      case ModerationStatus.flagged:
        return 'Flagged';
      case ModerationStatus.rejected:
        return 'Rejected';
    }
  }

  String get emoji {
    switch (this) {
      case ModerationStatus.approved:
        return '✅';
      case ModerationStatus.pending:
        return '⏳';
      case ModerationStatus.flagged:
        return '⚠️';
      case ModerationStatus.rejected:
        return '❌';
    }
  }
}

class ModerationResult {
  final ModerationStatus status;
  final String? reason;
  final List<String> issues;

  ModerationResult({
    required this.status,
    this.reason,
    this.issues = const [],
  });

  factory ModerationResult.approved() => ModerationResult(status: ModerationStatus.approved);
  
  factory ModerationResult.pending(String reason) => ModerationResult(
        status: ModerationStatus.pending,
        reason: reason,
      );
  
  factory ModerationResult.flagged(String reason, List<String> issues) => ModerationResult(
        status: ModerationStatus.flagged,
        reason: reason,
        issues: issues,
      );
  
  factory ModerationResult.rejected(String reason) => ModerationResult(
        status: ModerationStatus.rejected,
        reason: reason,
      );

  bool get isApproved => status == ModerationStatus.approved;
}

class ModerationService {
  // ✅ Spam keywords ภาษาไทย + อังกฤษ
  static const _spamKeywords = [
    'เพิ่มไลน์',
    'add line',
    'inbox',
    'dm me',
    'ส่งข้อความ',
    'ไลน์',
    'line:',
    'line id',
    'http://',
    'https://',
    'www.',
    '.com',
    'bit.ly',
    'รับตัวแทนจำหน่าย',
    'หาคนขาย',
    'งานพาร์ทไทม์',
  ];

  // ✅ Inappropriate words
  static const _inappropriateWords = [
    'fuck',
    'shit',
    'bitch',
    // เพิ่มตามต้องการ (ไม่ใส่เยอะเพราะอาจ false positive)
  ];

  // ✅ Main check function
  static Future<ModerationResult> checkItem(ItemModel item) async {
    final issues = <String>[];

    // 1. Check title
    if (_containsSpam(item.title)) {
      return ModerationResult.rejected('Title contains spam or promotional content');
    }

    if (_containsInappropriate(item.title)) {
      return ModerationResult.rejected('Title contains inappropriate language');
    }

    // 2. Check description
    if (_containsSpam(item.description)) {
      return ModerationResult.rejected('Description contains spam or links');
    }

    if (_containsInappropriate(item.description)) {
      return ModerationResult.rejected('Description contains inappropriate language');
    }

    // 3. Check price (ไม่ควรต่ำหรือสูงเกินไป)
    if (item.price < 10) {
      issues.add('Price too low (< ฿10)');
    }
    if (item.price > 500000) {
      issues.add('Price too high (> ฿500,000)');
    }

    // 4. Check description length
    if (item.description.length < 20) {
      issues.add('Description too short (< 20 characters)');
    }

    // 5. Check if has image
    if (item.imageUrls.isEmpty) {
      return ModerationResult.rejected('At least one image is required');
    }

    // 6. ถ้ามี issues แต่ไม่ reject → flag for review
    if (issues.isNotEmpty) {
      return ModerationResult.flagged('Item needs review', issues);
    }

    // 7. ✅ All good
    return ModerationResult.approved();
  }

  // Helper: Check spam keywords
  static bool _containsSpam(String text) {
    final lower = text.toLowerCase();
    return _spamKeywords.any((keyword) => lower.contains(keyword.toLowerCase()));
  }

  // Helper: Check inappropriate words
  static bool _containsInappropriate(String text) {
    final lower = text.toLowerCase();
    return _inappropriateWords.any((word) => lower.contains(word));
  }

  // ✅ Calculate quality score (0-100)
  static int calculateQualityScore(ItemModel item) {
    int score = 0;

    // Image quality (30 points)
    if (item.imageUrls.isNotEmpty) score += 20;
    // ถ้ามีหลายรูป (ต้องเพิ่ม imageUrls field ใน ItemModel)
    // if (item.imageUrls?.length >= 3) score += 10;

    // Description quality (30 points)
    if (item.description.length >= 100) score += 15;
    if (item.description.length >= 200) score += 15;

    // Completeness (20 points)
    if (item.tags.isNotEmpty) score += 10;
    if (item.tags.length >= 3) score += 10;

    // Category info (20 points)
    if (item.series.isNotEmpty) score += 10;
    if (item.rarity != 'Common') score += 5;
    if (item.condition != 'Good') score += 5;

    return score;
  }
}