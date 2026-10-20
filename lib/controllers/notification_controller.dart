import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../controllers/auth_controller.dart';
import '../controllers/enrollment_controller.dart';

class NotificationController extends GetxController {
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxList<NotificationModel> studentNotifications = <NotificationModel>[].obs;
  late final AuthController _authController;
  late final EnrollmentController _enrollmentController;

  @override
  void onInit() {
    super.onInit();
    _authController = Get.find<AuthController>();
    _enrollmentController = Get.put(EnrollmentController());
    _loadNotifications();
    _loadStudentEnrollments();
    // Listen to enrollment changes to update filtered notifications
    ever(_enrollmentController.enrollments, (_) => _updateStudentNotifications());
  }

  Future<void> _loadStudentEnrollments() async {
    if (_authController.currentUser?.role == 'student') {
      final studentId = _authController.currentUser?.id;
      if (studentId != null) {
        await _enrollmentController.fetchStudentEnrollments(studentId: studentId);
        // Refresh notifications after enrollments are loaded to apply filtering
        notifications.refresh();
      }
    }
  }

  // Method to reload notifications after enrollment changes
  Future<void> refreshNotifications() async {
    await _loadStudentEnrollments();
    notifications.refresh();
  }

  // Update filtered notifications when enrollments change
  void _updateStudentNotifications() {
    studentNotifications.value = _filterStudentNotifications();
  }

  // Get current student's enrolled course IDs (reactive)
  List<String> get _studentCourseIds {
    if (_authController.currentUser?.role != 'student') {
      return [];
    }
    final studentId = _authController.currentUser?.id;
    if (studentId == null) return [];

    // Use RxList to make it reactive
    return _enrollmentController.enrollments
        .where((e) => e.studentId == studentId && e.status == 'active')
        .map((e) => e.courseId)
        .toList();
  }

  // Filtering logic extracted to a separate method
  List<NotificationModel> _filterStudentNotifications() {
    final currentUserId = _authController.currentUser?.id;
    final enrolledCourseIds = _studentCourseIds;

    return notifications.where((n) {
      // Automatic notifications (test, result) are filtered by course
      if (n.senderRole == 'automatic') {
        // Show if notification targets a course the student is enrolled in
        if (n.targetCourseId != null) {
          return enrolledCourseIds.contains(n.targetCourseId);
        }
        // If no course specified, don't show automatic notifications
        return false;
      }

      // Admin and Teacher notifications
      if (n.senderRole == 'admin' || n.senderRole == 'teacher') {
        // Show if it's a global announcement
        if (n.isGlobal) {
          return true;
        }

        // Show if it targets the specific student
        if (n.targetStudentId != null && n.targetStudentId == currentUserId) {
          return true;
        }

        // Show if it targets a course the student is enrolled in
        if (n.targetCourseId != null) {
          return enrolledCourseIds.contains(n.targetCourseId);
        }

        // Account approval notifications without specific targeting should be shown
        if (n.notificationType == 'approval' && n.targetStudentId == null) {
          return true;
        }

        // If no specific targeting, don't show (prevents showing all notifications)
        return false;
      }

      return false;
    }).toList();
  }

  void _loadNotifications() {
    notifications.value = [
      // Biology course notification (course ID: bio123)
      NotificationModel(
        id: '1',
        title: 'New Test Available',
        message: 'Biology Chapter 5 test is now available for you to attempt.',
        fullMessage: 'Biology Chapter 5 test is now available for you to attempt.\n\nTest Details:\n• Subject: Biology\n• Chapter: 5 - Cell Division\n• Duration: 60 minutes\n• Total Marks: 100\n• Passing Marks: 50\n\nPlease attempt the test before the deadline.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        icon: Icons.quiz,
        senderRole: 'automatic',
        notificationType: 'test',
        targetCourseId: 'bio123',
      ),
      // App Development course notification (course ID: app456)
      NotificationModel(
        id: '2',
        title: 'Test Starting Soon',
        message: 'Flutter test will start in 15 minutes.',
        fullMessage: 'Flutter test will start in 15 minutes.\n\nTest Information:\n• Test: Flutter Widgets\n• Start Time: 2:30 PM\n• Duration: 60 minutes\n\nMake sure you are ready to start the test.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        icon: Icons.alarm,
        senderRole: 'automatic',
        notificationType: 'test',
        targetCourseId: 'app456',
      ),
      // CIT course notification (course ID: cit789)
      NotificationModel(
        id: '3',
        title: 'Result Released',
        message: 'Your result for CIT test has been published.',
        fullMessage: 'Your result for CIT test has been published.\n\nResult Summary:\n• Test: CIT Fundamentals\n• Your Score: 78/100\n• Percentage: 78%\n• Status: Passed\n\nView your detailed results in the Results section.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        icon: Icons.assessment,
        senderRole: 'automatic',
        notificationType: 'result',
        targetCourseId: 'cit789',
      ),
      // Global Admin approval (no course targeting, isGlobal)
      NotificationModel(
        id: '4',
        title: 'Account Approved',
        message: 'Your account has been approved by Admin. You can now access all features.',
        fullMessage: 'Your account has been approved by Admin. You can now access all features.\n\n• Your account is now active\n• You can attempt tests\n• You can view results\n• You can access courses\n\nWelcome to RAINTECH Smart Test!',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        icon: Icons.check_circle,
        senderRole: 'admin',
        notificationType: 'approval',
        isGlobal: true,
      ),
      // Teacher announcement for Biology (course ID: bio123)
      NotificationModel(
        id: '5',
        title: 'Teacher Announcement',
        message: 'Important: Class schedule change for Biology',
        fullMessage: 'Important: Class schedule change for Biology\n\nDear Students,\n\nThe Biology class scheduled for Friday has been moved to Saturday at 10 AM. Please update your schedules accordingly.\n\nInstructor: Dr. Smith\nDepartment: Science',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        icon: Icons.announcement,
        senderRole: 'teacher',
        notificationType: 'announcement',
        targetCourseId: 'bio123',
      ),
      // Global Admin announcement (isGlobal, no course targeting)
      NotificationModel(
        id: '6',
        title: 'Admin Announcement',
        message: 'Holiday Notice: College closed on Monday',
        fullMessage: 'Holiday Notice: College closed on Monday\n\nDear Students,\n\nThe college will remain closed on Monday due to maintenance. Classes will resume on Tuesday as per the regular schedule.\n\nAdministration',
        timestamp: DateTime.now().subtract(const Duration(days: 4)),
        icon: Icons.announcement,
        senderRole: 'admin',
        notificationType: 'announcement',
        isGlobal: true,
      ),
    ];
    // Initialize filtered notifications
    _updateStudentNotifications();
  }

  int get unreadCount {
    return notifications.where((n) => !n.isRead).length;
  }

  int get studentUnreadCount {
    return studentNotifications.where((n) => !n.isRead).length;
  }

  void markAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      notifications.refresh();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }
    notifications.refresh();
  }

  void addNotification(NotificationModel notification) {
    notifications.insert(0, notification);
    _updateStudentNotifications();
  }

  // Notification methods for specific events
  void addNewTestNotification(String testName, String courseName, DateTime testDate, {String? courseId}) {
    addNotification(NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Test Available',
      message: '$testName is now available for $courseName.',
      fullMessage: '$testName is now available for $courseName.\n\nTest Details:\n• Test: $testName\n• Course: $courseName\n• Date: ${testDate.day}/${testDate.month}/${testDate.year}\n\nPlease attempt the test before the deadline.',
      timestamp: DateTime.now(),
      icon: Icons.quiz,
      senderRole: 'automatic',
      notificationType: 'test',
      targetCourseId: courseId,
    ));
  }

  void addTestStartingSoonNotification(String testName, DateTime startTime, {String? courseId}) {
    addNotification(NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Test Starting Soon',
      message: '$testName will start in 15 minutes.',
      fullMessage: '$testName will start in 15 minutes.\n\nTest Information:\n• Test: $testName\n• Start Time: ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}\n\nMake sure you are ready to start the test.',
      timestamp: DateTime.now(),
      icon: Icons.alarm,
      senderRole: 'automatic',
      notificationType: 'test',
      targetCourseId: courseId,
    ));
  }

  void addResultReleasedNotification(String testName, int score, int totalMarks, {String? courseId}) {
    final percentage = ((score / totalMarks) * 100).toInt();
    addNotification(NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Result Released',
      message: 'Your result for $testName has been published.',
      fullMessage: 'Your result for $testName has been published.\n\nResult Summary:\n• Test: $testName\n• Your Score: $score/$totalMarks\n• Percentage: $percentage%\n\nView your detailed results in the Results section.',
      timestamp: DateTime.now(),
      icon: Icons.assessment,
      senderRole: 'automatic',
      notificationType: 'result',
      targetCourseId: courseId,
    ));
  }

  void addAdminApprovedNotification({String? targetStudentId}) {
    addNotification(NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Account Approved',
      message: 'Your account has been approved by Admin. You can now access all features.',
      fullMessage: 'Your account has been approved by Admin. You can now access all features.\n\n• Your account is now active\n• You can attempt tests\n• You can view results\n• You can access courses\n\nWelcome to RAINTECH Smart Test!',
      timestamp: DateTime.now(),
      icon: Icons.check_circle,
      senderRole: 'admin',
      notificationType: 'approval',
      targetStudentId: targetStudentId,
      isGlobal: targetStudentId == null,
    ));
  }

  void addTeacherAnnouncementNotification(String title, String message, {String? courseId}) {
    addNotification(NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Teacher Announcement',
      message: title,
      fullMessage: '$title\n\n$message\n\nThis announcement is from your teacher. Please read it carefully.',
      timestamp: DateTime.now(),
      icon: Icons.announcement,
      senderRole: 'teacher',
      notificationType: 'announcement',
      targetCourseId: courseId,
    ));
  }

  // Method for Admin to send general announcements
  void addAdminAnnouncementNotification(String title, String message, {String? courseId, bool isGlobal = true}) {
    addNotification(NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      fullMessage: '$title\n\n$message\n\nThis announcement is from the Admin.',
      timestamp: DateTime.now(),
      icon: Icons.announcement,
      senderRole: 'admin',
      notificationType: 'announcement',
      targetCourseId: courseId,
      isGlobal: isGlobal,
    ));
  }
}
