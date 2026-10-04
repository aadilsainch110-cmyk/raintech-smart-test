import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/course_controller.dart';
import '../../controllers/test_controller.dart';
import '../../controllers/student_controller.dart';
import '../../controllers/teacher_controller.dart';
import '../../app/theme/app_theme.dart';
import '../../app/responsive/responsive_utils.dart';
import '../../app/responsive/adaptive_navigation.dart';

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
    return AdaptiveScaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutConfirmation(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: ResponsiveUtils.responsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Text(
                  'Welcome, ${_authController.currentUser?.name ?? 'Admin'} 👋',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 24),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 24)),
              Obx(
                () => GridView.count(
                  crossAxisCount: ResponsiveUtils.getGridColumns(context),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: ResponsiveUtils.responsiveSpacing(context, 12),
                  crossAxisSpacing: ResponsiveUtils.responsiveSpacing(context, 12),
                  childAspectRatio: ResponsiveUtils.isMobile(context) ? 1.2 : 1.5,
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
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 24)),
              Text(
                'Management',
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
              _buildManagementCard(
                'Users Management',
                Icons.people_outline,
                () => _showUsersDialog(),
              ),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 12)),
              _buildManagementCard(
                'Courses Management',
                Icons.menu_book,
                () => Get.toNamed('/courses-management'),
              ),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 12)),
              _buildManagementCard(
                'Classes Management',
                Icons.class_outlined,
                () => Get.toNamed('/classes-management'),
              ),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 12)),
              _buildManagementCard(
                'Shifts Management',
                Icons.access_time,
                () => Get.toNamed('/shifts-management'),
              ),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 24)),
              Text(
                'Quick Stats',
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
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
      drawer: _buildNavigationDrawer(context),
      bottomNavigationBar: ResponsiveUtils.isMobile(context)
          ? _buildBottomNavigationBar()
          : null,
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
                  const Icon(Icons.admin_panel_settings, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Admin Portal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 24),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Text(
                      _authController.currentUser?.name ?? 'Admin',
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
            _buildDrawerItem(Icons.people, 'Users', 1),
            _buildDrawerItem(Icons.menu_book, 'Courses', 2),
            _buildDrawerItem(Icons.class_, 'Classes', 3),
            _buildDrawerItem(Icons.access_time, 'Shifts', 4),
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
      onTap: () {
        if (ResponsiveUtils.isMobile(context)) {
          Navigator.pop(context);
        }
        // Handle navigation based on index
        switch (index) {
          case 0:
            break;
          case 1:
            _showUsersDialog();
            break;
          case 2:
            Get.toNamed('/courses-management');
            break;
          case 3:
            Get.toNamed('/classes-management');
            break;
          case 4:
            Get.toNamed('/shifts-management');
            break;
        }
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outlined),
          selectedIcon: Icon(Icons.people),
          label: 'Users',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book),
          label: 'Courses',
        ),
        NavigationDestination(
          icon: Icon(Icons.class_outlined),
          selectedIcon: Icon(Icons.class_),
          label: 'Classes',
        ),
        NavigationDestination(
          icon: Icon(Icons.access_time_outlined),
          selectedIcon: Icon(Icons.access_time),
          label: 'Shifts',
        ),
      ],
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

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Builder(
      builder: (context) => Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.responsiveBorderRadius(context, 16),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(
            ResponsiveUtils.responsiveSpacing(context, 16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: ResponsiveUtils.responsiveIconSize(context, 32),
                color: color,
              ),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 8)),
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 24),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 4)),
              Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 12),
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementCard(String title, IconData icon, VoidCallback onTap) {
    return Builder(
      builder: (context) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.responsiveBorderRadius(context, 12),
          ),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: ResponsiveUtils.responsiveIconSize(context, 24),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: ResponsiveUtils.responsiveIconSize(context, 16),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Builder(
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: ResponsiveUtils.responsiveSpacing(context, 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
