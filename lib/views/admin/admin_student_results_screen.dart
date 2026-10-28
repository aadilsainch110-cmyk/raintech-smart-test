import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/result_controller.dart';
import '../../controllers/test_controller.dart';
import '../../controllers/course_controller.dart';
import '../../controllers/student_controller.dart';
import '../../models/result_model.dart';
import '../../models/test_model.dart';
import '../../services/pdf_service.dart';
import '../../app/theme/app_theme.dart' as theme;
import '../../app/responsive/responsive_utils.dart';
import '../../views/student/marksheet_preview_screen.dart';

class AdminStudentResultsScreen extends StatefulWidget {
  const AdminStudentResultsScreen({super.key});

  @override
  State<AdminStudentResultsScreen> createState() => _AdminStudentResultsScreenState();
}

class _AdminStudentResultsScreenState extends State<AdminStudentResultsScreen> {
  final ResultController _resultController = Get.put(ResultController());
  final TestController _testController = Get.put(TestController());
  final CourseController _courseController = Get.put(CourseController());
  final StudentController _studentController = Get.put(StudentController());

  final TextEditingController _searchController = TextEditingController();
  String _selectedCourse = 'All Courses';
  String _selectedTest = 'All Tests';
  String _selectedStatus = 'All Status';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _resultController.fetchAllResults(),
      _testController.fetchAllTests(),
      _courseController.fetchCourses(),
      _studentController.fetchAllStudents(),
    ]);
  }

  List<ResultModel> get _filteredResults {
    var results = _resultController.results.toList();

    // Search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      results = results.where((result) {
        final student = _studentController.students.firstWhereOrNull(
          (s) => s.id == result.studentId,
        );
        if (student == null) return false;
        return student.name.toLowerCase().contains(query) ||
            student.email.toLowerCase().contains(query) ||
            (student.studentId?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Course filter
    if (_selectedCourse != 'All Courses') {
      final course = _courseController.courses.firstWhereOrNull(
        (c) => c.name == _selectedCourse,
      );
      if (course != null) {
        final courseTests = _testController.tests
            .where((t) => t.courseId == course.id)
            .map((t) => t.id)
            .toSet();
        results = results.where((r) => courseTests.contains(r.testId)).toList();
      }
    }

    // Test filter
    if (_selectedTest != 'All Tests') {
      final test = _testController.tests.firstWhereOrNull(
        (t) => t.title == _selectedTest,
      );
      if (test != null) {
        results = results.where((r) => r.testId == test.id).toList();
      }
    }

    // Status filter
    if (_selectedStatus != 'All Status') {
      results = results.where((r) => r.status == _selectedStatus).toList();
    }

    return results;
  }

  List<String> get _courseNames {
    return ['All Courses', ..._courseController.courses.map((c) => c.name)];
  }

  List<String> get _testNames {
    return ['All Tests', ..._testController.tests.map((t) => t.title)];
  }

  List<String> get _statusOptions {
    return ['All Status', 'PASS', 'FAIL'];
  }

  Future<void> _viewMarksheet(ResultModel result) async {
    final student = _studentController.students.firstWhereOrNull(
      (s) => s.id == result.studentId,
    );
    final test = _testController.tests.firstWhereOrNull(
      (t) => t.id == result.testId,
    );

    if (student == null || test == null) {
      Get.snackbar(
        'Error',
        'Student or test data not found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.AppTheme.errorColor,
        colorText: Colors.white,
      );
      return;
    }

    final course = _courseController.courses.firstWhereOrNull(
      (c) => c.id == test.courseId,
    );

    await Get.to(
      () => MarksheetPreviewScreen(
        result: result,
        student: student,
        test: test,
        course: course,
      ),
    );
  }

  Future<void> _downloadMarksheet(ResultModel result) async {
    final student = _studentController.students.firstWhereOrNull(
      (s) => s.id == result.studentId,
    );
    final test = _testController.tests.firstWhereOrNull(
      (t) => t.id == result.testId,
    );

    if (student == null || test == null) {
      Get.snackbar(
        'Error',
        'Student or test data not found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.AppTheme.errorColor,
        colorText: Colors.white,
      );
      return;
    }

    final course = _courseController.courses.firstWhereOrNull(
      (c) => c.id == test.courseId,
    );

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final pdfService = PdfService();
      await pdfService.generateMarksheet(
        result: result,
        student: student,
        test: test,
        course: course,
      );

      Get.back();

      Get.snackbar(
        'Success',
        'Marksheet PDF downloaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Failed to download marksheet: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _downloadAllMarksheets() async {
    final filteredResults = _filteredResults;

    if (filteredResults.isEmpty) {
      Get.snackbar(
        'Info',
        'No results to download',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Download All Marksheets'),
        content: Text('Download ${filteredResults.length} marksheet(s)?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.AppTheme.primaryColor,
            ),
            child: const Text('Download', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    int successCount = 0;
    int failCount = 0;

    final pdfService = PdfService();

    for (final result in filteredResults) {
      final student = _studentController.students.firstWhereOrNull(
        (s) => s.id == result.studentId,
      );
      final test = _testController.tests.firstWhereOrNull(
        (t) => t.id == result.testId,
      );

      if (student == null || test == null) {
        failCount++;
        continue;
      }

      final course = _courseController.courses.firstWhereOrNull(
        (c) => c.id == test.courseId,
      );

      try {
        await pdfService.generateMarksheet(
          result: result,
          student: student,
          test: test,
          course: course,
        );
        successCount++;
      } catch (e) {
        failCount++;
      }
    }

    Get.back();

    Get.snackbar(
      'Download Complete',
      'Success: $successCount, Failed: $failCount',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: failCount > 0 ? Colors.orange : Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> _downloadRainTECHTestPDF(TestModel test) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Fetch results for this test
      await _resultController.fetchTestResults(testId: test.id!);

      final course = _courseController.courses.firstWhereOrNull(
        (c) => c.id == test.courseId,
      );

      final pdfService = PdfService();
      await pdfService.generateTestResultPDF(
        testId: test.id!,
        testName: test.title,
        courseName: course?.name ?? 'N/A',
        shiftName: 'All Shifts',
        testDate: test.createdAt ?? DateTime.now(),
        totalMarks: test.totalMarks,
        passingMarks: test.passingMarks,
        results: _resultController.results.toList(),
        students: _studentController.students.toList(),
      );

      Get.back();

      Get.snackbar(
        'Success',
        'PDF downloaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Failed to download PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Results'),
        actions: [
          if (_selectedTest != 'All Tests')
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () {
                final test = _testController.tests.firstWhereOrNull(
                  (t) => t.title == _selectedTest,
                );
                if (test != null) {
                  _downloadRainTECHTestPDF(test);
                }
              },
              tooltip: 'Download Test PDF',
            ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _downloadAllMarksheets,
            tooltip: 'Download All',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.responsiveSpacing(context, 16)),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, or Student ID',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.responsiveSpacing(context, 16),
                      vertical: ResponsiveUtils.responsiveSpacing(context, 12),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 12)),
                // Filters Row
                ResponsiveUtils.isMobile(context)
                    ? Column(
                        children: [
                          _buildFilterDropdown(
                            'Course',
                            _courseNames,
                            _selectedCourse,
                            (value) => setState(() => _selectedCourse = value),
                          ),
                          SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 8)),
                          _buildFilterDropdown(
                            'Test',
                            _testNames,
                            _selectedTest,
                            (value) => setState(() => _selectedTest = value),
                          ),
                          SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 8)),
                          _buildFilterDropdown(
                            'Status',
                            _statusOptions,
                            _selectedStatus,
                            (value) => setState(() => _selectedStatus = value),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _buildFilterDropdown(
                              'Course',
                              _courseNames,
                              _selectedCourse,
                              (value) => setState(() => _selectedCourse = value),
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.responsiveSpacing(context, 12)),
                          Expanded(
                            child: _buildFilterDropdown(
                              'Test',
                              _testNames,
                              _selectedTest,
                              (value) => setState(() => _selectedTest = value),
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.responsiveSpacing(context, 12)),
                          Expanded(
                            child: _buildFilterDropdown(
                              'Status',
                              _statusOptions,
                              _selectedStatus,
                              (value) => setState(() => _selectedStatus = value),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
          // Results List
          Expanded(
            child: Obx(() {
              if (_resultController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredResults = _filteredResults;

              if (filteredResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assessment_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No results found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(ResponsiveUtils.responsiveSpacing(context, 16)),
                itemCount: filteredResults.length,
                itemBuilder: (context, index) {
                  final result = filteredResults[index];
                  final student = _studentController.students.firstWhereOrNull(
                    (s) => s.id == result.studentId,
                  );
                  final test = _testController.tests.firstWhereOrNull(
                    (t) => t.id == result.testId,
                  );
                  final course = test != null
                      ? _courseController.courses.firstWhereOrNull(
                          (c) => c.id == test.courseId,
                        )
                      : null;

                  return Card(
                    margin: EdgeInsets.only(
                      bottom: ResponsiveUtils.responsiveSpacing(context, 12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      title: Text(
                        student?.name ?? 'Unknown Student',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(student?.email ?? ''),
                          if (student?.studentId != null)
                            Text('Student ID: ${student!.studentId}'),
                          Text('Course: ${course?.name ?? 'N/A'}'),
                          Text('Test: ${test?.title ?? 'N/A'}'),
                          Text(
                            'Submitted: ${result.submittedAt != null ? _formatDate(result.submittedAt!) : 'N/A'}',
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${result.obtainedMarks}/${result.totalMarks}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${result.percentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: result.status == 'PASS'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(result.status),
                            backgroundColor:
                                result.status == 'PASS' ? Colors.green : Colors.red,
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.download, color: Colors.blue),
                            onPressed: () => _downloadMarksheet(result),
                            tooltip: 'Download PDF',
                          ),
                        ],
                      ),
                      onTap: () => _viewMarksheet(result),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    List<String> options,
    String selectedValue,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: selectedValue,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
