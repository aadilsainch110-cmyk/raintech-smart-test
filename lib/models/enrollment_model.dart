class EnrollmentModel {
  final String? id;
  final String studentId;
  final String courseId;
  final String? classId;
  final String shiftId;
  final String status;
  final DateTime? createdAt;

  EnrollmentModel({
    this.id,
    required this.studentId,
    required this.courseId,
    this.classId,
    required this.shiftId,
    this.status = 'pending',
    this.createdAt,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return EnrollmentModel(
      id: id ?? json['id'],
      studentId: json['studentId'] ?? '',
      courseId: json['courseId'] ?? '',
      classId: json['classId'],
      shiftId: json['shiftId'] ?? '',
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'studentId': studentId,
      'courseId': courseId,
      if (classId != null) 'classId': classId,
      'shiftId': shiftId,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  EnrollmentModel copyWith({
    String? id,
    String? studentId,
    String? courseId,
    String? classId,
    String? shiftId,
    String? status,
    DateTime? createdAt,
  }) {
    return EnrollmentModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      courseId: courseId ?? this.courseId,
      classId: classId ?? this.classId,
      shiftId: shiftId ?? this.shiftId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
