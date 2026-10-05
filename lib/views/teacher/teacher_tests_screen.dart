import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/test_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/course_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart';
import '../../models/test_model.dart';
import '../../models/course_model.dart';
import '../../app/responsive/responsive_utils.dart';

// ignore_for_file: deprecated_member_use

class TeacherTestsScreen extends StatefulWidget {
  const TeacherTestsScreen({super.key});

  @override
  State<TeacherTestsScreen> createState() => _TeacherTestsScreenState();
}

class _TeacherTestsScreenState extends State<TeacherTestsScreen> {
  final TestController _testController = Get.put(TestController());
  final AuthController _authController = Get.find<AuthController>();
  final CourseController _courseController = Get.put(CourseController());

  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadTests();
    _courseController.fetchCourses();
  }

  Future<void> _loadTests() async {
    await _testController.fetchTestsByTeacher(
      teacherId: _authController.currentUser!.id!,
    );
  }

  Future<void> _showEditTestDialog(TestModel test) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: test.title);
    final descriptionController = TextEditingController(
      text: test.description ?? '',
    );
    final durationController = TextEditingController(
      text: test.durationMinutes.toString(),
    );
    final totalMarksController = TextEditingController(
      text: test.totalMarks.toString(),
    );
    final passingMarksController = TextEditingController(
      text: test.passingMarks.toString(),
    );

    CourseModel? selectedCourse = _courseController.courses
        .where((c) => c.id == test.courseId)
        .firstOrNull;

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Edit Test'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Test Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: durationController,
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
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: totalMarksController,
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
                        controller: passingMarksController,
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
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Get.back(result: true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      final success = await _testController.updateTest(
        testId: test.id!,
        title: titleController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        courseId: selectedCourse?.id,
        durationMinutes: int.parse(durationController.text),
        totalMarks: int.parse(totalMarksController.text),
        passingMarks: int.parse(passingMarksController.text),
      );

      if (success) {
        Get.snackbar(
          'Success',
          'Test updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.successColor,
          colorText: Colors.white,
        );
        await _loadTests();
      } else {
        Get.snackbar(
          'Error',
          _testController.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.errorColor,
          colorText: Colors.white,
        );
      }
    }

    titleController.dispose();
    descriptionController.dispose();
    durationController.dispose();
    totalMarksController.dispose();
    passingMarksController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tests')),
      drawer: _buildNavigationDrawer(context),
      bottomNavigationBar: ResponsiveUtils.isMobile(context)
          ? _buildBottomNavigationBar()
          : null,
      body: Obx(
        () => _testController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : _testController.tests.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.quiz_outlined,
                      size: ResponsiveUtils.responsiveIconSize(context, 80),
                      color: AppTheme.textSecondary,
                    ),
                    SizedBox(
                      height: ResponsiveUtils.responsiveSpacing(context, 16),
                    ),
                    Text(
                      'No tests created yet',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          18,
                        ),
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: ResponsiveUtils.responsivePadding(context),
                itemCount: _testController.tests.length,
                itemBuilder: (context, index) {
                  final test = _testController.tests[index];
                  return Card(
                    margin: EdgeInsets.only(
                      bottom: ResponsiveUtils.responsiveSpacing(context, 16),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.responsiveSpacing(context, 16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  test.title,
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveUtils.responsiveFontSize(
                                          context,
                                          18,
                                        ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Chip(
                                label: Text(test.status.toUpperCase()),
                                backgroundColor: _getStatusColor(test.status),
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          if (test.description != null) ...[
                            SizedBox(
                              height: ResponsiveUtils.responsiveSpacing(
                                context,
                                8,
                              ),
                            ),
                            Text(
                              test.description!,
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: ResponsiveUtils.responsiveFontSize(
                                  context,
                                  14,
                                ),
                              ),
                            ),
                          ],
                          SizedBox(
                            height: ResponsiveUtils.responsiveSpacing(
                              context,
                              12,
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildInfoChip(
                                  Icons.help_outline,
                                  '${test.questionCount} Questions',
                                ),
                                SizedBox(
                                  width: ResponsiveUtils.responsiveSpacing(
                                    context,
                                    8,
                                  ),
                                ),
                                _buildInfoChip(
                                  Icons.access_time,
                                  '${test.durationMinutes} min',
                                ),
                                SizedBox(
                                  width: ResponsiveUtils.responsiveSpacing(
                                    context,
                                    8,
                                  ),
                                ),
                                _buildInfoChip(
                                  Icons.star_outline,
                                  '${test.totalMarks} Marks',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveUtils.responsiveSpacing(
                              context,
                              16,
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Get.toNamed(
                                      Routes.TEST_QUESTIONS,
                                      arguments: test,
                                    );
                                  },
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text('Questions'),
                                ),
                              ),
                              SizedBox(
                                width: ResponsiveUtils.responsiveSpacing(
                                  context,
                                  8,
                                ),
                              ),
                              if (test.status == 'published')
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Get.toNamed(
                                        '/test-monitoring',
                                        arguments: test,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.visibility,
                                      size: 16,
                                    ),
                                    label: const Text('Monitor'),
                                  ),
                                ),
                              SizedBox(
                                width: ResponsiveUtils.responsiveSpacing(
                                  context,
                                  8,
                                ),
                              ),
                              if (test.status == 'draft')
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final confirmed = await Get.dialog<bool>(
                                        AlertDialog(
                                          title: const Text('Publish Test'),
                                          content: const Text(
                                            'Are you sure you want to publish this test?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Get.back(result: false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Get.back(result: true),
                                              child: const Text('Publish'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true) {
                                        await _testController.publishTest(
                                          testId: test.id!,
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.publish, size: 16),
                                    label: const Text('Publish'),
                                  ),
                                ),
                              if (test.status == 'published')
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      await _testController.releaseResults(
                                        testId: test.id!,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.check_circle,
                                      size: 16,
                                    ),
                                    label: const Text('Release Results'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.successColor,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () => _showEditTestDialog(test),
                                icon: const Icon(Icons.edit_note),
                                color: AppTheme.primaryColor,
                                tooltip: 'Edit Test',
                              ),
                              SizedBox(
                                width: ResponsiveUtils.responsiveSpacing(
                                  context,
                                  4,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  final confirmed = await Get.dialog<bool>(
                                    AlertDialog(
                                      title: const Text('Delete Test'),
                                      content: const Text(
                                        'Are you sure you want to delete this test? This will also delete all associated questions, attempts, and results. This action cannot be undone.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Get.back(result: false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Get.back(result: true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppTheme.errorColor,
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    final success = await _testController
                                        .deleteTest(
                                          testId: test.id!,
                                          teacherId:
                                              _authController.currentUser!.id!,
                                        );
                                    if (success) {
                                      Get.snackbar(
                                        'Success',
                                        'Test deleted successfully',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: AppTheme.successColor,
                                        colorText: Colors.white,
                                      );
                                    } else {
                                      Get.snackbar(
                                        'Error',
                                        _testController.errorMessage.value,
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: AppTheme.errorColor,
                                        colorText: Colors.white,
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.delete),
                                color: AppTheme.errorColor,
                                tooltip: 'Delete Test',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(Routes.CREATE_TEST);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNavigationDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.secondaryColor,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.person, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Teacher Portal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 24),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Text(
                      _authController.currentUser?.name ?? 'Teacher',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.dashboard, 'Dashboard', 0),
            _buildDrawerItem(Icons.quiz, 'Tests', 1),
            _buildDrawerItem(Icons.menu_book, 'Courses', 2),
            _buildDrawerItem(Icons.people, 'Students', 3),
            _buildDrawerItem(Icons.assessment, 'Results', 4),
            _buildDrawerItem(Icons.person, 'Profile', 5),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String label, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      selected: _selectedIndex == index,
      selectedTileColor: Colors.white.withValues(alpha: 0.2),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        _handleNavigation(index);
        if (ResponsiveUtils.isMobile(context)) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
        _handleNavigation(index);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.quiz_outlined),
          selectedIcon: Icon(Icons.quiz),
          label: 'Tests',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book),
          label: 'Courses',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outlined),
          selectedIcon: Icon(Icons.people),
          label: 'Students',
        ),
        NavigationDestination(
          icon: Icon(Icons.assessment_outlined),
          selectedIcon: Icon(Icons.assessment),
          label: 'Results',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outlined),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        Get.toNamed(Routes.TEACHER_DASHBOARD);
        break;
      case 1:
        Navigator.pop(context);
        break;
      case 2:
        Get.toNamed(Routes.TEACHER_COURSES);
        break;
      case 3:
        Get.toNamed(Routes.TEACHER_STUDENTS);
        break;
      case 4:
        Get.toNamed(Routes.TEACHER_RESULTS);
        break;
      case 5:
        Get.toNamed(Routes.TEACHER_PROFILE);
        break;
    }
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 12),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'published':
        return AppTheme.successColor;
      case 'draft':
        return AppTheme.warningColor;
      case 'closed':
        return AppTheme.errorColor;
      case 'results_released':
        return AppTheme.primaryColor;
      default:
        return Colors.grey;
    }
  }
}
