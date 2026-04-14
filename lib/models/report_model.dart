import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anigoods/core/constants/firebase_constants.dart';

enum ReportReason {
  fakeItem,
  wrongCategory,
  inappropriateContent,
  spam,
  scam,
  duplicateListing,
  other;
}

extension ReportReasonUIExtension on ReportReason {
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
    final data = doc.data() as Map<String, dynamic>; 
    
    return ReportModel(
      id: doc.id,
      itemId: data[ReportFields.itemId] ?? '',
      itemTitle: data[ReportFields.itemTitle] ?? '',
      reporterId: data[ReportFields.reporterId] ?? '',
      reporterName: data[ReportFields.reporterName] ?? '',
      reason: ReportReason.values.firstWhere(
        (e) => e.name == data[ReportFields.reason],
        orElse: () => ReportReason.other,
      ),
      additionalInfo: data[ReportFields.additionalInfo],
      evidenceUrls: List<String>.from(data[ReportFields.evidenceUrls] ?? []),
      createdAt: (data[ReportFields.createdAt] as Timestamp?)?.toDate() ?? DateTime.now(),
      reviewed: data[ReportFields.reviewed] ?? false,
      adminNote: data[ReportFields.adminNote],
    );
  }

  Map<String, dynamic> toFirestore() => {
        ReportFields.itemId: itemId,
        ReportFields.itemTitle: itemTitle,
        ReportFields.reporterId: reporterId,
        ReportFields.reporterName: reporterName,
        ReportFields.reason: reason.name,
        ReportFields.additionalInfo: additionalInfo,
        ReportFields.evidenceUrls: evidenceUrls,
        ReportFields.createdAt: Timestamp.fromDate(createdAt),
        ReportFields.reviewed: reviewed,
        ReportFields.adminNote: adminNote,
      };
}