import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/result_controller.dart';
import '../../controllers/test_controller.dart';
import '../../controllers/student_controller.dart';
import '../../services/pdf_service.dart';
import '../../services/csv_service.dart';
import '../../app/theme/app_theme.dart';

class TeacherResultsScreen extends StatefulWidget {
  const TeacherResultsScreen({super.key});

  @override
  State<TeacherResultsScreen> createState() => _TeacherResultsScreenState();
}

class _TeacherResultsScreenState extends State<TeacherResultsScreen> {
  final ResultController _resultController = Get.put(ResultController());
  final TestController _testController = Get.put(TestController());
  final StudentController _studentController = Get.put(StudentController());
  final PdfService _pdfService = PdfService();
  final CsvService _csvService = CsvService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _testController.fetchAllTests(),
      _studentController.fetchAllStudents(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Results')),
      body: Obx(
        () => _testController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : _testController.tests.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assessment_outlined,
                      size: 80,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No tests available',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _testController.tests.length,
                itemBuilder: (context, index) {
                  final test = _testController.tests[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text(test.title),
                      subtitle: Text(
                        '${test.questionCount} Questions • ${test.totalMarks} Marks',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (test.resultsReleased)
                            Chip(
                              label: const Text('Released'),
                              backgroundColor: AppTheme.successColor,
                              labelStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                      onTap: () async {
                        await _resultController.fetchTestResults(
                          testId: test.id!,
                        );
                        _showResultsDialog(test);
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showResultsDialog(dynamic test) {
    Get.dialog(
      AlertDialog(
        title: Text('${test.title} - Results'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Obx(
            () => _resultController.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : _resultController.results.isEmpty
                ? const Center(child: Text('No results yet'))
                : ListView.builder(
                    itemCount: _resultController.results.length,
                    itemBuilder: (context, index) {
                      final result = _resultController.results[index];
                      return ListTile(
                        title: Text('Student ${index + 1}'),
                        subtitle: Text(
                          '${result.obtainedMarks}/${result.totalMarks} (${result.percentage.toStringAsFixed(1)}%)',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (test.resultsReleased && result.position != null)
                              Text(
                                '${result.position}${_getOrdinalSuffix(result.position!)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(result.status),
                              backgroundColor: result.status == 'PASS'
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                              labelStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
          if (test.resultsReleased) ...[
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () => _exportToPdf(test),
              tooltip: 'Export to PDF',
            ),
            IconButton(
              icon: const Icon(Icons.table_chart),
              onPressed: () => _exportToCsv(test),
              tooltip: 'Export to CSV',
            ),
          ],
          if (!test.resultsReleased)
            ElevatedButton(
              onPressed: () async {
                Get.back();
                final confirmed = await Get.dialog<bool>(
                  AlertDialog(
                    title: const Text('Release Results'),
                    content: const Text(
                      'Are you sure you want to release results for this test?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        child: const Text('Release'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await _testController.releaseResults(testId: test.id!);
                  await _resultController.calculateRankings(testId: test.id!);
                  Get.snackbar(
                    'Success',
                    'Results released successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppTheme.successColor,
                    colorText: Colors.white,
                  );
                }
              },
              child: const Text('Release Results'),
            ),
        ],
      ),
    );
  }

  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) {
      return 'th';
    }
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  Future<void> _exportToPdf(dynamic test) async {
    try {
      await _pdfService.generateAllMarksheets(
        results: _resultController.results,
        students: _studentController.students,
        test: test,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to export PDF: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _exportToCsv(dynamic test) async {
    try {
      final resultsData = _resultController.results.map((result) {
        final student = _studentController.students
            .where((s) => s.id == result.studentId)
            .firstOrNull;
        return {
          'studentName': student?.name ?? 'Unknown',
          'email': student?.email ?? '',
          'studentId': student?.studentId ?? 'N/A',
          'obtainedMarks': result.obtainedMarks,
          'totalMarks': result.totalMarks,
          'percentage': result.percentage,
          'status': result.status,
          'position': result.position != null
              ? result.position.toString()
              : 'N/A',
          'submittedAt': result.submittedAt?.toIso8601String() ?? 'N/A',
        };
      }).toList();

      final filePath = await _csvService.exportResultsToCsv(resultsData);
      if (filePath != null) {
        Get.snackbar(
          'Success',
          'CSV exported successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.successColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to export CSV: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }
}
