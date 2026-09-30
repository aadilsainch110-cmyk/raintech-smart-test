import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/course_controller.dart';
import '../../controllers/test_controller.dart';
import '../../controllers/student_controller.dart';
import '../../controllers/teacher_controller.dart';
import '../../app/theme/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final AdminController _adminController = Get.put(AdminController());
  final CourseController _courseController = Get.put(CourseController());
  final TestController _testController = Get.put(TestController());
  final StudentController _studentController = Get.put(StudentController());
  final TeacherController _teacherController = Get.put(TeacherController());

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _adminController.fetchAllData(),
      _courseController.fetchCourses(),
      _testController.fetchAllTests(),
      _studentController.fetchAllStudents(),
      _teacherController.fetchAllTeachers(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authController.signOut();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Text(
                  'Welcome, ${_authController.currentUser?.name ?? 'Admin'} 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      'Users',
                      _adminController.users.length.toString(),
                      Icons.people,
                      AppTheme.primaryColor,
                    ),
                    _buildStatCard(
                      'Courses',
                      _courseController.courses.length.toString(),
                      Icons.menu_book,
                      AppTheme.successColor,
                    ),
                    _buildStatCard(
                      'Tests',
                      _testController.tests.length.toString(),
                      Icons.quiz,
                      AppTheme.warningColor,
                    ),
                    _buildStatCard(
                      'Classes',
                      _adminController.classes.length.toString(),
                      Icons.class_,
                      AppTheme.accentColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Management',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildManagementCard(
                'Users Management',
                Icons.people_outline,
                () => _showUsersDialog(),
              ),
              const SizedBox(height: 12),
              _buildManagementCard(
                'Courses Management',
                Icons.menu_book,
                () => Get.toNamed('/courses-management'),
              ),
              const SizedBox(height: 12),
              _buildManagementCard(
                'Classes Management',
                Icons.class_outlined,
                () => Get.toNamed('/classes-management'),
              ),
              const SizedBox(height: 12),
              _buildManagementCard(
                'Shifts Management',
                Icons.access_time,
                () => Get.toNamed('/shifts-management'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Quick Stats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Obx(
                () => Column(
                  children: [
                    _buildStatRow(
                      'Students',
                      _studentController.students.length.toString(),
                    ),
                    _buildStatRow(
                      'Teachers',
                      _teacherController.teachers.length.toString(),
                    ),
                    _buildStatRow(
                      'Active Tests',
                      _testController.tests
                          .where((t) => t.status == 'published')
                          .length
                          .toString(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showUsersDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Users Management'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Obx(
            () => ListView.builder(
              itemCount: _adminController.users.length,
              itemBuilder: (context, index) {
                final user = _adminController.users[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text('${user.email} • ${user.role}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: user.isActive,
                        onChanged: (value) async {
                          await _adminController.updateUser(
                            userId: user.id!,
                            isActive: value,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: AppTheme.errorColor,
                        onPressed: () async {
                          final confirmed = await Get.dialog<bool>(
                            AlertDialog(
                              title: const Text('Delete User'),
                              content: const Text(
                                'Are you sure you want to delete this user?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(result: false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Get.back(result: true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.errorColor,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await _adminController.updateUser(
                              userId: user.id!,
                              isActive: false,
                            );
                          }
                        },
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
        ],
      ),
    );
  }
}
