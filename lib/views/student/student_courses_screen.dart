import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/course_controller.dart';
import '../../controllers/enrollment_controller.dart';
import '../../app/theme/app_theme.dart' as theme;
import '../../app/responsive/responsive_utils.dart';

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
                  padding: ResponsiveUtils.responsivePadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enrolled Courses',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
                      _buildEnrolledCourses(),
                      SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 24)),
                      Text(
                        'Available Courses',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
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

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveUtils.getGridColumns(context),
        childAspectRatio: ResponsiveUtils.isMobile(context) ? 1.2 : 1.3,
        crossAxisSpacing: ResponsiveUtils.responsiveSpacing(context, 12),
        mainAxisSpacing: ResponsiveUtils.responsiveSpacing(context, 12),
      ),
      itemCount: enrolledCourses.length,
          itemBuilder: (context, index) {
            final course = enrolledCourses[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.responsiveBorderRadius(context, 12),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(
                  ResponsiveUtils.responsiveSpacing(context, 12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.responsiveSpacing(context, 10),
                      ),
                      decoration: BoxDecoration(
                        gradient: theme.AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.responsiveBorderRadius(context, 8),
                        ),
                      ),
                      child: Icon(
                        Icons.menu_book,
                        color: Colors.white,
                        size: ResponsiveUtils.responsiveIconSize(context, 24),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 10)),
                    Text(
                      course.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (course.description != null) ...[
                      SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 4)),
                      Text(
                        course.description!,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.responsiveFontSize(context, 12),
                          color: theme.AppTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    Chip(
                      label: const Text('Enrolled'),
                      backgroundColor: theme.AppTheme.successColor,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  ],
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

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveUtils.getGridColumns(context),
        childAspectRatio: ResponsiveUtils.isMobile(context) ? 1.2 : 1.3,
        crossAxisSpacing: ResponsiveUtils.responsiveSpacing(context, 12),
        mainAxisSpacing: ResponsiveUtils.responsiveSpacing(context, 12),
      ),
      itemCount: availableCourses.length,
          itemBuilder: (context, index) {
            final course = availableCourses[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.responsiveBorderRadius(context, 12),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(
                  ResponsiveUtils.responsiveSpacing(context, 12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.responsiveSpacing(context, 10),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.AppTheme.primaryColor.withValues(alpha: 0.1),
                            theme.AppTheme.secondaryColor.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.responsiveBorderRadius(context, 8),
                        ),
                      ),
                      child: Icon(
                        Icons.menu_book,
                        color: theme.AppTheme.primaryColor,
                        size: ResponsiveUtils.responsiveIconSize(context, 24),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 10)),
                    Text(
                      course.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (course.description != null) ...[
                      SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 4)),
                      Text(
                        course.description!,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.responsiveFontSize(context, 12),
                          color: theme.AppTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: ResponsiveUtils.responsiveButtonHeight(context) * 0.7,
                      child: ElevatedButton(
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
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.responsiveBorderRadius(context, 8),
                            ),
                          ),
                        ),
                        child: const Text('Enroll'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
  }

  Widget _buildEmptyCard(String message) {
    return Builder(
      builder: (context) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.responsiveBorderRadius(context, 12),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(
            ResponsiveUtils.responsiveSpacing(context, 24),
          ),
          child: Center(
            child: Text(
              message,
              style: TextStyle(
                color: theme.AppTheme.textSecondary,
                fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
