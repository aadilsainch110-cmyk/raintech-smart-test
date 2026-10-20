class ResultModel {
  final String? id;
  final String testId;
  final String studentId;
  final int totalMarks;
  final int obtainedMarks;
  final double percentage;
  final int correctAnswers;
  final int wrongAnswers;
  final String status;
  final int? position;
  final bool showPosition;
  final DateTime? submittedAt;
  final DateTime? createdAt;

  ResultModel({
    this.id,
    required this.testId,
    required this.studentId,
    required this.totalMarks,
    required this.obtainedMarks,
    required this.percentage,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.status,
    this.position,
    this.showPosition = false,
    this.submittedAt,
    this.createdAt,
  });

  factory ResultModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return ResultModel(
      id: id ?? json['id'],
      testId: json['testId'] ?? '',
      studentId: json['studentId'] ?? '',
      totalMarks: json['totalMarks'] ?? 0,
      obtainedMarks: json['obtainedMarks'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      correctAnswers: json['correctAnswers'] ?? 0,
      wrongAnswers: json['wrongAnswers'] ?? 0,
      status: json['status'] ?? 'FAIL',
      position: json['position'],
      showPosition: json['showPosition'] ?? false,
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'testId': testId,
      'studentId': studentId,
      'totalMarks': totalMarks,
      'obtainedMarks': obtainedMarks,
      'percentage': percentage,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'status': status,
      if (position != null) 'position': position,
      'showPosition': showPosition,
      if (submittedAt != null) 'submittedAt': submittedAt?.toIso8601String(),
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
    };
  }

  ResultModel copyWith({
    String? id,
    String? testId,
    String? studentId,
    int? totalMarks,
    int? obtainedMarks,
    double? percentage,
    int? correctAnswers,
    int? wrongAnswers,
    String? status,
    int? position,
    bool? showPosition,
    DateTime? submittedAt,
    DateTime? createdAt,
  }) {
    return ResultModel(
      id: id ?? this.id,
      testId: testId ?? this.testId,
      studentId: studentId ?? this.studentId,
      totalMarks: totalMarks ?? this.totalMarks,
      obtainedMarks: obtainedMarks ?? this.obtainedMarks,
      percentage: percentage ?? this.percentage,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      status: status ?? this.status,
      position: position ?? this.position,
      showPosition: showPosition ?? this.showPosition,
      submittedAt: submittedAt ?? this.submittedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String getPositionDisplay() {
    if (position == null) return 'Results not released yet';
    return '$position${_getOrdinalSuffix(position!)}';
  }

  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) {
      return 'th';
    }
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String getGrade() {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C';
    if (percentage >= 40) return 'D';
    return 'F';
  }
}
