import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  final String id;
  final String ticketNumber;
  final String title;
  final String description;
  final String category;
  final String location; // short text, e.g. "CS Block, Room 12"
  final String status; // 'Open', 'Assigned', 'In Progress', 'Resolved', 'Rejected'
  final String priority; // 'Low', 'Medium', 'High', 'Urgent'
  final String studentId; // Firebase uid for student complaints
  final String studentName;
  final String studentEmail;
  final String regNo;
  final String assignedTo;
  final String remarks;
  final String? imageUrl;
  final String address; // full reverse-geocoded address from the student app
  final double? latitude;
  final double? longitude;
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
    this.regNo = '',
    this.assignedTo = '',
    this.remarks = '',
    this.imageUrl,
    this.address = '',
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.updatedAt,
  });

  // ---------- handy getters ----------

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  bool get hasCoordinates => latitude != null && longitude != null;

  /// Opens Google Maps at the reported spot (use with url_launcher).
  String? get mapsUrl => hasCoordinates
      ? 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude'
      : null;

  /// Small version of the photo for list cards. Cloudinary resizes images
  /// on the fly when you put a transformation in the URL, so the list
  /// downloads ~10 KB instead of the full photo.
  String? get thumbnailUrl {
    if (!hasImage) return null;
    const marker = '/upload/';
    final url = imageUrl!;
    if (!url.contains('res.cloudinary.com') || !url.contains(marker)) {
      return url;
    }
    return url.replaceFirst(marker, '$marker' 'w_240,h_240,c_fill,q_auto,f_auto/');
  }

  /// "Iman Fatima (COSC231101093)". Falls back gracefully for old tickets.
  String get studentLabel {
    if (regNo.isNotEmpty) return '$studentName ($regNo)';
    // old tickets stored a short department / student id; a uid is too long
    if (studentId.isNotEmpty && studentId.length <= 20) {
      return '$studentName ($studentId)';
    }
    return studentName;
  }

  // ---------- Firestore ----------

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
      'regNo': regNo,
      'assignedTo': assignedTo,
      'remarks': remarks,
      'imageUrl': imageUrl,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
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

    // first non-empty string among the given values
    String firstText(List<dynamic> values, String fallback) {
      for (final v in values) {
        final s = v?.toString().trim() ?? '';
        if (s.isNotEmpty) return s;
      }
      return fallback;
    }

    final rawImage = map['imageUrl']?.toString().trim() ?? '';

    return TicketModel(
      id: docId,
      ticketNumber: map['ticketNumber'] ??
          map['ticketId'] ??
          '#CF-${docId.substring(0, docId.length > 5 ? 5 : docId.length).toUpperCase()}',
      title: map['title'] ?? 'Maintenance Request',
      description: map['description'] ?? map['desc'] ?? '',
      category: map['category'] ?? 'General',
      // student complaints use locationDetail (short); admin tickets use location
      location: firstText([map['locationDetail'], map['location']], 'Campus'),
      status: map['status'] ?? 'Open',
      priority: map['priority'] ?? 'Medium',
      studentId: map['studentId'] ?? map['deptId'] ?? '',
      studentName: map['studentName'] ?? map['name'] ?? 'Student',
      studentEmail: map['studentEmail'] ?? map['email'] ?? '',
      regNo: map['regNo']?.toString() ?? '',
      assignedTo: map['assignedTo'] ?? '',
      remarks: map['remarks'] ?? map['adminNote'] ?? '',
      imageUrl: rawImage.isEmpty ? null : rawImage,
      address: map['address']?.toString() ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
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
      regNo: regNo,
      assignedTo: assignedTo ?? this.assignedTo,
      remarks: remarks ?? this.remarks,
      imageUrl: imageUrl,
      address: address,
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}