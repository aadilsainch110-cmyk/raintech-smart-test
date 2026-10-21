class QuestionModel {
  final String? id;
  final String? testId;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;
  final int marks;
  final int order;
  final DateTime? createdAt;

  QuestionModel({
    this.id,
    this.testId,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    required this.marks,
    required this.order,
    this.createdAt,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json, {String? id}) {
    try {
      // Handle createdAt field - could be Timestamp or String
      DateTime? parsedCreatedAt;
      if (json['createdAt'] != null) {
        if (json['createdAt'] is String) {
          parsedCreatedAt = DateTime.parse(json['createdAt'] as String);
        } else if (json['createdAt'].toString().contains('Timestamp')) {
          // Firestore Timestamp - extract seconds
          final timestamp = json['createdAt'];
          if (timestamp is Map && timestamp.containsKey('_seconds')) {
            parsedCreatedAt = DateTime.fromMillisecondsSinceEpoch(
              (timestamp['_seconds'] as int) * 1000,
            );
          }
        }
      }

      return QuestionModel(
        id: id ?? json['id'],
        testId: json['testId'],
        question: json['question'] ?? '',
        optionA: json['optionA'] ?? '',
        optionB: json['optionB'] ?? '',
        optionC: json['optionC'] ?? '',
        optionD: json['optionD'] ?? '',
        correctAnswer: json['correctAnswer'] ?? 'A',
        marks: json['marks'] ?? 1,
        order: json['order'] ?? 0,
        createdAt: parsedCreatedAt,
      );
    } catch (e) {
      print('DEBUG: Error parsing QuestionModel: $e');
      print('DEBUG: JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (testId != null) 'testId': testId,
      'question': question,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'correctAnswer': correctAnswer,
      'marks': marks,
      'order': order,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
    };
  }

  QuestionModel copyWith({
    String? id,
    String? testId,
    String? question,
    String? optionA,
    String? optionB,
    String? optionC,
    String? optionD,
    String? correctAnswer,
    int? marks,
    int? order,
    DateTime? createdAt,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      testId: testId ?? this.testId,
      question: question ?? this.question,
      optionA: optionA ?? this.optionA,
      optionB: optionB ?? this.optionB,
      optionC: optionC ?? this.optionC,
      optionD: optionD ?? this.optionD,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      marks: marks ?? this.marks,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class QuestionBankModel {
  final String? id;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;
  final int marks;
  final String? courseId;
  final String? category;
  final String? difficulty;
  final String? createdBy;
  final DateTime? createdAt;

  QuestionBankModel({
    this.id,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    required this.marks,
    this.courseId,
    this.category,
    this.difficulty,
    this.createdBy,
    this.createdAt,
  });

  factory QuestionBankModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return QuestionBankModel(
      id: id ?? json['id'],
      question: json['question'] ?? '',
      optionA: json['optionA'] ?? '',
      optionB: json['optionB'] ?? '',
      optionC: json['optionC'] ?? '',
      optionD: json['optionD'] ?? '',
      correctAnswer: json['correctAnswer'] ?? 'A',
      marks: json['marks'] ?? 1,
      courseId: json['courseId'],
      category: json['category'],
      difficulty: json['difficulty'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'question': question,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'correctAnswer': correctAnswer,
      'marks': marks,
      if (courseId != null) 'courseId': courseId,
      if (category != null) 'category': category,
      if (difficulty != null) 'difficulty': difficulty,
      if (createdBy != null) 'createdBy': createdBy,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
    };
  }

  QuestionBankModel copyWith({
    String? id,
    String? question,
    String? optionA,
    String? optionB,
    String? optionC,
    String? optionD,
    String? correctAnswer,
    int? marks,
    String? courseId,
    String? category,
    String? difficulty,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return QuestionBankModel(
      id: id ?? this.id,
      question: question ?? this.question,
      optionA: optionA ?? this.optionA,
      optionB: optionB ?? this.optionB,
      optionC: optionC ?? this.optionC,
      optionD: optionD ?? this.optionD,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      marks: marks ?? this.marks,
      courseId: courseId ?? this.courseId,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
