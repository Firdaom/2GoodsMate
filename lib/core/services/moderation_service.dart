import 'package:anigoods/models/item_model.dart';
import 'package:flutter/material.dart';


enum ModerationStatus {
  approved,    // ผ่าน -> แสดงทันที
  pending,     // รอ admin review
  flagged,     // มีปัญหา -> ส่ง admin
  rejected;    // ไม่ผ่าน
}

extension ModerationStatusUI on ModerationStatus {
  String get displayName {
    switch (this) {
      case ModerationStatus.approved: return 'Approved';
      case ModerationStatus.pending: return 'Pending Review';
      case ModerationStatus.flagged: return 'Flagged';
      case ModerationStatus.rejected: return 'Rejected';
    }
  }

 IconData get icon {
    switch (this) {
      case ModerationStatus.approved: return Icons.check_circle_outline;
      case ModerationStatus.pending: return Icons.hourglass_empty; 
      case ModerationStatus.flagged: return Icons.warning_amber_rounded;
      case ModerationStatus.rejected: return Icons.cancel_outlined;
    }
  }

  Color get color {
    switch (this) {
      case ModerationStatus.approved: return Colors.green;
      case ModerationStatus.pending: return Colors.orange;
      case ModerationStatus.flagged: return Colors.amber.shade900;
      case ModerationStatus.rejected: return Colors.red;
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
  static const double _minPrice = 10.0;
  static const double _maxPrice = 500000.0;
  static const int _minDescLength = 20;

  static const _spamKeywords = [
    'เพิ่มไลน์', 'add line', 'inbox', 'dm me', 'ส่งข้อความ', 'line id',
    'http://', 'https://', 'www.', '.com', 'bit.ly',
    'รับตัวแทนจำหน่าย', 'หาคนขาย', 'งานพาร์ทไทม์',
  ];

  static const _inappropriateWords = [
    'fuck', 'shit', 'bitch',
  ];

  static Future<ModerationResult> checkItem(ItemModel item) async {
    final issues = <String>[];

    if (_containsKeywords(item.title, _spamKeywords)) {
      return ModerationResult.rejected('Title contains spam or promotional content');
    }
    if (_containsKeywords(item.title, _inappropriateWords)) {
      return ModerationResult.rejected('Title contains inappropriate language');
    }
    if (_containsKeywords(item.description, _spamKeywords)) {
      return ModerationResult.rejected('Description contains spam or links');
    }
    if (_containsKeywords(item.description, _inappropriateWords)) {
      return ModerationResult.rejected('Description contains inappropriate language');
    }

    // ใช้ Constants แทน Magic Numbers
    if (item.price < _minPrice) issues.add('Price too low (< ฿$_minPrice)');
    if (item.price > _maxPrice) issues.add('Price too high (> ฿$_maxPrice)');
    if (item.description.length < _minDescLength) issues.add('Description too short (< $_minDescLength characters)');

    if (item.imageUrls.isEmpty) {
      return ModerationResult.rejected('At least one image is required');
    }

    if (issues.isNotEmpty) {
      return ModerationResult.flagged('Item needs review', issues);
    }

    return ModerationResult.approved();
  }

  
  static bool _containsKeywords(String text, List<String> keywords) {
    final lowerText = text.toLowerCase();
    return keywords.any((keyword) => lowerText.contains(keyword.toLowerCase()));
  }

  static int calculateQualityScore(ItemModel item) {
    int score = 0;

    // Image quality 
    if (item.imageUrls.isNotEmpty) score += 20;
    if (item.imageUrls.length >= 3) score += 10;

    // Description quality 
    if (item.description.length >= 100) score += 15;
    if (item.description.length >= 200) score += 15;

    // Completeness 
    if (item.tags.isNotEmpty) score += 10;
    if (item.tags.length >= 3) score += 10;

    // Category info 
    if (item.series.isNotEmpty) score += 10;
    if (item.rarity != 'Common') score += 5;
    if (item.condition != 'Good') score += 5;

    return score;
  }
}