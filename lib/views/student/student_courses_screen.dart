import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/course_controller.dart';
import '../../controllers/enrollment_controller.dart';
import '../../app/theme/app_theme.dart' as theme;

class StudentCoursesScreen extends StatefulWidget {
  const StudentCoursesScreen({super.key});

  @override
  State<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends State<StudentCoursesScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final CourseController _courseController = Get.put(CourseController());
  final EnrollmentController _enrollmentController = Get.put(
    EnrollmentController(),
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_authController.currentUser != null) {
      await Future.wait([
        _courseController.fetchCourses(),
        _enrollmentController.fetchStudentEnrollments(
          studentId: _authController.currentUser!.id!,
        ),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Courses')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Obx(
          () =>
              _courseController.isLoading.value ||
                  _enrollmentController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enrolled Courses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildEnrolledCourses(),
                      const SizedBox(height: 24),
                      const Text(
                        'Available Courses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildAvailableCourses(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildEnrolledCourses() {
    final enrolledCourseIds = _enrollmentController.enrollments
        .map((e) => e.courseId)
        .toSet();
    final enrolledCourses = _courseController.courses
        .where((course) => enrolledCourseIds.contains(course.id))
        .toList();

    if (enrolledCourses.isEmpty) {
      return _buildEmptyCard('No courses enrolled yet');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: enrolledCourses.length,
      itemBuilder: (context, index) {
        final course = enrolledCourses[index];
        final enrollment = _enrollmentController.enrollments.firstWhere(
          (e) => e.courseId == course.id,
        );
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              course.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (course.description != null) Text(course.description!),
                Text('Shift: ${enrollment.shiftId}'),
              ],
            ),
            trailing: Chip(
              label: const Text('Enrolled'),
              backgroundColor: theme.AppTheme.successColor,
              labelStyle: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvailableCourses() {
    final enrolledCourseIds = _enrollmentController.enrollments
        .map((e) => e.courseId)
        .toSet();
    final availableCourses = _courseController.courses
        .where(
          (course) => !enrolledCourseIds.contains(course.id) && course.isActive,
        )
        .toList();

    if (availableCourses.isEmpty) {
      return _buildEmptyCard('No new courses available');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: availableCourses.length,
      itemBuilder: (context, index) {
        final course = availableCourses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              course.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: course.description != null
                ? Text(course.description!)
                : null,
            trailing: ElevatedButton(
              onPressed: () async {
                final success = await _enrollmentController.createEnrollment(
                  studentId: _authController.currentUser!.id!,
                  courseId: course.id!,
                  shiftId: 'default',
                );
                if (success) {
                  Get.snackbar(
                    'Success',
                    'Enrolled in ${course.name}',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: theme.AppTheme.successColor,
                    colorText: Colors.white,
                  );
                  _loadData();
                }
              },
              child: const Text('Enroll'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            message,
            style: const TextStyle(color: theme.AppTheme.textSecondary),
          ),
        ),
      ),
    );
  }
}
