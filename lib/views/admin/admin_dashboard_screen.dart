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
import '../../app/routes/app_routes.dart';

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

  final Set<int> _expandedItems = <int>{};

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
            Container(
              padding: EdgeInsets.all(
                ResponsiveUtils.responsiveSpacing(context, 24),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.1),
                    AppTheme.secondaryColor.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.responsiveBorderRadius(context, 20),
                ),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WELCOME',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 11),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                      letterSpacing: 3,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 8)),
                  Obx(
                    () => Text(
                      _authController.currentUser?.name ?? 'Admin',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.responsiveFontSize(context, 26),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 24)),
              GridView.count(
                crossAxisCount: ResponsiveUtils.getGridColumns(context),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: ResponsiveUtils.responsiveSpacing(context, 12),
                crossAxisSpacing: ResponsiveUtils.responsiveSpacing(context, 12),
                childAspectRatio: ResponsiveUtils.isMobile(context) ? 1.0 : 1.1,
                children: [
                  Obx(() => _buildStatCard(
                    'Users',
                    _adminController.users.length.toString(),
                    Icons.people,
                    AppTheme.primaryColor,
                    onTap: () => _showUsersDialog(),
                  )),
                  Obx(() => _buildStatCard(
                    'Courses',
                    _courseController.courses.length.toString(),
                    Icons.menu_book,
                    AppTheme.successColor,
                    onTap: () => Get.toNamed('/courses-management'),
                  )),
                  Obx(() => _buildStatCard(
                    'Tests',
                    _testController.tests.length.toString(),
                    Icons.quiz,
                    AppTheme.warningColor,
                    onTap: () => _showTestsDialog(),
                  )),
                  Obx(() => _buildStatCard(
                    'Classes',
                    _adminController.classes.length.toString(),
                    Icons.class_,
                    AppTheme.accentColor,
                    onTap: () => Get.toNamed('/classes-management'),
                  )),
                ],
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
                'Tests Management',
                Icons.quiz_outlined,
                () => _showTestsDialog(),
              ),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 12)),
              _buildManagementCard(
                'Shifts Management',
                Icons.access_time,
                () => Get.toNamed('/shifts-management'),
              ),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 12)),
              _buildManagementCard(
                'Enrollment Approvals',
                Icons.approval,
                () => Get.toNamed('/enrollment-approval'),
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
                () => _buildStatRow(
                  'Students',
                  _studentController.students.length.toString(),
                ),
              ),
              Obx(
                () => _buildStatRow(
                  'Teachers',
                  _teacherController.teachers.length.toString(),
                ),
              ),
              Obx(
                () => _buildStatRow(
                  'Active Tests',
                  _testController.tests
                      .where((t) => t.status == 'published')
                      .length
                      .toString(),
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
            _buildExpandableDrawerItem(Icons.people, 'Users', 1),
            _buildExpandableDrawerItem(Icons.menu_book, 'Courses', 2),
            _buildDrawerItem(Icons.class_, 'Classes', 3),
            _buildDrawerItem(Icons.quiz, 'Tests', 4),
            _buildDrawerItem(Icons.access_time, 'Shifts', 5),
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
      onTap: () {
        if (ResponsiveUtils.isMobile(context)) {
          Navigator.pop(context);
        }
        // Handle navigation based on index
        switch (index) {
          case 0:
            break;
          case 3:
            Get.toNamed('/classes-management');
            break;
          case 4:
            _showTestsDialog();
            break;
          case 5:
            Get.toNamed('/shifts-management');
            break;
        }
      },
    );
  }

  Widget _buildExpandableDrawerItem(IconData icon, String label, int index) {
    final isExpanded = _expandedItems.contains(index);

    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
          trailing: Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: Colors.white,
          ),
          onTap: () {
            setState(() {
              if (_expandedItems.contains(index)) {
                _expandedItems.remove(index);
              } else {
                _expandedItems.add(index);
              }
            });
          },
        ),
        if (isExpanded)
          Padding(
            padding: EdgeInsets.only(left: ResponsiveUtils.responsiveSpacing(context, 20)),
            child: Column(
              children: index == 1
                  ? [
                      // Users submenu
                      ListTile(
                        leading: const Icon(Icons.people_outline, color: Colors.white70, size: 20),
                        title: Text(
                          'All Users',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        onTap: () {
                          if (ResponsiveUtils.isMobile(context)) {
                            Navigator.pop(context);
                          }
                          _showUsersDialog();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.approval, color: Colors.white70, size: 20),
                        title: Text(
                          'Approvals',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        onTap: () {
                          if (ResponsiveUtils.isMobile(context)) {
                            Navigator.pop(context);
                          }
                          _showApprovalsDialog();
                        },
                      ),
                    ]
                  : index == 2
                  ? [
                      // Courses submenu
                      ListTile(
                        leading: const Icon(Icons.edit, color: Colors.white70, size: 20),
                        title: Text(
                          'Course Management',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        onTap: () {
                          if (ResponsiveUtils.isMobile(context)) {
                            Navigator.pop(context);
                          }
                          Get.toNamed('/courses-management');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.approval, color: Colors.white70, size: 20),
                        title: Text(
                          'Enrollment Approvals',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        onTap: () {
                          if (ResponsiveUtils.isMobile(context)) {
                            Navigator.pop(context);
                          }
                          Get.toNamed('/enrollment-approval');
                        },
                      ),
                    ]
                  : [],
            ),
          ),
      ],
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
          icon: Icon(Icons.quiz_outlined),
          selectedIcon: Icon(Icons.quiz),
          label: 'Tests',
        ),
        NavigationDestination(
          icon: Icon(Icons.access_time_outlined),
          selectedIcon: Icon(Icons.access_time),
          label: 'Shifts',
        ),
      ],
      onDestinationSelected: (index) {
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
            _showTestsDialog();
            break;
          case 5:
            Get.toNamed('/shifts-management');
            break;
        }
      },
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
    Color color, {
    VoidCallback? onTap,
  }) {
    return Builder(
      builder: (context) => Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.responsiveBorderRadius(context, 16),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.responsiveBorderRadius(context, 16),
          ),
          splashColor: color.withValues(alpha: 0.1),
          highlightColor: color.withValues(alpha: 0.05),
          child: Padding(
            padding: EdgeInsets.all(
              ResponsiveUtils.responsiveSpacing(context, 12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: ResponsiveUtils.responsiveIconSize(context, 28),
                  color: color,
                ),
                SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 6)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 3)),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 11),
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
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

  void _showUsersDialog({int initialTabIndex = 0}) {
    Get.dialog(
      AlertDialog(
        title: const Text('All Users'),
        content: SizedBox(
          width: double.maxFinite,
          height: 600,
          child: DefaultTabController(
            length: 2,
            initialIndex: initialTabIndex,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Teachers'),
                    Tab(text: 'Students'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildTeachersTab(),
                      _buildStudentsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showApprovalsDialog({int initialTabIndex = 0}) {
    Get.dialog(
      AlertDialog(
        title: const Text('User Approvals'),
        content: SizedBox(
          width: double.maxFinite,
          height: 600,
          child: DefaultTabController(
            length: 3,
            initialIndex: initialTabIndex,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Pending'),
                    Tab(text: 'Approved'),
                    Tab(text: 'Rejected'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildPendingApprovalsTab(),
                      _buildApprovedUsersTab(),
                      _buildRejectedUsersTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showTestsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('All Tests'),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: Obx(
            () => _testController.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : _testController.tests.isEmpty
                    ? const Center(child: Text('No tests available'))
                    : ListView.builder(
                        itemCount: _testController.tests.length,
                        itemBuilder: (context, index) {
                          final test = _testController.tests[index];
                          final course = _courseController.getCourseById(test.courseId);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(test.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Course: ${course?.name ?? test.courseId}'),
                                  Text('Questions: ${test.questionCount}'),
                                  Text('Duration: ${test.durationMinutes} minutes'),
                                  Text('Total Marks: ${test.totalMarks}'),
                                  Text('Status: ${test.status}'),
                                  if (test.createdAt != null)
                                    Text('Created: ${_formatDate(test.createdAt!)}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Chip(
                                    label: Text(test.status),
                                    backgroundColor: test.status == 'published'
                                        ? Colors.green
                                        : Colors.orange,
                                    labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      final confirmed = await Get.dialog<bool>(
                                        AlertDialog(
                                          title: const Text('Delete Test'),
                                          content: Text('Delete "${test.title}"? This will also delete all questions and attempts for this test.'),
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
                                        final success = await _testController.deleteTest(
                                          testId: test.id!,
                                        );
                                        if (success) {
                                          Get.snackbar(
                                            'Success',
                                            'Test deleted successfully',
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: AppTheme.successColor,
                                            colorText: Colors.white,
                                          );
                                          _loadData();
                                        }
                                      }
                                    },
                                    tooltip: 'Delete',
                                  ),
                                ],
                              ),
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

  Widget _buildTeachersTab() {
    return Obx(
      () {
        final allUsers = _adminController.users;
        final teachers = allUsers.where((u) => u.role == 'teacher' && u.approvalStatus == 'approved').toList();

        if (teachers.isEmpty) {
          return const Center(child: Text('No teachers found'));
        }

        return ListView.builder(
          itemCount: teachers.length,
          itemBuilder: (context, index) {
            final teacher = teachers[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(teacher.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(teacher.email),
                    if (teacher.phone != null) Text('Phone: ${teacher.phone}'),
                    Text('Status: ${teacher.isActive ? "Active" : "Inactive"}'),
                    if (teacher.createdAt != null)
                      Text('Registered: ${_formatDate(teacher.createdAt!)}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(teacher.isActive ? 'Active' : 'Inactive'),
                      backgroundColor: teacher.isActive ? Colors.green : Colors.grey,
                      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: teacher.isActive,
                      onChanged: (value) async {
                        await _adminController.updateUser(
                          userId: teacher.id!,
                          isActive: value,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirmed = await Get.dialog<bool>(
                          AlertDialog(
                            title: const Text('Delete Teacher'),
                            content: Text('Delete ${teacher.name}? This action cannot be undone.'),
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
                          final success = await _adminController.updateUser(
                            userId: teacher.id!,
                            isActive: false,
                          );
                          if (success) {
                            Get.snackbar(
                              'Success',
                              'Teacher Deleted Successfully',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppTheme.successColor,
                              colorText: Colors.white,
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStudentsTab() {
    return Obx(
      () {
        final allUsers = _adminController.users;
        final students = allUsers.where((u) => u.role == 'student' && u.approvalStatus == 'approved').toList();

        if (students.isEmpty) {
          return const Center(child: Text('No students found'));
        }

        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(student.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.email),
                    if (student.phone != null) Text('Phone: ${student.phone}'),
                    if (student.studentId != null) Text('Student ID: ${student.studentId}'),
                    if (student.classId != null) Text('Class: ${student.classId}'),
                    Text('Status: ${student.isActive ? "Active" : "Inactive"}'),
                    if (student.createdAt != null)
                      Text('Registered: ${_formatDate(student.createdAt!)}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(student.isActive ? 'Active' : 'Inactive'),
                      backgroundColor: student.isActive ? Colors.green : Colors.grey,
                      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: student.isActive,
                      onChanged: (value) async {
                        await _adminController.updateUser(
                          userId: student.id!,
                          isActive: value,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirmed = await Get.dialog<bool>(
                          AlertDialog(
                            title: const Text('Delete Student'),
                            content: Text('Delete ${student.name}? This action cannot be undone.'),
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
                          final success = await _adminController.updateUser(
                            userId: student.id!,
                            isActive: false,
                          );
                          if (success) {
                            Get.snackbar(
                              'Success',
                              'Student Deleted Successfully',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppTheme.successColor,
                              colorText: Colors.white,
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPendingApprovalsTab() {
    return Obx(
      () {
        final allUsers = _adminController.users;
        final pendingUsers = allUsers.where((u) => u.approvalStatus == 'pending').toList();

        if (pendingUsers.isEmpty) {
          return const Center(child: Text('No pending approvals'));
        }

        return ListView.builder(
          itemCount: pendingUsers.length,
          itemBuilder: (context, index) {
            final user = pendingUsers[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(user.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.email),
                    Text('Role: ${user.role}'),
                    if (user.phone != null) Text('Phone: ${user.phone}'),
                    if (user.studentId != null) Text('Student ID: ${user.studentId}'),
                    if (user.classId != null) Text('Class: ${user.classId}'),
                    if (user.createdAt != null)
                      Text('Registered: ${_formatDate(user.createdAt!)}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: const Text('Pending'),
                      backgroundColor: Colors.orange,
                      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () async {
                        final confirmed = await Get.dialog<bool>(
                          AlertDialog(
                            title: const Text('Approve User'),
                            content: Text('Approve ${user.name} as ${user.role}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Get.back(result: true),
                                child: const Text('Approve'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          final success = await _adminController.approveUser(userId: user.id!);
                          if (success) {
                            Get.snackbar(
                              'Success',
                              'User Approved Successfully',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppTheme.successColor,
                              colorText: Colors.white,
                            );
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () async {
                        final confirmed = await Get.dialog<bool>(
                          AlertDialog(
                            title: const Text('Reject User'),
                            content: Text('Reject ${user.name}?'),
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
                                child: const Text('Reject'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          final success = await _adminController.rejectUser(userId: user.id!);
                          if (success) {
                            Get.snackbar(
                              'Success',
                              'User Rejected',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppTheme.errorColor,
                              colorText: Colors.white,
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildApprovedUsersTab() {
    return Obx(
      () {
        final allUsers = _adminController.users;
        final approvedUsers = allUsers.where((u) => u.approvalStatus == 'approved').toList();

        if (approvedUsers.isEmpty) {
          return const Center(child: Text('No approved users'));
        }

        return ListView.builder(
          itemCount: approvedUsers.length,
          itemBuilder: (context, index) {
            final user = approvedUsers[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(user.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.email),
                    Text('Role: ${user.role}'),
                    if (user.phone != null) Text('Phone: ${user.phone}'),
                    if (user.studentId != null) Text('Student ID: ${user.studentId}'),
                    if (user.classId != null) Text('Class: ${user.classId}'),
                    Text('Status: ${user.isActive ? "Active" : "Inactive"}'),
                    if (user.createdAt != null)
                      Text('Registered: ${_formatDate(user.createdAt!)}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(user.isActive ? 'Active' : 'Inactive'),
                      backgroundColor: user.isActive ? Colors.green : Colors.grey,
                      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
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
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirmed = await Get.dialog<bool>(
                          AlertDialog(
                            title: const Text('Delete User'),
                            content: Text('Delete ${user.name}? This action cannot be undone.'),
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
                          final success = await _adminController.updateUser(
                            userId: user.id!,
                            isActive: false,
                          );
                          if (success) {
                            Get.snackbar(
                              'Success',
                              'User Deleted Successfully',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppTheme.successColor,
                              colorText: Colors.white,
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRejectedUsersTab() {
    return Obx(
      () {
        final allUsers = _adminController.users;
        final rejectedUsers = allUsers.where((u) => u.approvalStatus == 'rejected').toList();

        if (rejectedUsers.isEmpty) {
          return const Center(child: Text('No rejected users'));
        }

        return ListView.builder(
          itemCount: rejectedUsers.length,
          itemBuilder: (context, index) {
            final user = rejectedUsers[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(user.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.email),
                    Text('Role: ${user.role}'),
                    if (user.phone != null) Text('Phone: ${user.phone}'),
                    if (user.studentId != null) Text('Student ID: ${user.studentId}'),
                    if (user.classId != null) Text('Class: ${user.classId}'),
                    if (user.createdAt != null)
                      Text('Registered: ${_formatDate(user.createdAt!)}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: const Text('Rejected'),
                      backgroundColor: Colors.red,
                      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () async {
                        final confirmed = await Get.dialog<bool>(
                          AlertDialog(
                            title: const Text('Approve User'),
                            content: Text('Approve ${user.name}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Get.back(result: true),
                                child: const Text('Approve'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          final success = await _adminController.approveUser(userId: user.id!);
                          if (success) {
                            Get.snackbar(
                              'Success',
                              'User Approved Successfully',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppTheme.successColor,
                              colorText: Colors.white,
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
