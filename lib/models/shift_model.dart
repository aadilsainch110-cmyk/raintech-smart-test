class ShiftModel {
  final String? id;
  final String name;
  final String? description;
  final String? startTime;
  final String? endTime;
  final bool isActive;
  final DateTime? createdAt;

  ShiftModel({
    this.id,
    required this.name,
    this.description,
    this.startTime,
    this.endTime,
    this.isActive = true,
    this.createdAt,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return ShiftModel(
      id: id ?? json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      startTime: json['startTime'],
      endTime: json['endTime'],
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
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
    };
  }

  ShiftModel copyWith({
    String? id,
    String? name,
    String? description,
    String? startTime,
    String? endTime,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ShiftModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
