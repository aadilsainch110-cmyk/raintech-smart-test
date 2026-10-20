import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/result_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/test_controller.dart';
import '../../controllers/course_controller.dart';
import '../../services/pdf_service.dart';
import '../../app/theme/app_theme.dart' as theme;

class OverallMarksheetScreen extends StatefulWidget {
  const OverallMarksheetScreen({super.key});

  @override
  State<OverallMarksheetScreen> createState() => _OverallMarksheetScreenState();
}

class _OverallMarksheetScreenState extends State<OverallMarksheetScreen> {
  final ResultController _resultController = Get.put(ResultController());
  final AuthController _authController = Get.find<AuthController>();
  final TestController _testController = Get.put(TestController());
  final CourseController _courseController = Get.put(CourseController());
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
        title: const Text('Overall Marksheet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadOverallMarksheet,
            tooltip: 'Download Marksheet',
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
                      Icons.description_outlined,
                      size: 80,
                      color: theme.AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No results yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: theme.AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStudentInfo(),
                    const SizedBox(height: 24),
                    _buildPerformanceSummary(),
                    const SizedBox(height: 24),
                    _buildResultsTable(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStudentInfo() {
    final student = _authController.currentUser;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Student Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Name', student?.name ?? 'N/A'),
            _buildInfoRow('Email', student?.email ?? 'N/A'),
            _buildInfoRow('Student ID', student?.studentId ?? 'N/A'),
            _buildInfoRow('Phone', student?.phone ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: theme.AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummary() {
    final performance = _resultController.getOverallPerformance(
      studentId: _authController.currentUser!.id!,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Tests Attempted',
                    performance['testsAttempted'].toString(),
                    Icons.quiz,
                    theme.AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Average %',
                    '${performance['averagePercentage'].toStringAsFixed(1)}%',
                    Icons.trending_up,
                    theme.AppTheme.successColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Passed',
                    performance['passedTests'].toString(),
                    Icons.check_circle,
                    theme.AppTheme.successColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Failed',
                    performance['failedTests'].toString(),
                    Icons.cancel,
                    theme.AppTheme.errorColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Marks',
                    performance['totalMarks'].toString(),
                    Icons.star,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Obtained',
                    performance['obtainedMarks'].toString(),
                    Icons.emoji_events,
                    theme.AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: theme.AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(color: Colors.grey[300]!, width: 1),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
              },
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: theme.AppTheme.primaryColor),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        '#',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Test',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Marks',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        '%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Status',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                ..._resultController.results.asMap().entries.map((entry) {
                  final index = entry.key;
                  final result = entry.value;
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('${index + 1}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('Test ${index + 1}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          '${result.obtainedMarks}/${result.totalMarks}',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(result.percentage.toStringAsFixed(1)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: result.status == 'PASS'
                                ? theme.AppTheme.successColor
                                : theme.AppTheme.errorColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            result.status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadOverallMarksheet() async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // For overall marksheet, generate individual PDFs for each result
      for (final result in _resultController.results) {
        // Fetch test for this result
        await _testController.fetchAllTests();
        final test = _testController.tests.firstWhereOrNull(
          (t) => t.id == result.testId,
        );

        if (test != null) {
          // Fetch course for this test
          await _courseController.fetchCourses();
          final course = _courseController.courses.firstWhereOrNull(
            (c) => c.id == test.courseId,
          );

          // Generate PDF for this result
          await _pdfService.generateMarksheet(
            result: result,
            student: _authController.currentUser!,
            test: test,
            course: course,
          );
        }
      }

      // Close loading dialog
      Get.back();

      // Show success message
      Get.snackbar(
        'Success',
        'Overall marksheet PDFs downloaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
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
        'Failed to download marksheet: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }
}
