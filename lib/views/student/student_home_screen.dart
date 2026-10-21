import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/enrollment_controller.dart';
import '../../controllers/test_controller.dart';
import '../../controllers/course_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart' as theme;
import '../../app/responsive/responsive_utils.dart';
import '../../app/responsive/adaptive_navigation.dart';
import 'notifications_screen.dart';

// ignore_for_file: deprecated_member_use

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final EnrollmentController _enrollmentController = Get.put(
    EnrollmentController(),
  );
  final TestController _testController = Get.put(TestController());
  final CourseController _courseController = Get.put(CourseController());
  final NotificationController _notificationController = Get.put(NotificationController());

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Delay data loading to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (_authController.currentUser != null) {
      await _enrollmentController.fetchStudentEnrollments(
        studentId: _authController.currentUser!.id!,
      );
      await _courseController.fetchCourses();

      // Extract enrolled course IDs (only active enrollments)
      final enrolledCourseIds = _enrollmentController.enrollments
          .where((e) => e.status == 'active')
          .map((e) => e.courseId)
          .toSet()
          .toList();

      // Fetch published tests only for enrolled courses
      if (enrolledCourseIds.isNotEmpty) {
        await _testController.fetchPublishedTestsByCourseIds(
          courseIds: enrolledCourseIds,
        );
      } else {
        // No enrolled courses - clear tests
        _testController.tests.clear();
      }

      // Refresh notifications after enrollments are loaded
      await _notificationController.refreshNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AppBar(
        title: const Text('RAINTECH'),
        elevation: 0,
        actions: [
          Obx(
            () => Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    Get.to(() => const NotificationsScreen());
                  },
                  tooltip: 'Notifications',
                ),
                if (_notificationController.studentUnreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                        child: Text(
                          _notificationController.studentUnreadCount > 99
                              ? '99+'
                              : _notificationController.studentUnreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutConfirmation(context);
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _buildBody(),
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
              theme.AppTheme.primaryColor,
              theme.AppTheme.secondaryColor,
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
                    theme.AppTheme.primaryColor,
                    theme.AppTheme.secondaryColor,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.school, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'RAINTECH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 24),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Text(
                      _authController.currentUser?.name ?? 'Student',
                      style: TextStyle(fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.home, 'Dashboard', 0),
            _buildDrawerItem(Icons.menu_book, 'Courses', 1),
            _buildDrawerItem(Icons.quiz, 'Tests', 2),
            _buildDrawerItem(Icons.assessment, 'Results', 3),
            _buildDrawerItem(Icons.emoji_events, 'Leaderboard', 4),
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
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
        _handleNavigation(index);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book),
          label: 'Courses',
        ),
        NavigationDestination(
          icon: Icon(Icons.quiz_outlined),
          selectedIcon: Icon(Icons.quiz),
          label: 'Tests',
        ),
        NavigationDestination(
          icon: Icon(Icons.assessment_outlined),
          selectedIcon: Icon(Icons.assessment),
          label: 'Results',
        ),
        NavigationDestination(
          icon: Icon(Icons.emoji_events_outlined),
          selectedIcon: Icon(Icons.emoji_events),
          label: 'Leaderboard',
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
        // Already on Home, do nothing
        break;
      case 1:
        Get.toNamed('/student-courses');
        break;
      case 2:
        Get.toNamed(Routes.STUDENT_TESTS);
        break;
      case 3:
        Get.toNamed(Routes.STUDENT_RESULTS);
        break;
      case 4:
        Get.toNamed('/leaderboard');
        break;
      case 5:
        Get.toNamed(Routes.STUDENT_PROFILE);
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
                backgroundColor: theme.AppTheme.errorColor,
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
      color: theme.AppTheme.primaryColor,
      child: SingleChildScrollView(
        padding: ResponsiveUtils.responsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              padding: EdgeInsets.all(
                ResponsiveUtils.responsiveSpacing(context, 28),
              ),
              decoration: BoxDecoration(
                gradient: theme.AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.responsiveBorderRadius(context, 24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.AppTheme.primaryColor.withValues(alpha: 0.35),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WELCOME BACK',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 12),
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.85),
                      letterSpacing: 3,
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.responsiveSpacing(context, 12),
                  ),
                  Obx(
                    () => Text(
                      _authController.currentUser?.name ?? 'Student',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          28,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.responsiveSpacing(context, 16),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.responsiveSpacing(
                        context,
                        20,
                      ),
                      vertical: ResponsiveUtils.responsiveSpacing(context, 10),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.responsiveBorderRadius(context, 24),
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.school,
                          color: Colors.white,
                          size: ResponsiveUtils.responsiveIconSize(context, 22),
                        ),
                        SizedBox(
                          width: ResponsiveUtils.responsiveSpacing(context, 10),
                        ),
                        Text(
                          'Student Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveUtils.responsiveFontSize(context, 15),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 32)),

            // My Courses Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Courses',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
                    fontWeight: FontWeight.bold,
                    color: theme.AppTheme.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed('/student-courses'),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: theme.AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
            Obx(
              () => _enrollmentController.isLoading.value
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _enrollmentController.enrollments.isEmpty
                  ? _buildEmptyCard('No courses enrolled yet')
                  : _buildCoursesList(),
            ),
            SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 32)),

            // Available Courses Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Courses',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
                    fontWeight: FontWeight.bold,
                    color: theme.AppTheme.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed('/student-courses'),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: theme.AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
            Obx(
              () => _courseController.isLoading.value
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _buildAvailableCourses(),
            ),
            SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 32)),

            // Available Tests Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Tests',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
                    fontWeight: FontWeight.bold,
                    color: theme.AppTheme.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed(Routes.STUDENT_TESTS),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: theme.AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
            Obx(
              () => _testController.isLoading.value
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _testController.tests.isEmpty
                  ? _buildEmptyCard('No tests available')
                  : _buildTestsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesList() {
    // Filter out rejected enrollments
    final validEnrollments = _enrollmentController.enrollments
        .where((e) => e.status != 'rejected')
        .toList();

    if (validEnrollments.isEmpty) {
      return _buildEmptyCard('No courses enrolled yet');
    }

    return Builder(
      builder: (context) => SizedBox(
        height: ResponsiveUtils.responsiveSpacing(context, 180),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: validEnrollments.length,
          itemBuilder: (context, index) {
            final enrollment = validEnrollments[index];
            final course = _courseController.getCourseById(enrollment.courseId);
            final isPending = enrollment.status == 'pending';

            return InkWell(
              onTap: () => Get.toNamed('/student-courses'),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.responsiveBorderRadius(context, 16),
              ),
              splashColor: theme.AppTheme.primaryColor.withValues(alpha: 0.1),
              child: Container(
                width: ResponsiveUtils.responsiveSpacing(context, 200),
                margin: EdgeInsets.only(
                  right: ResponsiveUtils.responsiveSpacing(context, 16),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isPending
                        ? [
                            Colors.orange.withValues(alpha: 0.1),
                            Colors.amber.withValues(alpha: 0.1),
                          ]
                        : [
                            theme.AppTheme.primaryColor.withValues(alpha: 0.1),
                            theme.AppTheme.secondaryColor.withValues(alpha: 0.1),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.responsiveBorderRadius(context, 16),
                  ),
                  border: Border.all(
                    color: isPending
                        ? Colors.orange.withValues(alpha: 0.3)
                        : theme.AppTheme.primaryColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.responsiveSpacing(context, 20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(
                              ResponsiveUtils.responsiveSpacing(context, 12),
                            ),
                            decoration: BoxDecoration(
                              color: isPending
                                  ? Colors.orange.withValues(alpha: 0.2)
                                  : theme.AppTheme.primaryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(
                                ResponsiveUtils.responsiveBorderRadius(context, 12),
                              ),
                            ),
                            child: Icon(
                              isPending ? Icons.pending : Icons.menu_book,
                              color: isPending ? Colors.orange : theme.AppTheme.primaryColor,
                              size: ResponsiveUtils.responsiveIconSize(context, 24),
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveUtils.responsiveSpacing(context, 16),
                          ),
                          Text(
                            course?.name ?? 'Unknown Course',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.responsiveFontSize(
                                context,
                                16,
                              ),
                              fontWeight: FontWeight.bold,
                              color: theme.AppTheme.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            height: ResponsiveUtils.responsiveSpacing(context, 8),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveUtils.responsiveSpacing(
                                context,
                                12,
                              ),
                              vertical: ResponsiveUtils.responsiveSpacing(context, 6),
                            ),
                            decoration: BoxDecoration(
                              color: isPending
                                  ? Colors.orange.withValues(alpha: 0.1)
                                  : theme.AppTheme.successColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                ResponsiveUtils.responsiveBorderRadius(context, 8),
                              ),
                            ),
                            child: Text(
                              isPending ? 'Pending' : 'Enrolled',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.responsiveFontSize(
                                  context,
                                  12,
                                ),
                                fontWeight: FontWeight.w600,
                                color: isPending ? Colors.orange : theme.AppTheme.successColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (course == null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () async {
                            final confirmed = await Get.dialog<bool>(
                              AlertDialog(
                                title: const Text('Delete Enrollment'),
                                content: const Text('Are you sure you want to delete this enrollment?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(result: false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Get.back(result: true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.AppTheme.errorColor,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              final success = await _enrollmentController.deleteEnrollment(
                                enrollmentId: enrollment.id!,
                              );
                              if (success) {
                                Get.snackbar(
                                  'Success',
                                  'Enrollment deleted successfully',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: theme.AppTheme.successColor,
                                  colorText: Colors.white,
                                );
                                _loadData();
                              }
                            }
                          },
                          tooltip: 'Delete',
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvailableCourses() {
    final enrolledCourseIds = _enrollmentController.enrollments
        .map((e) => e.courseId)
        .toSet();
    final availableCourses = _courseController.courses
        .where((course) => !enrolledCourseIds.contains(course.id))
        .toList();

    if (availableCourses.isEmpty) {
      return _buildEmptyCard('No new courses available');
    }

    return Builder(
      builder: (context) => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: availableCourses.length,
        itemBuilder: (context, index) {
          final course = availableCourses[index];
          return InkWell(
            onTap: () => Get.toNamed('/student-courses'),
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.responsiveBorderRadius(context, 16),
            ),
            splashColor: theme.AppTheme.primaryColor.withValues(alpha: 0.1),
            child: Container(
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
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(
                  ResponsiveUtils.responsiveSpacing(context, 20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.responsiveSpacing(context, 16),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.AppTheme.primaryColor.withValues(alpha: 0.1),
                            theme.AppTheme.secondaryColor.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.responsiveBorderRadius(context, 12),
                        ),
                      ),
                      child: Icon(
                        Icons.menu_book,
                        color: theme.AppTheme.primaryColor,
                        size: ResponsiveUtils.responsiveIconSize(context, 28),
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveUtils.responsiveSpacing(context, 16),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.name,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.responsiveFontSize(
                                context,
                                16,
                              ),
                              fontWeight: FontWeight.bold,
                              color: theme.AppTheme.textPrimary,
                            ),
                          ),
                          if (course.description != null) ...[
                            SizedBox(
                              height: ResponsiveUtils.responsiveSpacing(
                                context,
                                4,
                              ),
                            ),
                            Text(
                              course.description!,
                              style: TextStyle(
                                fontSize: ResponsiveUtils.responsiveFontSize(
                                  context,
                                  14,
                                ),
                                color: theme.AppTheme.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveUtils.responsiveSpacing(context, 16),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final success = await _enrollmentController
                            .createEnrollment(
                              studentId: _authController.currentUser!.id!,
                              courseId: course.id!,
                              shiftId: 'default',
                            );
                        if (success) {
                          Get.snackbar(
                            'Success',
                            'Enrolled in ${course.name}',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: theme.AppTheme.successColor,
                            colorText: Colors.white,
                          );
                          _loadData();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.responsiveSpacing(
                            context,
                            24,
                          ),
                          vertical: ResponsiveUtils.responsiveSpacing(
                            context,
                            12,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.responsiveBorderRadius(context, 12),
                          ),
                        ),
                      ),
                      child: const Text('Enroll'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTestsList() {
    // Additional safety check: only show tests if student has active enrollments
    final hasActiveEnrollments = _enrollmentController.enrollments
        .any((e) => e.status == 'active');

    if (!hasActiveEnrollments) {
      return _buildEmptyCard('No tests available (enroll in a course first)');
    }

    return Builder(
      builder: (context) => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _testController.tests.length,
        itemBuilder: (context, index) {
          final test = _testController.tests[index];
          return InkWell(
            onTap: () => Get.toNamed(Routes.STUDENT_TESTS),
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.responsiveBorderRadius(context, 10),
            ),
            splashColor: theme.AppTheme.primaryColor.withValues(alpha: 0.1),
            child: Container(
              margin: EdgeInsets.only(
                bottom: ResponsiveUtils.responsiveSpacing(context, 8),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.responsiveBorderRadius(context, 10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(
                  ResponsiveUtils.responsiveSpacing(context, 10),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.responsiveSpacing(context, 10),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.AppTheme.accentColor.withValues(alpha: 0.1),
                            theme.AppTheme.primaryColor.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.responsiveBorderRadius(context, 8),
                        ),
                      ),
                      child: Icon(
                        Icons.quiz,
                        color: theme.AppTheme.accentColor,
                        size: ResponsiveUtils.responsiveIconSize(context, 20),
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveUtils.responsiveSpacing(context, 10),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            test.title,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.responsiveFontSize(
                                context,
                                13,
                              ),
                              fontWeight: FontWeight.bold,
                              color: theme.AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            height: ResponsiveUtils.responsiveSpacing(context, 4),
                          ),
                          Row(
                            children: [
                              _buildTestInfoChip(
                                Icons.help_outline,
                                '${test.questionCount} Q',
                              ),
                              SizedBox(
                                width: ResponsiveUtils.responsiveSpacing(
                                  context,
                                  4,
                                ),
                              ),
                              _buildTestInfoChip(
                                Icons.access_time,
                                '${test.durationMinutes}m',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveUtils.responsiveSpacing(context, 10),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.toNamed(Routes.TEST_SCREEN, arguments: test);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.AppTheme.accentColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.responsiveSpacing(
                            context,
                            12,
                          ),
                          vertical: ResponsiveUtils.responsiveSpacing(
                            context,
                            6,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.responsiveBorderRadius(context, 6),
                          ),
                        ),
                        minimumSize: Size(0, ResponsiveUtils.responsiveSpacing(context, 30)),
                      ),
                      child: Text(
                        'Start',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.responsiveFontSize(context, 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTestInfoChip(IconData icon, String label) {
    return Builder(
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.responsiveSpacing(context, 6),
          vertical: ResponsiveUtils.responsiveSpacing(context, 3),
        ),
        decoration: BoxDecoration(
          color: theme.AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.responsiveBorderRadius(context, 4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: ResponsiveUtils.responsiveIconSize(context, 10),
              color: theme.AppTheme.textSecondary,
            ),
            SizedBox(width: ResponsiveUtils.responsiveSpacing(context, 3)),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 10),
                fontWeight: FontWeight.w500,
                color: theme.AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Builder(
      builder: (context) => Container(
        padding: EdgeInsets.all(ResponsiveUtils.responsiveSpacing(context, 40)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.responsiveBorderRadius(context, 16),
          ),
          border: Border.all(color: theme.AppTheme.dividerColor, width: 2),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: ResponsiveUtils.responsiveIconSize(context, 64),
                color: theme.AppTheme.textSecondary.withValues(alpha: 0.5),
              ),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
              Text(
                message,
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                  color: theme.AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
