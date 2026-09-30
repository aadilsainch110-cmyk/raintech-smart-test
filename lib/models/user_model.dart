class UserModel {
  final String? id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? studentId;
  final String? classId;
  final String? shiftId;
  final String? photoUrl;
  final bool isActive;
  final DateTime? createdAt;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.studentId,
    this.classId,
    this.shiftId,
    this.photoUrl,
    this.isActive = true,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return UserModel(
      id: id ?? json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'student',
      studentId: json['studentId'],
      classId: json['classId'],
      shiftId: json['shiftId'],
      photoUrl: json['photoUrl'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      'role': role,
      if (studentId != null) 'studentId': studentId,
      if (classId != null) 'classId': classId,
      if (shiftId != null) 'shiftId': shiftId,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? studentId,
    String? classId,
    String? shiftId,
    String? photoUrl,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      shiftId: shiftId ?? this.shiftId,
      photoUrl: photoUrl ?? this.photoUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
