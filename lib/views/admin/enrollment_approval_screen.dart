import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/enrollment_controller.dart';
import '../../controllers/course_controller.dart';
import '../../controllers/student_controller.dart';
import '../../models/enrollment_model.dart';
import '../../app/theme/app_theme.dart';
import '../../app/responsive/responsive_utils.dart';

class EnrollmentApprovalScreen extends StatefulWidget {
  const EnrollmentApprovalScreen({super.key});

  @override
  State<EnrollmentApprovalScreen> createState() =>
      _EnrollmentApprovalScreenState();
}

class _EnrollmentApprovalScreenState extends State<EnrollmentApprovalScreen> {
  final EnrollmentController _enrollmentController =
      Get.put(EnrollmentController());
  final CourseController _courseController = Get.put(CourseController());
  final StudentController _studentController = Get.put(StudentController());

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _enrollmentController.fetchAllEnrollments(),
      _courseController.fetchCourses(),
      _studentController.fetchAllStudents(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Enrollment Approvals'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Pending'),
                  Tab(text: 'Approved'),
                  Tab(text: 'Rejected'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildPendingEnrollmentsTab(),
                    _buildApprovedEnrollmentsTab(),
                    _buildRejectedEnrollmentsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingEnrollmentsTab() {
    return Obx(
      () {
        final pendingEnrollments = _enrollmentController.enrollments
            .where((e) => e.status == 'pending')
            .toList();

        if (pendingEnrollments.isEmpty) {
          return Center(
            child: Text(
              'No pending enrollments',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: ResponsiveUtils.responsivePadding(context),
          itemCount: pendingEnrollments.length,
          itemBuilder: (context, index) {
            final enrollment = pendingEnrollments[index];
            final student =
                _studentController.getStudentById(enrollment.studentId);
            final course = _courseController.getCourseById(enrollment.courseId);

            return Card(
              margin: EdgeInsets.only(
                bottom: ResponsiveUtils.responsiveSpacing(context, 12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.responsiveBorderRadius(context, 12),
                ),
              ),
              child: ListTile(
                title: Text(
                  student?.name ?? enrollment.studentId,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Course: ${course?.name ?? enrollment.courseId}'),
                    if (student?.email != null) Text('Email: ${student!.email}'),
                    if (enrollment.createdAt != null)
                      Text('Requested: ${_formatDate(enrollment.createdAt!)}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: const Text('Pending'),
                      backgroundColor: Colors.orange,
                      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () => _showApproveConfirmation(enrollment),
                      tooltip: 'Approve',
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => _showRejectConfirmation(enrollment),
                      tooltip: 'Reject',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildApprovedEnrollmentsTab() {
    return Obx(
      () {
        final approvedEnrollments = _enrollmentController.enrollments
            .where((e) => e.status == 'active')
            .toList();

        if (approvedEnrollments.isEmpty) {
          return Center(
            child: Text(
              'No approved enrollments',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: ResponsiveUtils.responsivePadding(context),
          itemCount: approvedEnrollments.length,
          itemBuilder: (context, index) {
            final enrollment = approvedEnrollments[index];
            final student =
                _studentController.getStudentById(enrollment.studentId);
            final course = _courseController.getCourseById(enrollment.courseId);

            return Card(
              margin: EdgeInsets.only(
                bottom: ResponsiveUtils.responsiveSpacing(context, 12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.responsiveBorderRadius(context, 12),
                ),
              ),
              child: ListTile(
                title: Text(
                  student?.name ?? enrollment.studentId,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Course: ${course?.name ?? enrollment.courseId}'),
                    if (student?.email != null) Text('Email: ${student!.email}'),
                    if (enrollment.createdAt != null)
                      Text('Enrolled: ${_formatDate(enrollment.createdAt!)}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: const Text('Approved'),
                      backgroundColor: Colors.green,
                      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation(enrollment),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRejectedEnrollmentsTab() {
    return Obx(
      () {
        final rejectedEnrollments = _enrollmentController.enrollments
            .where((e) => e.status == 'rejected')
            .toList();

        if (rejectedEnrollments.isEmpty) {
          return Center(
            child: Text(
              'No rejected enrollments',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: ResponsiveUtils.responsivePadding(context),
          itemCount: rejectedEnrollments.length,
          itemBuilder: (context, index) {
            final enrollment = rejectedEnrollments[index];
            final student =
                _studentController.getStudentById(enrollment.studentId);
            final course = _courseController.getCourseById(enrollment.courseId);

            return Card(
              margin: EdgeInsets.only(
                bottom: ResponsiveUtils.responsiveSpacing(context, 12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.responsiveBorderRadius(context, 12),
                ),
              ),
              child: ListTile(
                title: Text(
                  student?.name ?? enrollment.studentId,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Course: ${course?.name ?? enrollment.courseId}'),
                    if (student?.email != null) Text('Email: ${student!.email}'),
                    if (enrollment.createdAt != null)
                      Text('Requested: ${_formatDate(enrollment.createdAt!)}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: const Text('Rejected'),
                      backgroundColor: Colors.red,
                      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.blue),
                      onPressed: () => _showReconsiderConfirmation(enrollment),
                      tooltip: 'Reconsider',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation(enrollment),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showApproveConfirmation(EnrollmentModel enrollment) {
    final student = _studentController.getStudentById(enrollment.studentId);
    final course = _courseController.getCourseById(enrollment.courseId);

    Get.dialog(
      AlertDialog(
        title: const Text('Approve Enrollment'),
        content: Text(
            'Approve enrollment for ${student?.name ?? enrollment.studentId} in ${course?.name ?? enrollment.courseId}?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await _enrollmentController.approveEnrollment(
                enrollmentId: enrollment.id!,
              );
              if (success) {
                Get.snackbar(
                  'Success',
                  'Enrollment approved successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.successColor,
                  colorText: Colors.white,
                );
                await _loadData();
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to approve enrollment',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.errorColor,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectConfirmation(EnrollmentModel enrollment) {
    final student = _studentController.getStudentById(enrollment.studentId);
    final course = _courseController.getCourseById(enrollment.courseId);

    Get.dialog(
      AlertDialog(
        title: const Text('Reject Enrollment'),
        content: Text(
            'Reject enrollment for ${student?.name ?? enrollment.studentId} in ${course?.name ?? enrollment.courseId}?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await _enrollmentController.rejectEnrollment(
                enrollmentId: enrollment.id!,
              );
              if (success) {
                Get.snackbar(
                  'Success',
                  'Enrollment rejected',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.errorColor,
                  colorText: Colors.white,
                );
                await _loadData();
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to reject enrollment',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.errorColor,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showReconsiderConfirmation(EnrollmentModel enrollment) {
    final student = _studentController.getStudentById(enrollment.studentId);
    final course = _courseController.getCourseById(enrollment.courseId);

    Get.dialog(
      AlertDialog(
        title: const Text('Reconsider Enrollment'),
        content: Text(
            'Approve enrollment for ${student?.name ?? enrollment.studentId} in ${course?.name ?? enrollment.courseId}?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await _enrollmentController.approveEnrollment(
                enrollmentId: enrollment.id!,
              );
              if (success) {
                Get.snackbar(
                  'Success',
                  'Enrollment approved successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.successColor,
                  colorText: Colors.white,
                );
                await _loadData();
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to approve enrollment',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.errorColor,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(EnrollmentModel enrollment) {
    final student = _studentController.getStudentById(enrollment.studentId);
    final course = _courseController.getCourseById(enrollment.courseId);

    Get.dialog(
      AlertDialog(
        title: const Text('Delete Enrollment'),
        content: Text(
            'Delete enrollment for ${student?.name ?? enrollment.studentId} in ${course?.name ?? enrollment.courseId}?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await _enrollmentController.deleteEnrollment(
                enrollmentId: enrollment.id!,
              );
              if (success) {
                Get.snackbar(
                  'Success',
                  'Enrollment deleted successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.successColor,
                  colorText: Colors.white,
                );
                await _loadData();
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to delete enrollment',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.errorColor,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
