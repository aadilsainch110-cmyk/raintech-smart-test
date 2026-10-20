import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/course_controller.dart';
import '../../controllers/enrollment_controller.dart';
import '../../models/course_model.dart';
import '../../models/enrollment_model.dart';
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

  final Set<String> _enrollingCourseIds = {};

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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('My Courses'),
      ),
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
                        'Pending Enrollments',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
                      _buildPendingEnrollments(),
                      SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 24)),
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

  Widget _buildPendingEnrollments() {
    final pendingEnrollments = _enrollmentController.enrollments
        .where((e) => e.status == 'pending')
        .toList();
    final pendingCourseIds = pendingEnrollments.map((e) => e.courseId).toSet();
    final pendingCourses = _courseController.courses
        .where((course) => pendingCourseIds.contains(course.id))
        .toList();

    if (pendingCourses.isEmpty) {
      return _buildEmptyCard('No pending enrollments');
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
      itemCount: pendingCourses.length,
      itemBuilder: (context, index) {
        final course = pendingCourses[index];
        final enrollment = pendingEnrollments.firstWhere((e) => e.courseId == course.id);
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
                        Colors.orange.withValues(alpha: 0.8),
                        Colors.amber.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.responsiveBorderRadius(context, 8),
                    ),
                  ),
                  child: Icon(
                    Icons.pending,
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
                SizedBox(
                  width: double.infinity,
                  height: ResponsiveUtils.responsiveButtonHeight(context) * 0.7,
                  child: ElevatedButton(
                    onPressed: () => _showDeletePendingConfirmation(enrollment, course),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.responsiveBorderRadius(context, 8),
                        ),
                      ),
                    ),
                    child: const Text('Cancel Request'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnrolledCourses() {
    final enrolledEnrollments = _enrollmentController.enrollments
        .where((e) => e.status == 'active')
        .toList();
    final enrolledCourseIds = enrolledEnrollments
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
                    SizedBox(
                      width: double.infinity,
                      height: ResponsiveUtils.responsiveButtonHeight(context) * 0.7,
                      child: ElevatedButton(
                        onPressed: _enrollingCourseIds.contains(course.id)
                            ? null
                            : () => _showUnenrollConfirmation(course),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.AppTheme.successColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.responsiveBorderRadius(context, 8),
                            ),
                          ),
                        ),
                        child: _enrollingCourseIds.contains(course.id)
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Enrolled'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
  }

  Widget _buildAvailableCourses() {
    final allEnrolledCourseIds = _enrollmentController.enrollments
        .map((e) => e.courseId)
        .toSet();
    final availableCourses = _courseController.courses
        .where(
          (course) => !allEnrolledCourseIds.contains(course.id) && course.isActive,
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
                        onPressed: _enrollingCourseIds.contains(course.id)
                            ? null
                            : () => _handleEnroll(course),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.responsiveBorderRadius(context, 8),
                            ),
                          ),
                        ),
                        child: _enrollingCourseIds.contains(course.id)
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Enroll'),
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

  Future<void> _handleEnroll(CourseModel course) async {
    setState(() {
      _enrollingCourseIds.add(course.id!);
    });

    try {
      final success = await _enrollmentController.createEnrollment(
        studentId: _authController.currentUser!.id!,
        courseId: course.id!,
        shiftId: 'default',
      );

      if (success) {
        Get.snackbar(
          'Success',
          'Enrollment request sent. Once approved, tests for this course will be available.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        await _loadData();
      } else {
        Get.snackbar(
          'Error',
          'Unable to update enrollment. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: theme.AppTheme.errorColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to update enrollment. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.AppTheme.errorColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      setState(() {
        _enrollingCourseIds.remove(course.id!);
      });
    }
  }

  void _showUnenrollConfirmation(CourseModel course) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Unenroll from Course?'),
          content: const Text('Are you sure you want to unenroll from this course?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _handleUnenroll(course);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.AppTheme.errorColor,
              ),
              child: const Text('Unenroll'),
            ),
          ],
        );
      },
    );
  }

  void _showDeletePendingConfirmation(EnrollmentModel enrollment, CourseModel course) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Enrollment Request?'),
          content: Text('Are you sure you want to cancel your enrollment request for ${course.name}?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _handleDeletePending(enrollment);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.AppTheme.errorColor,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleDeletePending(EnrollmentModel enrollment) async {
    final success = await _enrollmentController.deleteEnrollment(
      enrollmentId: enrollment.id!,
    );

    if (success) {
      Get.snackbar(
        'Success',
        'Enrollment request cancelled successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.AppTheme.successColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      await _loadData();
    } else {
      Get.snackbar(
        'Error',
        'Unable to cancel enrollment request. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.AppTheme.errorColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _handleUnenroll(CourseModel course) async {
    setState(() {
      _enrollingCourseIds.add(course.id!);
    });

    try {
      final enrollment = _enrollmentController.getStudentEnrollmentByShift(
        studentId: _authController.currentUser!.id!,
        courseId: course.id!,
        shiftId: 'default',
      );

      if (enrollment != null) {
        final success = await _enrollmentController.deleteEnrollment(
          enrollmentId: enrollment.id!,
        );

        if (success) {
          Get.snackbar(
            'Success',
            'Successfully unenrolled from this course.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: theme.AppTheme.successColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          await _loadData();
        } else {
          Get.snackbar(
            'Error',
            'Unable to update enrollment. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: theme.AppTheme.errorColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Unable to update enrollment. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: theme.AppTheme.errorColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to update enrollment. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.AppTheme.errorColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      setState(() {
        _enrollingCourseIds.remove(course.id!);
      });
    }
  }
}
