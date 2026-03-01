import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportReason {
  fakeItem,
  wrongCategory,
  inappropriateContent,
  spam,
  scam,
  duplicateListing,
  other;

  String get displayName {
    switch (this) {
      case ReportReason.fakeItem:
        return 'Fake or counterfeit item';
      case ReportReason.wrongCategory:
        return 'Wrong category';
      case ReportReason.inappropriateContent:
        return 'Inappropriate content';
      case ReportReason.spam:
        return 'Spam or misleading';
      case ReportReason.scam:
        return 'Suspected scam';
      case ReportReason.duplicateListing:
        return 'Duplicate listing';
      case ReportReason.other:
        return 'Other';
    }
  }
}

class ReportModel {
  final String id;
  final String itemId;
  final String itemTitle;
  final String reporterId;
  final String reporterName;
  final ReportReason reason;
  final String? additionalInfo;
  final List<String> evidenceUrls;
  final DateTime createdAt;
  final bool reviewed;
  final String? adminNote;

  ReportModel({
    required this.id,
    required this.itemId,
    required this.itemTitle,
    required this.reporterId,
    required this.reporterName,
    required this.reason,
    this.additionalInfo,
    this.evidenceUrls = const [],
    required this.createdAt,
    this.reviewed = false,
    this.adminNote,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      itemId: d['itemId'] ?? '',
      itemTitle: d['itemTitle'] ?? '',
      reporterId: d['reporterId'] ?? '',
      reporterName: d['reporterName'] ?? '',
      reason: ReportReason.values.firstWhere(
        (e) => e.name == d['reason'],
        orElse: () => ReportReason.other,
      ),
      additionalInfo: d['additionalInfo'],
      evidenceUrls: List<String>.from(d['evidenceUrls'] ?? []),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reviewed: d['reviewed'] ?? false,
      adminNote: d['adminNote'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'itemId': itemId,
        'itemTitle': itemTitle,
        'reporterId': reporterId,
        'reporterName': reporterName,
        'reason': reason.name,
        'additionalInfo': additionalInfo,
        'evidenceUrls': evidenceUrls,
        'createdAt': Timestamp.fromDate(createdAt),
        'reviewed': reviewed,
        'adminNote': adminNote,
      };
}