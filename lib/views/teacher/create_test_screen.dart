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

  Future<void> _handleCreateTest() async {
    print('DEBUG: _handleCreateTest called');
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

      print('DEBUG: Calling createTest with params:');
      print('  - Title: ${_titleController.text.trim()}');
      print('  - Course ID: ${_selectedCourse!.id!}');
      print('  - Class ID: $_selectedClassId');
      print('  - Shift ID: ${_selectedShiftId ?? "default"}');
      print('  - Duration: ${int.parse(_durationController.text)}');
      print('  - Total Marks: ${int.parse(_totalMarksController.text)}');
      print('  - Passing Marks: ${int.parse(_passingMarksController.text)}');
      print('  - Created By: ${_authController.currentUser!.id!}');

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
      );

      print('DEBUG: createTest returned: $success');
      if (success) {
        print('DEBUG: Test creation successful');
        Get.snackbar(
          'Success',
          'Test created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.successColor,
          colorText: Colors.white,
        );
        Get.back();
      } else {
        print(
          'DEBUG: Test creation failed: ${_testController.errorMessage.value}',
        );
        Get.snackbar(
          'Error',
          _testController.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.errorColor,
          colorText: Colors.white,
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
      appBar: AppBar(title: const Text('Create Test')),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleCreateTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.cardColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Create Test',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
