import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String category; // 'Maintenance', 'Urgent Alert', 'Power Outage', 'Inspection'
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    this.category = 'Maintenance',
    this.isActive = true,
    this.createdBy = 'Facility Admin',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AnnouncementModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return AnnouncementModel(
      id: id,
      title: map['title'] ?? 'Notice',
      content: map['content'] ?? '',
      category: map['category'] ?? 'Maintenance',
      isActive: map['isActive'] ?? true,
      createdBy: map['createdBy'] ?? 'Facility Admin',
      createdAt: parseDate(map['createdAt']),
    );
  }
}
