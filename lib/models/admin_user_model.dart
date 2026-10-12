class AdminUserModel {
  final String uid;
  final String email;
  final String fullName;
  final String role;
  final String department;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  AdminUserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.role = 'admin',
    this.department = 'Campus Facilities & Operations',
    this.createdAt,
    this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'role': role,
      'department': department,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory AdminUserModel.fromMap(Map<String, dynamic> map, String id) {
    return AdminUserModel(
      uid: id,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? map['name'] ?? 'Facility Admin',
      role: (map['role'] ?? 'admin').toString().toLowerCase(),
      department: map['department'] ?? 'Campus Facilities & Operations',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
      lastLogin: map['lastLogin'] != null
          ? DateTime.tryParse(map['lastLogin'].toString())
          : null,
    );
  }

  String get initials {
    if (fullName.trim().isEmpty) return 'AD';
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }
}
