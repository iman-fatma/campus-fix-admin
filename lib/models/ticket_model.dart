import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  final String id;
  final String ticketNumber;
  final String title;
  final String description;
  final String category;
  final String location;
  final String status; // 'Open', 'Assigned', 'In Progress', 'Resolved', 'Rejected'
  final String priority; // 'Low', 'Medium', 'High', 'Urgent'
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String assignedTo;
  final String remarks;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TicketModel({
    required this.id,
    required this.ticketNumber,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    this.status = 'Open',
    this.priority = 'Medium',
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    this.assignedTo = '',
    this.remarks = '',
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'ticketNumber': ticketNumber,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'status': status,
      'priority': priority,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'assignedTo': assignedTo,
      'remarks': remarks,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : Timestamp.now(),
    };
  }

  factory TicketModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return TicketModel(
      id: docId,
      ticketNumber: map['ticketNumber'] ?? map['ticketId'] ?? '#CF-${docId.substring(0, docId.length > 5 ? 5 : docId.length).toUpperCase()}',
      title: map['title'] ?? 'Maintenance Request',
      description: map['description'] ?? map['desc'] ?? '',
      category: map['category'] ?? 'General',
      location: map['location'] ?? 'Campus',
      status: map['status'] ?? 'Open',
      priority: map['priority'] ?? 'Medium',
      studentId: map['studentId'] ?? map['deptId'] ?? '',
      studentName: map['studentName'] ?? map['name'] ?? 'Student',
      studentEmail: map['studentEmail'] ?? map['email'] ?? '',
      assignedTo: map['assignedTo'] ?? '',
      remarks: map['remarks'] ?? map['adminNote'] ?? '',
      imageUrl: map['imageUrl'],
      createdAt: parseDate(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? parseDate(map['updatedAt']) : null,
    );
  }

  TicketModel copyWith({
    String? status,
    String? priority,
    String? assignedTo,
    String? remarks,
    DateTime? updatedAt,
  }) {
    return TicketModel(
      id: id,
      ticketNumber: ticketNumber,
      title: title,
      description: description,
      category: category,
      location: location,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      studentId: studentId,
      studentName: studentName,
      studentEmail: studentEmail,
      assignedTo: assignedTo ?? this.assignedTo,
      remarks: remarks ?? this.remarks,
      imageUrl: imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
