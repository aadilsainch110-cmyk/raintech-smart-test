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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'My Tests',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,

        foregroundColor: AppTheme.primaryColor,
      ),
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
                    Container(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.responsiveSpacing(context, 24),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.quiz_outlined,
                        size: ResponsiveUtils.responsiveIconSize(context, 64),
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveUtils.responsiveSpacing(context, 24),
                    ),
                    Text(
                      'No tests created yet',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          18,
                        ),
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveUtils.responsiveSpacing(context, 8),
                    ),
                    Text(
                      'Tap the + button to create your first test',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          14,
                        ),
                        color: AppTheme.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(
                  ResponsiveUtils.responsiveSpacing(context, 16),
                ),
                itemCount: _testController.tests.length,
                itemBuilder: (context, index) {
                  final test = _testController.tests[index];
                  return Container(
                    margin: EdgeInsets.only(
                      bottom: ResponsiveUtils.responsiveSpacing(context, 16),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.responsiveBorderRadius(context, 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.responsiveSpacing(context, 16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header: Title and Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      test.title,
                                      style: TextStyle(
                                        fontSize: ResponsiveUtils.responsiveFontSize(
                                          context,
                                          18,
                                        ),
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                        height: 1.3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (test.description != null) ...[
                                      SizedBox(
                                        height: ResponsiveUtils.responsiveSpacing(
                                          context,
                                          6,
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
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: ResponsiveUtils.responsiveSpacing(context, 12),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveUtils.responsiveSpacing(context, 12),
                                  vertical: ResponsiveUtils.responsiveSpacing(context, 6),
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(test.status),
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveUtils.responsiveBorderRadius(context, 8),
                                  ),
                                ),
                                child: Text(
                                  _formatStatus(test.status),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ResponsiveUtils.responsiveFontSize(
                                      context,
                                      12,
                                    ),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: ResponsiveUtils.responsiveSpacing(
                              context,
                              14,
                            ),
                          ),
                          // Metadata Chips
                          Wrap(
                            spacing: ResponsiveUtils.responsiveSpacing(context, 8),
                            runSpacing: ResponsiveUtils.responsiveSpacing(context, 8),
                            children: [
                              _buildInfoChip(
                                Icons.quiz_outlined,
                                '${test.questionCount} Questions',
                              ),
                              _buildInfoChip(
                                Icons.access_time,
                                '${test.durationMinutes} min',
                              ),
                              _buildInfoChip(
                                Icons.grade_outlined,
                                '${test.totalMarks} Marks',
                              ),
                            ],
                          ),
                          SizedBox(
                            height: ResponsiveUtils.responsiveSpacing(
                              context,
                              16,
                            ),
                          ),
                          // Action Buttons
                          Wrap(
                            spacing: ResponsiveUtils.responsiveSpacing(context, 8),
                            runSpacing: ResponsiveUtils.responsiveSpacing(context, 8),
                            children: [
                              _buildActionButton(
                                icon: Icons.edit_note,
                                label: 'Questions',
                                onPressed: () {
                                  Get.toNamed(
                                    Routes.TEST_QUESTIONS,
                                    arguments: test,
                                  );
                                },
                                isPrimary: false,
                              ),
                              if (test.status == 'published')
                                _buildActionButton(
                                  icon: Icons.visibility,
                                  label: 'Monitor',
                                  onPressed: () {
                                    Get.toNamed(
                                      '/test-monitoring',
                                      arguments: test,
                                    );
                                  },
                                  isPrimary: false,
                                ),
                              if (test.status == 'draft')
                                _buildActionButton(
                                  icon: Icons.publish,
                                  label: 'Publish',
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
                                  isPrimary: true,
                                ),
                              if (test.status == 'published')
                                _buildActionButton(
                                  icon: Icons.check_circle,
                                  label: 'Release Results',
                                  onPressed: () async {
                                    await _testController.releaseResults(
                                      testId: test.id!,
                                    );
                                  },
                                  isPrimary: true,
                                ),
                              _buildActionButton(
                                icon: Icons.settings,
                                label: 'Edit',
                                onPressed: () => _showEditTestDialog(test),
                                isPrimary: false,
                              ),
                              _buildActionButton(
                                icon: Icons.delete_outline,
                                label: 'Delete',
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
                                isPrimary: false,
                                isDestructive: true,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed(Routes.CREATE_TEST);
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Test'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                _showLogoutConfirmation(context);
                if (ResponsiveUtils.isMobile(context)) {
                  Navigator.pop(context);
                }
              },
            ),
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
      backgroundColor: Colors.white,
      indicatorColor: AppTheme.primaryColor.withValues(alpha: 0.1),
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
        _handleNavigation(index);
      },
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined, color: _selectedIndex == 0 ? AppTheme.primaryColor : AppTheme.textSecondary),
          selectedIcon: Icon(Icons.dashboard, color: AppTheme.primaryColor),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.quiz_outlined, color: _selectedIndex == 1 ? AppTheme.primaryColor : AppTheme.textSecondary),
          selectedIcon: Icon(Icons.quiz, color: AppTheme.primaryColor),
          label: 'Tests',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined, color: _selectedIndex == 2 ? AppTheme.primaryColor : AppTheme.textSecondary),
          selectedIcon: Icon(Icons.menu_book, color: AppTheme.primaryColor),
          label: 'Courses',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outlined, color: _selectedIndex == 3 ? AppTheme.primaryColor : AppTheme.textSecondary),
          selectedIcon: Icon(Icons.people, color: AppTheme.primaryColor),
          label: 'Students',
        ),
        NavigationDestination(
          icon: Icon(Icons.assessment_outlined, color: _selectedIndex == 4 ? AppTheme.primaryColor : AppTheme.textSecondary),
          selectedIcon: Icon(Icons.assessment, color: AppTheme.primaryColor),
          label: 'Results',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outlined, color: _selectedIndex == 5 ? AppTheme.primaryColor : AppTheme.textSecondary),
          selectedIcon: Icon(Icons.person, color: AppTheme.primaryColor),
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
    return Builder(
      builder: (context) => Chip(
        avatar: Icon(icon, size: 16, color: AppTheme.primaryColor),
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: ResponsiveUtils.responsiveFontSize(context, 12),
          fontWeight: FontWeight.w500,
          color: AppTheme.primaryColor,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.responsiveSpacing(context, 10),
          vertical: ResponsiveUtils.responsiveSpacing(context, 6),
        ),
        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
        side: BorderSide(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
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

  String _formatStatus(String status) {
    switch (status) {
      case 'published':
        return 'Published';
      case 'draft':
        return 'Draft';
      case 'closed':
        return 'Closed';
      case 'results_released':
        return 'Results Released';
      default:
        return status.toUpperCase();
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
    bool isDestructive = false,
  }) {
    return Builder(
      builder: (context) => OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: isDestructive
              ? AppTheme.errorColor
              : isPrimary
                  ? Colors.white
                  : AppTheme.primaryColor,
          backgroundColor: isPrimary ? AppTheme.primaryColor : null,
          side: BorderSide(
            color: isDestructive
                ? AppTheme.errorColor
                : isPrimary
                    ? AppTheme.primaryColor
                    : AppTheme.primaryColor,
            width: 1.5,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.responsiveSpacing(context, 14),
            vertical: ResponsiveUtils.responsiveSpacing(context, 10),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.responsiveBorderRadius(context, 8),
            ),
          ),
          textStyle: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, 13),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
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
                _authController.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
