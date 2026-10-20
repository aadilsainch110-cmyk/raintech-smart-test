import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/result_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/test_controller.dart';
import '../../controllers/course_controller.dart';
import '../../controllers/enrollment_controller.dart';
import '../../services/pdf_service.dart';
import '../../models/result_model.dart';
import '../../app/theme/app_theme.dart' as theme;
import '../../app/responsive/responsive_utils.dart';
import 'marksheet_preview_screen.dart';

class StudentResultsScreen extends StatefulWidget {
  const StudentResultsScreen({super.key});

  @override
  State<StudentResultsScreen> createState() => _StudentResultsScreenState();
}

class _StudentResultsScreenState extends State<StudentResultsScreen> {
  final ResultController _resultController = Get.put(ResultController());
  final AuthController _authController = Get.find<AuthController>();
  final TestController _testController = Get.put(TestController());
  final CourseController _courseController = Get.put(CourseController());
  final EnrollmentController _enrollmentController = Get.put(EnrollmentController());
  final PdfService _pdfService = PdfService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_authController.currentUser != null) {
      await _resultController.fetchStudentResults(
        studentId: _authController.currentUser!.id!,
      );

      // Fetch enrollments to filter tests
      await _enrollmentController.fetchStudentEnrollments(
        studentId: _authController.currentUser!.id!,
      );

      // Extract enrolled course IDs (only active enrollments)
      final enrolledCourseIds = _enrollmentController.enrollments
          .where((e) => e.status == 'active')
          .map((e) => e.courseId)
          .toSet()
          .toList();

      // Fetch tests only for enrolled courses
      if (enrolledCourseIds.isNotEmpty) {
        await _testController.fetchPublishedTestsByCourseIds(
          courseIds: enrolledCourseIds,
        );
      } else {
        // No enrolled courses - clear tests
        _testController.tests.clear();
      }
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
        title: const Text('My Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.description),
            onPressed: () => Get.toNamed('/overall-marksheet'),
            tooltip: 'Overall Marksheet',
          ),
        ],
      ),
      body: Obx(
        () => _resultController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : _resultController.results.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assessment_outlined,
                      size: ResponsiveUtils.responsiveIconSize(context, 80),
                      color: theme.AppTheme.textSecondary,
                    ),
                    SizedBox(
                      height: ResponsiveUtils.responsiveSpacing(context, 16),
                    ),
                    Text(
                      'No results yet',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          18,
                        ),
                        color: theme.AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                padding: ResponsiveUtils.responsivePadding(context),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveUtils.getGridColumns(context),
                  childAspectRatio: ResponsiveUtils.isMobile(context) ? 1.1 : 1.2,
                  crossAxisSpacing: ResponsiveUtils.responsiveSpacing(context, 12),
                  mainAxisSpacing: ResponsiveUtils.responsiveSpacing(context, 12),
                ),
                itemCount: _resultController.results.length,
                itemBuilder: (context, index) {
                  final result = _resultController.results[index];
                  final test = _testController.tests.firstWhereOrNull(
                    (t) => t.id == result.testId,
                  );
                  final testName = test?.title ?? 'Test ${index + 1}';
                  
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.responsiveSpacing(context, 12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  testName,
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveUtils.responsiveFontSize(
                                        context,
                                        15,
                                      ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: ResponsiveUtils.responsiveSpacing(context, 8)),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveUtils.responsiveSpacing(
                                    context,
                                    6,
                                  ),
                                  vertical: ResponsiveUtils.responsiveSpacing(
                                    context,
                                    3,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  color: result.status == 'PASS'
                                      ? theme.AppTheme.successColor
                                      : theme.AppTheme.errorColor,
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveUtils.responsiveBorderRadius(
                                      context,
                                      6,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  result.status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            '${result.obtainedMarks}/${result.totalMarks}',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.responsiveFontSize(
                                context,
                                18,
                              ),
                              fontWeight: FontWeight.bold,
                              color: theme.AppTheme.primaryColor,
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveUtils.responsiveSpacing(
                              context,
                              6,
                            ),
                          ),
                          Text(
                            '${result.percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.responsiveFontSize(
                                context,
                                13,
                              ),
                              color: theme.AppTheme.textSecondary,
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveUtils.responsiveSpacing(
                              context,
                              6,
                            ),
                          ),
                          Text(
                            '✓ ${result.correctAnswers} | ✗ ${result.wrongAnswers}',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.responsiveFontSize(
                                context,
                                11,
                              ),
                              color: theme.AppTheme.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: ResponsiveUtils.responsiveButtonHeight(context) * 0.65,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _viewMarksheet(result),
                                    icon: const Icon(Icons.visibility, size: 14),
                                    label: const Text('View', style: TextStyle(fontSize: 11)),
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: ResponsiveUtils.responsiveSpacing(context, 6),
                                        vertical: ResponsiveUtils.responsiveSpacing(context, 6),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: ResponsiveUtils.responsiveSpacing(context, 8)),
                              Expanded(
                                child: SizedBox(
                                  height: ResponsiveUtils.responsiveButtonHeight(context) * 0.65,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _downloadMarksheet(result),
                                    icon: const Icon(Icons.download, size: 14),
                                    label: const Text('PDF', style: TextStyle(fontSize: 11)),
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: ResponsiveUtils.responsiveSpacing(context, 6),
                                        vertical: ResponsiveUtils.responsiveSpacing(context, 6),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _viewMarksheet(ResultModel result) async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Get test data (already fetched in initState)
      final test = _testController.tests.firstWhereOrNull(
        (t) => t.id == result.testId,
      );

      if (test == null) {
        Get.back();
        Get.snackbar(
          'Error',
          'Test data not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: theme.AppTheme.errorColor,
          colorText: Colors.white,
        );
        return;
      }

      // Fetch course data
      await _courseController.fetchCourses();
      final course = _courseController.courses.firstWhereOrNull(
        (c) => c.id == test.courseId,
      );

      // Close loading dialog
      Get.back();

      // Navigate to marksheet preview
      Get.to(
        () => MarksheetPreviewScreen(
          result: result,
          student: _authController.currentUser!,
          test: test,
          course: course,
        ),
      );
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to load marksheet: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _downloadMarksheet(ResultModel result) async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Get test data (already fetched in initState)
      final test = _testController.tests.firstWhereOrNull(
        (t) => t.id == result.testId,
      );

      if (test == null) {
        Get.back();
        Get.snackbar(
          'Error',
          'Test data not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: theme.AppTheme.errorColor,
          colorText: Colors.white,
        );
        return;
      }

      await _courseController.fetchCourses();
      final course = _courseController.courses.firstWhereOrNull(
        (c) => c.id == test.courseId,
      );

      // Close loading dialog
      Get.back();

      // Generate marksheet
      await _pdfService.generateMarksheet(
        result: result,
        student: _authController.currentUser!,
        test: test,
        course: course,
      );

      // Show success message
      Get.snackbar(
        'Success',
        'Marksheet generated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.AppTheme.successColor,
        colorText: Colors.white,
      );
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to generate marksheet: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }
}
