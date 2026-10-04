import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/course_controller.dart';
import '../../models/course_model.dart';
import '../../app/theme/app_theme.dart';
import '../../app/responsive/responsive_utils.dart';

class CoursesManagementScreen extends StatefulWidget {
  const CoursesManagementScreen({super.key});

  @override
  State<CoursesManagementScreen> createState() =>
      _CoursesManagementScreenState();
}

class _CoursesManagementScreenState extends State<CoursesManagementScreen> {
  final CourseController _courseController = Get.put(CourseController());

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _courseController.fetchCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCourseDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Obx(
          () => _courseController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : _courseController.courses.isEmpty
              ? _buildEmptyState()
              : _buildCoursesList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Builder(
      builder: (context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: ResponsiveUtils.responsiveIconSize(context, 64),
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
            Text(
              'No courses yet',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
            ElevatedButton.icon(
              onPressed: _showAddCourseDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add First Course'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.responsiveSpacing(context, 24),
                  vertical: ResponsiveUtils.responsiveSpacing(context, 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesList() {
    return Builder(
      builder: (context) => ListView.builder(
        padding: ResponsiveUtils.responsivePadding(context),
        itemCount: _courseController.courses.length,
        itemBuilder: (context, index) {
          final course = _courseController.courses[index];
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
                course.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                ),
              ),
              subtitle: course.description != null
                  ? Text(
                      course.description!,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                      ),
                    )
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: course.isActive,
                    onChanged: (value) async {
                      await _courseController.updateCourse(
                        courseId: course.id!,
                        name: course.name,
                        isActive: value,
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditCourseDialog(course),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: AppTheme.errorColor,
                    onPressed: () => _showDeleteDialog(course),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddCourseDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Course'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Course Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter course name',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.errorColor,
                  colorText: Colors.white,
                );
                return;
              }
              final success = await _courseController.createCourse(
                name: nameController.text,
                description: descriptionController.text.isEmpty
                    ? null
                    : descriptionController.text,
              );
              if (success) {
                Get.back();
                Get.snackbar(
                  'Success',
                  'Course created successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.successColor,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditCourseDialog(CourseModel course) {
    final nameController = TextEditingController(text: course.name);
    final descriptionController = TextEditingController(
      text: course.description ?? '',
    );

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Course'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Course Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter course name',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.errorColor,
                  colorText: Colors.white,
                );
                return;
              }
              final success = await _courseController.updateCourse(
                courseId: course.id!,
                name: nameController.text,
                description: descriptionController.text.isEmpty
                    ? null
                    : descriptionController.text,
                isActive: course.isActive,
              );
              if (success) {
                Get.back();
                Get.snackbar(
                  'Success',
                  'Course updated successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.successColor,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(CourseModel course) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final success = await _courseController.updateCourse(
                courseId: course.id!,
                name: course.name,
                isActive: false,
              );
              if (success) {
                Get.back();
                Get.snackbar(
                  'Success',
                  'Course deleted successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.successColor,
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
}
