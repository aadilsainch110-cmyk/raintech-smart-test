class CourseModel {
  final String? id;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;

  CourseModel({
    this.id,
    required this.name,
    this.description,
    this.isActive = true,
    this.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return CourseModel(
      id: id ?? json['id'],
      name: json['name'] ?? '',
      description: json['description'],
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
      if (description != null) 'description': description,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  CourseModel copyWith({
    String? id,
    String? name,
    String? description,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return CourseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
