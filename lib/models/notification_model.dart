import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String? fullMessage;
  final DateTime timestamp;
  final bool isRead;
  final IconData icon;
  final String? senderRole; // 'admin', 'teacher', 'automatic'
  final String? notificationType; // 'announcement', 'test', 'result', 'approval'
  final String? targetCourseId; // Course ID this notification is targeting
  final String? targetStudentId; // Specific student ID this notification is for
  final bool isGlobal; // If true, notification is for all students regardless of course

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.fullMessage,
    required this.timestamp,
    this.isRead = false,
    required this.icon,
    this.senderRole,
    this.notificationType,
    this.targetCourseId,
    this.targetStudentId,
    this.isGlobal = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json, {String? id}) {
    IconData getIconFromString(String? iconString) {
      switch (iconString) {
        case 'quiz':
          return Icons.quiz;
        case 'alarm':
          return Icons.alarm;
        case 'assessment':
          return Icons.assessment;
        case 'check_circle':
          return Icons.check_circle;
        case 'announcement':
          return Icons.announcement;
        default:
          return Icons.notifications;
      }
    }

    return NotificationModel(
      id: id ?? json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      fullMessage: json['fullMessage'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      icon: getIconFromString(json['icon']),
      senderRole: json['senderRole'],
      notificationType: json['notificationType'],
      targetCourseId: json['targetCourseId'],
      targetStudentId: json['targetStudentId'],
      isGlobal: json['isGlobal'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    String getIconString(IconData icon) {
      if (icon == Icons.quiz) return 'quiz';
      if (icon == Icons.alarm) return 'alarm';
      if (icon == Icons.assessment) return 'assessment';
      if (icon == Icons.check_circle) return 'check_circle';
      if (icon == Icons.announcement) return 'announcement';
      return 'notifications';
    }

    return {
      'id': id,
      'title': title,
      'message': message,
      if (fullMessage != null) 'fullMessage': fullMessage,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'icon': getIconString(icon),
      if (senderRole != null) 'senderRole': senderRole,
      if (notificationType != null) 'notificationType': notificationType,
      if (targetCourseId != null) 'targetCourseId': targetCourseId,
      if (targetStudentId != null) 'targetStudentId': targetStudentId,
      'isGlobal': isGlobal,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? fullMessage,
    DateTime? timestamp,
    bool? isRead,
    IconData? icon,
    String? senderRole,
    String? notificationType,
    String? targetCourseId,
    String? targetStudentId,
    bool? isGlobal,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      fullMessage: fullMessage ?? this.fullMessage,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      icon: icon ?? this.icon,
      senderRole: senderRole ?? this.senderRole,
      notificationType: notificationType ?? this.notificationType,
      targetCourseId: targetCourseId ?? this.targetCourseId,
      targetStudentId: targetStudentId ?? this.targetStudentId,
      isGlobal: isGlobal ?? this.isGlobal,
    );
  }
}
