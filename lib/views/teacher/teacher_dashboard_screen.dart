import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/test_controller.dart';
import '../../controllers/student_controller.dart';
import '../../controllers/course_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart';
import '../../app/responsive/responsive_utils.dart';
import '../../app/responsive/adaptive_navigation.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final TestController _testController = Get.put(TestController());
  final StudentController _studentController = Get.put(StudentController());
  final CourseController _courseController = Get.put(CourseController());

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _testController.fetchTestsByTeacher(
        teacherId: _authController.currentUser!.id!,
      ),
      _studentController.fetchActiveStudents(),
      _courseController.fetchCourses(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutConfirmation(context);
            },
          ),
        ],
      ),
      body: _buildBody(),
      drawer: _buildNavigationDrawer(context),
      bottomNavigationBar: ResponsiveUtils.isMobile(context)
          ? _buildBottomNavigationBar()
          : null,
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
        break;
      case 1:
        Get.toNamed(Routes.TEACHER_TESTS);
        break;
      case 2:
        Get.toNamed('/teacher-courses');
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

  Widget _buildBody() {
    return RefreshIndicator(
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
                      _authController.currentUser?.name ?? 'Teacher',
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
            Obx(
              () => Row(
                children: [
                  _buildStatCard(
                    'Total Tests',
                    _testController.tests.length.toString(),
                    Icons.quiz,
                    AppTheme.primaryColor,
                  ),
                  SizedBox(
                    width: ResponsiveUtils.responsiveSpacing(context, 12),
                  ),
                  _buildStatCard(
                    'Total Students',
                    _studentController.students.length.toString(),
                    Icons.people,
                    AppTheme.successColor,
                  ),
                ],
              ),
            ),
            SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 24)),
            Text(
              'Courses',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
            Obx(
              () => _courseController.courses.isEmpty
                  ? _buildEmptyCard('No courses available')
                  : _buildCoursesList(),
            ),
            SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 24)),
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
            _buildQuickAction('Create Test', Icons.add_circle_outline, () {
              Get.toNamed(Routes.CREATE_TEST);
            }),
            SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 12)),
            _buildQuickAction('View Students', Icons.people_outline, () {
              Get.toNamed(Routes.TEACHER_STUDENTS);
            }),
            SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 12)),
            _buildQuickAction('View Results', Icons.assessment_outlined, () {
              Get.toNamed(Routes.TEACHER_RESULTS);
            }),
            SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 12)),
            _buildQuickAction('Manage Courses', Icons.menu_book, () {
              Get.toNamed('/teacher-courses');
            }),
            SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 24)),
            Text(
              'Recent Tests',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
            Obx(
              () => _testController.tests.isEmpty
                  ? _buildEmptyCard('No tests created yet')
                  : _buildRecentTests(),
            ),
          ],
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
    return Builder(
      builder: (context) => Expanded(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(
              ResponsiveUtils.responsiveSpacing(context, 12),
            ),
            child: Column(
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

  Widget _buildQuickAction(String title, IconData icon, VoidCallback onTap) {
    return Builder(
      builder: (context) => Card(
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

  Widget _buildRecentTests() {
    return Builder(
      builder: (context) => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _testController.tests.length > 5
            ? 5
            : _testController.tests.length,
        itemBuilder: (context, index) {
          final test = _testController.tests[index];
          return Card(
            margin: EdgeInsets.only(
              bottom: ResponsiveUtils.responsiveSpacing(context, 8),
            ),
            child: ListTile(
              title: Text(
                test.title,
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                ),
              ),
              subtitle: Text(
                '${test.questionCount} Questions • ${test.status.toUpperCase()}',
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                ),
              ),
              trailing: Chip(
                label: Text(
                  test.status.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                backgroundColor: _getStatusColor(test.status),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCoursesList() {
    return Builder(
      builder: (context) => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _courseController.courses.length,
        itemBuilder: (context, index) {
          final course = _courseController.courses[index];
          return Card(
            margin: EdgeInsets.only(
              bottom: ResponsiveUtils.responsiveSpacing(context, 8),
            ),
            child: ListTile(
              title: Text(
                course.name,
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                ),
              ),
              subtitle: course.description != null
                  ? Text(
                      course.description!,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          14,
                        ),
                      ),
                    )
                  : null,
              trailing: Icon(
                course.isActive ? Icons.check_circle : Icons.cancel,
                color: course.isActive
                    ? AppTheme.successColor
                    : AppTheme.errorColor,
                size: ResponsiveUtils.responsiveIconSize(context, 24),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Builder(
      builder: (context) => Card(
        child: Padding(
          padding: EdgeInsets.all(
            ResponsiveUtils.responsiveSpacing(context, 24),
          ),
          child: Center(
            child: Text(
              message,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
              ),
            ),
          ),
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
}
