class AttemptModel {
  final String? id;
  final String testId;
  final String studentId;
  final Map<int, String> answers;
  final DateTime? startedAt;
  final DateTime? submittedAt;
  final int? timeTakenSeconds;

  AttemptModel({
    this.id,
    required this.testId,
    required this.studentId,
    required this.answers,
    this.startedAt,
    this.submittedAt,
    this.timeTakenSeconds,
  });

  factory AttemptModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return AttemptModel(
      id: id ?? json['id'],
      testId: json['testId'] ?? '',
      studentId: json['studentId'] ?? '',
      answers: Map<int, String>.from(json['answers'] ?? {}),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : null,
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'])
          : null,
      timeTakenSeconds: json['timeTakenSeconds'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'testId': testId,
      'studentId': studentId,
      'answers': answers,
      if (startedAt != null) 'startedAt': startedAt?.toIso8601String(),
      if (submittedAt != null) 'submittedAt': submittedAt?.toIso8601String(),
      if (timeTakenSeconds != null) 'timeTakenSeconds': timeTakenSeconds,
    };
  }

  AttemptModel copyWith({
    String? id,
    String? testId,
    String? studentId,
    Map<int, String>? answers,
    DateTime? startedAt,
    DateTime? submittedAt,
    int? timeTakenSeconds,
  }) {
    return AttemptModel(
      id: id ?? this.id,
      testId: testId ?? this.testId,
      studentId: studentId ?? this.studentId,
      answers: answers ?? this.answers,
      startedAt: startedAt ?? this.startedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      timeTakenSeconds: timeTakenSeconds ?? this.timeTakenSeconds,
    );
  }
}
