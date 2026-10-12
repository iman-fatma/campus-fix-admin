import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String id;
  final String name;
  final String studentId;
  final String email;
  final String department;
  final int semester;
  final String role;
  final DateTime? createdAt;

  StudentModel({
    required this.id,
    required this.name,
    required this.studentId,
    required this.email,
    required this.department,
    this.semester = 1,
    this.role = 'student',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'fullName': name,
      'studentId': studentId,
      'deptId': studentId,
      'email': email,
      'department': department,
      'semester': semester,
      'role': role,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : Timestamp.now(),
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    String studentName = (map['name'] ?? map['fullName'] ?? map['studentName'] ?? '').toString().trim();
    if (studentName.isEmpty && map['email'] != null) {
      studentName = map['email'].toString().split('@').first;
    }

    int sem = 1;
    if (map['semester'] != null) {
      sem = int.tryParse(map['semester'].toString()) ?? 1;
    }

    return StudentModel(
      id: id,
      name: studentName.isEmpty ? 'Student' : studentName,
      studentId: (map['studentId'] ?? map['deptId'] ?? map['id'] ?? 'N/A').toString(),
      email: (map['email'] ?? '').toString(),
      department: (map['department'] ?? map['dept'] ?? 'Computer Science').toString(),
      semester: sem,
      role: (map['role'] ?? 'student').toString(),
      createdAt: parseDate(map['createdAt']),
    );
  }

  String get initials {
    if (name.trim().isEmpty) return 'ST';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }
}
