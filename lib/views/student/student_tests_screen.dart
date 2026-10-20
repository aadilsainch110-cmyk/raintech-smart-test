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
  State<StudentTestsScreen> createState() => _StudentTestsScreenState();
}

class _StudentTestsScreenState extends State<StudentTestsScreen> {
  final TestController _testController = Get.put(TestController());
  final AuthController _authController = Get.find<AuthController>();
  final AttemptController _attemptController = Get.put(AttemptController());
  final CourseController _courseController = Get.put(CourseController());
  final EnrollmentController _enrollmentController = Get.put(EnrollmentController());

  final RxMap<String, bool> _attemptedTests = <String, bool>{}.obs;
  final RxBool _isCheckingAttempts = false.obs;
  final RxList<String> _enrolledCourseIds = <String>[].obs;

  @override
  void initState() {
    super.initState();

    // Fetch published tests and courses when screen opens.
    _loadData();

    // Listen to test changes and check attempted status
    ever(_testController.tests, (tests) {
      if (tests.isNotEmpty && !_isCheckingAttempts.value) {
        _checkAttemptedTests();
      }
    });
  }

  Future<void> _loadData() async {
    try {
      // Fetch student's enrollments first
      if (_authController.currentUser != null) {
        await _enrollmentController.fetchStudentEnrollments(
          studentId: _authController.currentUser!.id!,
        );

        // Extract enrolled course IDs (only active enrollments)
        _enrolledCourseIds.value = _enrollmentController.enrollments
            .where((e) => e.status == 'active')
            .map((e) => e.courseId)
            .toSet()
            .toList();
      }

      // Fetch courses
      await _courseController.fetchCourses();

      // Fetch published tests for enrolled courses only
      if (_enrolledCourseIds.isNotEmpty) {
        await _testController.fetchPublishedTestsByCourseIds(
          courseIds: _enrolledCourseIds,
        );
      } else {
        // No enrolled courses - clear tests
        _testController.tests.clear();
      }

      // Check attempted status after loading tests
      if (_testController.tests.isNotEmpty) {
        await _checkAttemptedTests();
      }
    } catch (e) {
      print('DEBUG: Error loading available tests: $e');
      Get.snackbar(
        'Error',
        'Failed to load available tests. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.AppTheme.errorColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _checkAttemptedTests() async {
    if (_isCheckingAttempts.value) {
      return;
    }

    _isCheckingAttempts.value = true;

    try {
      if (_authController.currentUser != null) {
        await _attemptController.fetchAttemptsByStudent(
          studentId: _authController.currentUser!.id!,
        );

        // Only check attempted status for tests that are actually available
        // (after filtering by enrolled courses)
        for (final test in _testController.tests) {
          final hasAttempted = await _attemptController.hasStudentAttemptedTest(
            testId: test.id!,
            studentId: _authController.currentUser!.id!,
          );
          _attemptedTests[test.id!] = hasAttempted;
        }
      }
    } finally {
      _isCheckingAttempts.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Available Tests'),
        centerTitle: false,
      ),
      body: Obx(() {
        // Loading state
        if (_testController.isLoading.value || _enrollmentController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Tests are already filtered by enrolled courses at the controller level
        // No need for additional client-side filtering
        final availableTests = _testController.tests;

        // Empty state
        if (availableTests.isEmpty) {
          return _buildEmptyState(context);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildResponsiveTestList(
                context,
                constraints.maxWidth,
                availableTests,
              ),
            );
          },
        );
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // RESPONSIVE TEST LIST
  // ---------------------------------------------------------------------------

  Widget _buildResponsiveTestList(
      BuildContext context,
      double availableWidth,
      List<dynamic> availableTests,
      ) {
    // Mobile
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

    // Tablet
    if (availableWidth < 1000) {
      const double spacing = 16;

      final cardWidth = (availableWidth - spacing) / 2;

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: List.generate(
          availableTests.length,
              (index) {
            final test = availableTests[index];

            return _buildTestCard(
              context,
              test,
              width: cardWidth,
            );
          },
        ),
      );
    }

    // Laptop / Desktop
    const double spacing = 20;

    final cardWidth = (availableWidth - (spacing * 2)) / 3;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: List.generate(
        availableTests.length,
            (index) {
          final test = availableTests[index];

          return _buildTestCard(
            context,
            test,
            width: cardWidth,
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TEST CARD
  // ---------------------------------------------------------------------------

  Widget _buildTestCard(
      BuildContext context,
      dynamic test, {
        required double width,
      }) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------------------------------------------------------
              // TOP ICON
              // ---------------------------------------------------------------

              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: theme.AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.quiz_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              const SizedBox(height: 14),

              // ---------------------------------------------------------------
              // TITLE
              // ---------------------------------------------------------------

              Text(
                test.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),

              // ---------------------------------------------------------------
              // DESCRIPTION
              // ---------------------------------------------------------------

              if (test.description != null &&
                  test.description.toString().trim().isNotEmpty) ...[
                const SizedBox(height: 7),
                Text(
                  test.description.toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: theme.AppTheme.textSecondary,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // ---------------------------------------------------------------
              // COURSE NAME
              // ---------------------------------------------------------------

              Obx(() {
                final course = _courseController.courses.firstWhereOrNull(
                  (c) => c.id == test.courseId,
                );
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFC7D2FE),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.book_outlined,
                        size: 16,
                        color: Color(0xFF4F46E5),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          course?.name ?? 'Unknown Course',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // ---------------------------------------------------------------
              // TEST INFORMATION
              // ---------------------------------------------------------------

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoItem(
                    icon: Icons.help_outline_rounded,
                    label: '${test.questionCount} Questions',
                  ),

                  _buildInfoItem(
                    icon: Icons.access_time_rounded,
                    label: '${test.durationMinutes} Minutes',
                  ),

                  _buildInfoItem(
                    icon: Icons.star_outline_rounded,
                    label: '${test.totalMarks} Marks',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ---------------------------------------------------------------
              // START TEST BUTTON
              // ---------------------------------------------------------------

              SizedBox(
                width: double.infinity,
                height: 46,
                child: Obx(() {
                  final isAttempted = _attemptedTests[test.id] ?? false;
                  final isChecking = _isCheckingAttempts.value && _attemptedTests[test.id] == null;

                  return ElevatedButton.icon(
                    onPressed: isAttempted || isChecking
                        ? null
                        : () async {
                            await Get.toNamed(
                              Routes.TEST_SCREEN,
                              arguments: test,
                            );
                            // Refresh attempt status when returning from test screen
                            await _checkAttemptedTests();
                          },
                    icon: Icon(
                      isChecking
                          ? Icons.hourglass_empty
                          : isAttempted
                              ? Icons.check_circle
                              : Icons.play_arrow_rounded,
                      size: 22,
                    ),
                    label: Text(
                      isChecking
                          ? 'Checking...'
                          : isAttempted
                              ? 'Test Submitted'
                              : 'Start Test',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: isAttempted
                          ? Colors.green
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INFORMATION ITEM
  // ---------------------------------------------------------------------------

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE3E8EF),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 19,
            color: const Color(0xFF2563EB),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EMPTY STATE
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState(BuildContext context) {
    final hasEnrollments = _enrolledCourseIds.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                hasEnrollments ? Icons.quiz_outlined : Icons.school_outlined,
                size: 48,
                color: theme.AppTheme.textSecondary,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              hasEnrollments ? 'No tests available' : 'No course enrollments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.AppTheme.textSecondary,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              hasEnrollments
                  ? 'There are no published tests for your enrolled courses right now.'
                  : 'You are not enrolled in any course. Please enroll in a course to access tests.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.AppTheme.textSecondary,
              ),
            ),

            if (!hasEnrollments) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Get.toNamed('/student-courses');
                },
                icon: const Icon(Icons.menu_book),
                label: const Text('Enroll in a Course'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}