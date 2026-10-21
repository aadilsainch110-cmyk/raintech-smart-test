class TestModel {
  final String? id;
  final String title;
  final String? description;
  final String courseId;
  final String? classId;
  final String shiftId;
  final int durationMinutes;
  final int totalMarks;
  final int passingMarks;
  final String status;
  final String createdBy;
  final int questionCount;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool resultsReleased;
  final DateTime? resultsReleasedAt;

  TestModel({
    this.id,
    required this.title,
    this.description,
    required this.courseId,
    this.classId,
    required this.shiftId,
    required this.durationMinutes,
    required this.totalMarks,
    required this.passingMarks,
    this.status = 'draft',
    required this.createdBy,
    this.questionCount = 0,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
    this.resultsReleased = false,
    this.resultsReleasedAt,
  });

  factory TestModel.fromJson(Map<String, dynamic> json, {String? id}) {
    try {
      print('DEBUG: TestModel.fromJson called');
      print('DEBUG:   id parameter: "$id"');
      print('DEBUG:   json[\'id\']: "${json['id']}"');
      print('DEBUG:   Using ID: "${id ?? json['id']}"');

      return TestModel(
        id: id ?? json['id'],
        title: json['title'] ?? '',
        description: json['description'],
        courseId: json['courseId'] ?? '',
        classId: json['classId'],
        shiftId: json['shiftId'] ?? '',
        durationMinutes: json['durationMinutes'] ?? 0,
        totalMarks: json['totalMarks'] ?? 0,
        passingMarks: json['passingMarks'] ?? 0,
        status: json['status'] ?? 'draft',
        createdBy: json['createdBy'] ?? '',
        questionCount: json['questionCount'] ?? 0,
        startDate: json['startDate'] != null
            ? DateTime.parse(json['startDate'])
            : null,
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'])
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
        resultsReleased: json['resultsReleased'] ?? false,
        resultsReleasedAt: json['resultsReleasedAt'] != null
            ? DateTime.parse(json['resultsReleasedAt'])
            : null,
      );
    } catch (e) {
      print('DEBUG: Error in TestModel.fromJson: $e');
      print('DEBUG: JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      if (description != null) 'description': description,
      'courseId': courseId,
      if (classId != null) 'classId': classId,
      'shiftId': shiftId,
      'durationMinutes': durationMinutes,
      'totalMarks': totalMarks,
      'passingMarks': passingMarks,
      'status': status,
      'createdBy': createdBy,
      'questionCount': questionCount,
      if (startDate != null) 'startDate': startDate?.toIso8601String(),
      if (endDate != null) 'endDate': endDate?.toIso8601String(),
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
      'resultsReleased': resultsReleased,
      if (resultsReleasedAt != null) 'resultsReleasedAt': resultsReleasedAt?.toIso8601String(),
    };
  }

  TestModel copyWith({
    String? id,
    String? title,
    String? description,
    String? courseId,
    String? classId,
    String? shiftId,
    int? durationMinutes,
    int? totalMarks,
    int? passingMarks,
    String? status,
    String? createdBy,
    int? questionCount,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? resultsReleased,
    DateTime? resultsReleasedAt,
  }) {
    return TestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      courseId: courseId ?? this.courseId,
      classId: classId ?? this.classId,
      shiftId: shiftId ?? this.shiftId,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      totalMarks: totalMarks ?? this.totalMarks,
      passingMarks: passingMarks ?? this.passingMarks,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      questionCount: questionCount ?? this.questionCount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resultsReleased: resultsReleased ?? this.resultsReleased,
      resultsReleasedAt: resultsReleasedAt ?? this.resultsReleasedAt,
    );
  }
}
