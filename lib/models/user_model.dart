class UserModel {
  final String? id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String role;
  final String? studentId;
  final String? classId;
  final String? shiftId;
  final String? photoUrl;
  final bool isActive;
  final String? approvalStatus;
  final DateTime? createdAt;
  final String? secretCode;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    required this.role,
    this.studentId,
    this.classId,
    this.shiftId,
    this.photoUrl,
    this.isActive = true,
    this.approvalStatus = 'pending',
    this.createdAt,
    this.secretCode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return UserModel(
      id: id ?? json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      role: json['role'] ?? 'student',
      studentId: json['studentId'],
      classId: json['classId'],
      shiftId: json['shiftId'],
      photoUrl: json['photoUrl'],
      isActive: json['isActive'] ?? true,
      approvalStatus: json['approvalStatus'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      secretCode: json['secretCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      'role': role,
      if (studentId != null) 'studentId': studentId,
      if (classId != null) 'classId': classId,
      if (shiftId != null) 'shiftId': shiftId,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'isActive': isActive,
      'approvalStatus': approvalStatus,
      'createdAt': createdAt?.toIso8601String(),
      if (secretCode != null) 'secretCode': secretCode,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? role,
    String? studentId,
    String? classId,
    String? shiftId,
    String? photoUrl,
    bool? isActive,
    String? approvalStatus,
    DateTime? createdAt,
    String? secretCode,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      shiftId: shiftId ?? this.shiftId,
      photoUrl: photoUrl ?? this.photoUrl,
      isActive: isActive ?? this.isActive,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      createdAt: createdAt ?? this.createdAt,
      secretCode: secretCode ?? this.secretCode,
    );
  }
}
