import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/result_controller.dart';
import '../../controllers/test_controller.dart';
import '../../controllers/student_controller.dart';
import '../../controllers/course_controller.dart';
import '../../controllers/shift_controller.dart';
import '../../controllers/class_controller.dart';
import '../../services/pdf_service.dart';
import '../../app/theme/app_theme.dart';
import '../../models/course_model.dart';
import '../../models/shift_model.dart';
import '../../models/class_model.dart';
import '../../models/test_model.dart';
import '../../models/result_model.dart';
import '../../models/user_model.dart';

class AllStudentsResultsScreen extends StatefulWidget {
  const AllStudentsResultsScreen({super.key});

  @override
  State<AllStudentsResultsScreen> createState() => _AllStudentsResultsScreenState();
}

class _AllStudentsResultsScreenState extends State<AllStudentsResultsScreen> {
  final ResultController _resultController = Get.put(ResultController());
  final TestController _testController = Get.put(TestController());
  final StudentController _studentController = Get.put(StudentController());
  final CourseController _courseController = Get.put(CourseController());
  final ShiftController _shiftController = Get.put(ShiftController());
  final ClassController _classController = Get.put(ClassController());
  final PdfService _pdfService = PdfService();

  String? _selectedCourseId;
  String? _selectedShiftId;
  String? _selectedClassId;
  String? _selectedTestId;
  String? _selectedPublishedStatus;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _resultController.fetchAllResults(),
      _testController.fetchAllTests(),
      _studentController.fetchAllStudents(),
      _courseController.fetchCourses(),
      _shiftController.fetchShifts(),
      _classController.fetchClasses(),
    ]);
  }

  List<Map<String, dynamic>> get _filteredResults {
    var results = <Map<String, dynamic>>[];

    // Combine results with student and test information
    for (final result in _resultController.results) {
      final student = _studentController.students
          .where((s) => s.id == result.studentId)
          .firstOrNull;
      final test = _testController.tests
          .where((t) => t.id == result.testId)
          .firstOrNull;

      if (student != null && test != null) {
        results.add({
          'result': result,
          'student': student,
          'test': test,
        });
      }
    }

    // Apply filters
    if (_selectedCourseId != null) {
      results = results.where((r) => r['test'].courseId == _selectedCourseId).toList();
    }
    if (_selectedShiftId != null) {
      results = results.where((r) => r['test'].shiftId == _selectedShiftId).toList();
    }
    if (_selectedClassId != null) {
      results = results.where((r) => r['test'].classId == _selectedClassId).toList();
    }
    if (_selectedTestId != null) {
      results = results.where((r) => r['test'].id == _selectedTestId).toList();
    }
    if (_selectedPublishedStatus != null) {
      if (_selectedPublishedStatus == 'published') {
        results = results.where((r) => r['test'].resultsReleased).toList();
      } else if (_selectedPublishedStatus == 'unpublished') {
        results = results.where((r) => !r['test'].resultsReleased).toList();
      }
    }

    // Apply search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      results = results.where((r) {
        final student = r['student'] as UserModel;
        return student.name.toLowerCase().contains(query) ||
               (student.studentId?.toLowerCase().contains(query) ?? false) ||
               student.email.toLowerCase().contains(query);
      }).toList();
    }

    // Sort by obtained marks descending
    results.sort((a, b) => (b['result'] as ResultModel).obtainedMarks.compareTo(
      (a['result'] as ResultModel).obtainedMarks
    ));

    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('All Students Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(
        () => _resultController.isLoading.value ||
                _testController.isLoading.value ||
                _studentController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Filters Section
                  _buildFiltersSection(),
                  const SizedBox(height: 16),
                  // Results List
                  Expanded(
                    child: _filteredResults.isEmpty
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
                                  'No results found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _buildResultsList(),
                  ),
                  // Download Button
                  if (_filteredResults.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _downloadAllResultsPDF,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Download All Results PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Filter Results',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_selectedCourseId != null ||
                  _selectedShiftId != null ||
                  _selectedClassId != null ||
                  _selectedTestId != null ||
                  _selectedPublishedStatus != null ||
                  _searchController.text.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedCourseId = null;
                      _selectedShiftId = null;
                      _selectedClassId = null;
                      _selectedTestId = null;
                      _selectedPublishedStatus = null;
                      _searchController.clear();
                    });
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear All'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, student ID, or email',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          // Filter dropdowns
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Course',
                  value: _selectedCourseId,
                  items: _courseController.courses,
                  onChanged: (value) {
                    setState(() {
                      _selectedCourseId = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: 'Shift',
                  value: _selectedShiftId,
                  items: _shiftController.shifts,
                  onChanged: (value) {
                    setState(() {
                      _selectedShiftId = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Class (9th-12th)',
                  value: _selectedClassId,
                  items: _classController.classes,
                  onChanged: (value) {
                    setState(() {
                      _selectedClassId = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: 'Test',
                  value: _selectedTestId,
                  items: _testController.tests,
                  onChanged: (value) {
                    setState(() {
                      _selectedTestId = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Published Status',
                  value: _selectedPublishedStatus,
                  items: const ['published', 'unpublished'],
                  isStringList: true,
                  onChanged: (value) {
                    setState(() {
                      _selectedPublishedStatus = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required dynamic items,
    required Function(String?) onChanged,
    bool isStringList = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          hint: const Text('All'),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All'),
            ),
            ...items.map((item) {
              String itemId;
              String itemName;
              if (isStringList) {
                itemId = item as String;
                itemName = item.toString()[0].toUpperCase() + item.toString().substring(1);
              } else if (item is CourseModel) {
                itemId = item.id ?? '';
                itemName = item.name;
              } else if (item is ShiftModel) {
                itemId = item.id ?? '';
                itemName = item.name;
              } else if (item is ClassModel) {
                itemId = item.id ?? '';
                itemName = item.name;
              } else if (item is TestModel) {
                itemId = item.id ?? '';
                itemName = item.title;
              } else {
                itemId = '';
                itemName = 'Unknown';
              }
              if (isStringList) {
                itemName = itemName[0].toUpperCase() + itemName.substring(1);
              }
              return DropdownMenuItem<String>(
                value: itemId.isEmpty ? null : itemId,
                child: Text(itemName),
              );
            }),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredResults.length,
      itemBuilder: (context, index) {
        final item = _filteredResults[index];
        final result = item['result'] as ResultModel;
        final student = item['student'] as UserModel;
        final test = item['test'] as TestModel;
        final course = _courseController.courses
            .where((c) => c.id == test.courseId)
            .firstOrNull;
        final shift = _shiftController.shifts
            .where((s) => s.id == test.shiftId)
            .firstOrNull;
        final schoolClass = _classController.classes
            .where((c) => c.id == test.classId)
            .firstOrNull;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Row(
              children: [
                CircleAvatar(
                  child: Text('${index + 1}'),
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${test.title} • ${course?.name ?? 'N/A'}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            subtitle: Row(
              children: [
                Text(
                  '${result.obtainedMarks}/${result.totalMarks} (${result.percentage.toStringAsFixed(1)}%)',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(result.status),
                  backgroundColor: result.status == 'PASS'
                      ? AppTheme.successColor
                      : AppTheme.errorColor,
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Student ID', student.studentId ?? 'N/A'),
                    _buildDetailRow('Roll Number', student.studentId ?? 'N/A'),
                    _buildDetailRow('Course', course?.name ?? 'N/A'),
                    _buildDetailRow('Shift', shift?.name ?? 'N/A'),
                    _buildDetailRow('Class', schoolClass?.name ?? 'N/A'),
                    _buildDetailRow('Test', test.title),
                    _buildDetailRow('Total Marks', '${test.totalMarks}'),
                    _buildDetailRow('Obtained Marks', '${result.obtainedMarks}'),
                    _buildDetailRow('Percentage', '${result.percentage.toStringAsFixed(1)}%'),
                    _buildDetailRow('Grade', result.getGrade()),
                    _buildDetailRow('Position', test.resultsReleased && result.position != null
                        ? '${result.position}${_getOrdinalSuffix(result.position!)}'
                        : 'N/A'),
                    _buildDetailRow('Status', result.status),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _downloadStudentMarksheet(result, student, test, course),
                            icon: const Icon(Icons.download, size: 18),
                            label: const Text('Download Marksheet'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
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

  Future<void> _downloadStudentMarksheet(
    ResultModel result,
    UserModel student,
    TestModel test,
    CourseModel? course,
  ) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await _pdfService.generateMarksheet(
        result: result,
        student: student,
        test: test,
        course: course,
      );

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.snackbar(
        'Success',
        'Marksheet downloaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.successColor,
        colorText: Colors.white,
      );
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Failed to download marksheet: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _downloadAllResultsPDF() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Prepare data for PDF
      final resultsData = _filteredResults.map((item) {
        return {
          'result': item['result'] as ResultModel,
          'student': item['student'] as UserModel,
          'test': item['test'] as TestModel,
        };
      }).toList();

      await _pdfService.generateAllStudentsResultsPDF(
        resultsData: resultsData,
        courses: _courseController.courses,
        shifts: _shiftController.shifts,
        classes: _classController.classes,
      );

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.snackbar(
        'Success',
        'All results PDF downloaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.successColor,
        colorText: Colors.white,
      );
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Failed to download PDF: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }
}
