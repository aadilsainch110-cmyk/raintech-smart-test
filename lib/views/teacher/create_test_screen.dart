import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/test_controller.dart';
import '../../controllers/course_controller.dart';
import '../../models/course_model.dart';
import '../../app/theme/app_theme.dart';

// ignore_for_file: avoid_print

class CreateTestScreen extends StatefulWidget {
  const CreateTestScreen({super.key});

  @override
  State<CreateTestScreen> createState() => _CreateTestScreenState();
}

class _CreateTestScreenState extends State<CreateTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalMarksController = TextEditingController(text: '100');
  final _passingMarksController = TextEditingController(text: '50');
  final _durationController = TextEditingController(text: '60');

  final AuthController _authController = Get.find<AuthController>();
  final TestController _testController = Get.put(TestController());
  final CourseController _courseController = Get.put(CourseController());

  CourseModel? _selectedCourse;
  String? _selectedClassId;
  String? _selectedShiftId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _courseController.fetchCourses();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _totalMarksController.dispose();
    _passingMarksController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateTest({required bool publish}) async {
    print('DEBUG: _handleCreateTest called with publish: $publish');
    if (_formKey.currentState!.validate()) {
      print('DEBUG: Form validation passed');
      if (_selectedCourse == null) {
        print('DEBUG: No course selected');
        Get.snackbar(
          'Error',
          'Please select a course',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.errorColor,
          colorText: Colors.white,
        );
        return;
      }
      print('DEBUG: Course selected: ${_selectedCourse!.id}');

      if (_startDate == null || _endDate == null) {
        print('DEBUG: Dates not selected');
        Get.snackbar(
          'Error',
          'Please select start and end dates',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.errorColor,
          colorText: Colors.white,
        );
        return;
      }
      print('DEBUG: Dates selected - Start: $_startDate, End: $_endDate');

      // If publishing, show confirmation dialog
      if (publish) {
        final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Publish Test'),
            content: const Text(
              'Are you sure you want to publish this test? Once published, it will be visible to students.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Publish'),
              ),
            ],
          ),
        );
        if (confirmed != true) {
          return;
        }
      }

      // Set loading state
      setState(() {
        _isCreating = true;
      });

      print('DEBUG: Calling createTest with params:');
      print('  - Title: ${_titleController.text.trim()}');
      print('  - Course ID: ${_selectedCourse!.id!}');
      print('  - Class ID: $_selectedClassId');
      print('  - Shift ID: ${_selectedShiftId ?? "default"}');
      print('  - Duration: ${int.parse(_durationController.text)}');
      print('  - Total Marks: ${int.parse(_totalMarksController.text)}');
      print('  - Passing Marks: ${int.parse(_passingMarksController.text)}');
      print('  - Created By: ${_authController.currentUser!.id!}');
      print('  - Status: ${publish ? "published" : "draft"}');

      final success = await _testController.createTest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        courseId: _selectedCourse!.id!,
        classId: _selectedClassId,
        shiftId: _selectedShiftId ?? 'default',
        durationMinutes: int.parse(_durationController.text),
        totalMarks: int.parse(_totalMarksController.text),
        passingMarks: int.parse(_passingMarksController.text),
        createdBy: _authController.currentUser!.id!,
        startDate: _startDate,
        endDate: _endDate,
        status: publish ? 'published' : 'draft',
      );

      // Reset loading state
      setState(() {
        _isCreating = false;
      });

      print('DEBUG: createTest returned: $success');
      if (success) {
        print('DEBUG: Test creation successful');

        // Clear form fields
        _formKey.currentState!.reset();
        _titleController.clear();
        _descriptionController.clear();
        _totalMarksController.text = '100';
        _passingMarksController.text = '50';
        _durationController.text = '60';
        setState(() {
          _selectedCourse = null;
          _selectedClassId = null;
          _selectedShiftId = null;
          _startDate = null;
          _endDate = null;
        });

        // Show success dialog
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  publish
                      ? 'Test Published Successfully! 🎉'
                      : 'Test Saved as Draft! 📝',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  publish
                      ? 'Your test has been published and is now visible to students.'
                      : 'Your test has been saved as a draft. You can publish it later from the Tests screen.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.back(); // Go back to test list
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        print(
          'DEBUG: Test creation failed: ${_testController.errorMessage.value}',
        );
        Get.snackbar(
          'Failed to create test. Please try again.',
          '',
          icon: const Icon(Icons.error_outline, color: Colors.white, size: 28),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.errorColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          snackStyle: SnackStyle.GROUNDED,
        );
      }
    } else {
      print('DEBUG: Form validation failed');
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null && mounted) {
        setState(() {
          _startDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null && mounted) {
        setState(() {
          _endDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Create Test'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Test Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter test title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Obx(
                () => DropdownButtonFormField<CourseModel>(
                  initialValue: _selectedCourse,
                  decoration: const InputDecoration(
                    labelText: 'Course',
                    border: OutlineInputBorder(),
                  ),
                  items: _courseController.courses.map((course) {
                    return DropdownMenuItem<CourseModel>(
                      value: course,
                      child: Text(course.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCourse = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a course';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Class ID (Optional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _selectedClassId = value.trim().isEmpty ? null : value.trim();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Shift ID (Optional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _selectedShiftId = value.trim().isEmpty ? null : value.trim();
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _totalMarksController,
                      decoration: const InputDecoration(
                        labelText: 'Total Marks',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        final marks = int.tryParse(value);
                        if (marks == null || marks <= 0) {
                          return 'Invalid marks';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _passingMarksController,
                      decoration: const InputDecoration(
                        labelText: 'Passing Marks',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        final marks = int.tryParse(value);
                        if (marks == null || marks <= 0) {
                          return 'Invalid marks';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  final duration = int.tryParse(value);
                  if (duration == null || duration <= 0) {
                    return 'Invalid duration';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Start Date & Time'),
                subtitle: Text(
                  _startDate != null
                      ? '${_startDate!.toLocal()}'.split('.')[0]
                      : 'Not selected',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectStartDate,
              ),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('End Date & Time'),
                subtitle: Text(
                  _endDate != null
                      ? '${_endDate!.toLocal()}'.split('.')[0]
                      : 'Not selected',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectEndDate,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isCreating
                          ? null
                          : () => _handleCreateTest(publish: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: _isCreating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Save as Draft',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isCreating
                          ? null
                          : () => _handleCreateTest(publish: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cardColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: _isCreating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Publish Test',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
