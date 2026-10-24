
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/test_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/attempt_controller.dart';
import '../../controllers/course_controller.dart';
import '../../controllers/enrollment_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart' as theme;

class StudentTestsScreen extends StatefulWidget {
  const StudentTestsScreen({super.key});

  @override
  State<StudentTestsScreen> createState() =>
      _StudentTestsScreenState();
}

class _StudentTestsScreenState extends State<StudentTestsScreen> {
  final TestController _testController = Get.put(TestController());
  final AuthController _authController = Get.find<AuthController>();
  final AttemptController _attemptController = Get.put(AttemptController());
  final CourseController _courseController = Get.put(CourseController());
  final EnrollmentController _enrollmentController =
  Get.put(EnrollmentController());

  final RxMap<String, bool> _attemptedTests = <String, bool>{}.obs;
  final RxBool _isCheckingAttempts = false.obs;
  final RxList<String> _enrolledCourseIds = <String>[].obs;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    try {
      debugPrint('StudentTestsScreen: Loading available tests');

      if (_authController.currentUser != null) {
        await _enrollmentController.fetchStudentEnrollments(
          studentId: _authController.currentUser!.id!,
        );

        final enrolledIds = _enrollmentController.enrollments
            .where((e) => e.status == 'active')
            .map((e) => e.courseId)
            .toSet()
            .toList();

        _enrolledCourseIds.assignAll(enrolledIds);
      } else {
        debugPrint('No current user found');
      }

      await _courseController.fetchCourses();

      if (_enrolledCourseIds.isNotEmpty) {
        await _testController.fetchPublishedTestsByCourseIds(
          courseIds: _enrolledCourseIds,
        );
      } else {
        _testController.tests.clear();
      }

      if (_testController.tests.isNotEmpty) {
        await _checkAttemptedTests();
      }

      debugPrint(
        'Available tests loaded: ${_testController.tests.length}',
      );
    } catch (e, stackTrace) {
      debugPrint('Error loading available tests: $e');
      debugPrint('$stackTrace');

      Get.snackbar(
        'Error',
        'Failed to load available tests. Please try again.\n$e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.AppTheme.errorColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  Future<void> _checkAttemptedTests() async {
    if (_isCheckingAttempts.value) return;

    _isCheckingAttempts.value = true;

    try {
      final user = _authController.currentUser;
      if (user == null) return;

      await _attemptController.fetchAttemptsByStudent(
        studentId: user.id!,
      );

      for (final test in _testController.tests) {
        final testId = test.id;
        if (testId == null || testId.isEmpty) continue;

        final hasAttempted =
        await _attemptController.hasStudentAttemptedTest(
          testId: testId,
          studentId: user.id!,
        );

        _attemptedTests[testId] = hasAttempted;
      }
    } catch (e) {
      debugPrint('Error checking attempted tests: $e');
    } finally {
      _isCheckingAttempts.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Available Tests',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFF0D47A1),
          ),
        ),
      ),

      body: Obx(() {
        if (_testController.isLoading.value ||
            _enrollmentController.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF1565C0),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading available tests...',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        final availableTests = _testController.tests;

        if (availableTests.isEmpty) {
          return _buildEmptyState(context);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: _buildResponsiveTestList(
                    context,
                    constraints.maxWidth > 1200
                        ? 1200
                        : constraints.maxWidth,
                    availableTests,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // RESPONSIVE TEST LIST

  Widget _buildResponsiveTestList(
      BuildContext context,
      double availableWidth,
      List<dynamic> availableTests,
      ) {
    if (availableWidth < 600) {
      return Column(
        children: List.generate(
          availableTests.length,
              (index) {
            final test = availableTests[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildTestCard(
                context,
                test,
                width: availableWidth,
              ),
            );
          },
        ),
      );
    }

    final crossAxisCount = availableWidth < 1000 ? 2 : 3;
    const spacing = 16.0;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: availableWidth < 1000 ? 0.95 : 1.05,
      ),
      itemCount: availableTests.length,
      itemBuilder: (context, index) {
        final test = availableTests[index];

        return _buildTestCard(
          context,
          test,
          width: double.infinity,
        );
      },
    );
  }

  // TEST CARD

  Widget _buildTestCard(
      BuildContext context,
      dynamic test, {
        required double width,
      }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF8FAFC),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF1565C0).withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1565C0).withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.quiz_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 3,
                ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.star_border_outlined,
                    size: 16,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              test.title?.toString() ?? 'Untitled Test',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0D47A1),
                height: 1.2,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 12),

            // Test info in grid
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.help_outline,
                    value: '${test.questionCount}',
                    label: 'Questions',
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.access_time,
                    value: '${test.durationMinutes}',
                    label: 'Minutes',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.grade,
                    value: '${test.totalMarks}',
                    label: 'Marks',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Course Badge
            Obx(() {
              final course =
              _courseController.courses.firstWhereOrNull(
                    (c) => c.id == test.courseId,
              );

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.menu_book,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        course?.name ?? 'Unknown Course',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 12),

            // Start Test Button
            SizedBox(
              width: double.infinity,
              height: 40,
              child: Obx(() {
                final testId = test.id?.toString() ?? '';
                final isAttempted =
                    _attemptedTests[testId] ?? false;
                final isChecking = _isCheckingAttempts.value &&
                    !_attemptedTests.containsKey(testId);

                return ElevatedButton(
                  onPressed: isAttempted || isChecking
                      ? null
                      : () async {
                    debugPrint(
                      'Student selected test: $testId',
                    );

                    await Get.toNamed(
                      Routes.TEST_SCREEN,
                      arguments: test,
                    );

                    await _checkAttemptedTests();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                    const Color(0xFFDCE7F5),
                    disabledForegroundColor:
                    const Color(0xFF64748B),
                    shadowColor: const Color(0xFF1565C0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isChecking
                            ? Icons.hourglass_empty
                            : isAttempted
                            ? Icons.check_circle
                            : Icons.play_arrow_rounded,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isChecking
                            ? 'Checking...'
                            : isAttempted
                            ? 'Test Submitted'
                            : 'Start Test',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F8FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFDCE7F5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 14,
            color: const Color(0xFF1565C0),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D47A1),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }



  // EMPTY STATE

  Widget _buildEmptyState(BuildContext context) {
    return Obx(() {
      final hasEnrollments = _enrolledCourseIds.isNotEmpty;

      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF3FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasEnrollments
                        ? Icons.quiz_outlined
                        : Icons.school_outlined,
                    size: 46,
                    color: const Color(0xFF1565C0),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  hasEnrollments
                      ? 'No tests available'
                      : 'No course enrollments',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D47A1),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  hasEnrollments
                      ? 'There are no published tests for your enrolled courses right now.'
                      : 'You are not enrolled in any course. Please enroll in a course to access tests.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),

                if (!hasEnrollments) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.toNamed('/student-courses');
                    },
                    icon: const Icon(Icons.menu_book_rounded),
                    label: const Text('Enroll in a Course'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}
