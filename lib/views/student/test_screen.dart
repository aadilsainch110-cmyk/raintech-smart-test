import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/exam_controller.dart';
import '../../controllers/question_controller.dart';
import '../../controllers/result_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/attempt_controller.dart';
import '../../controllers/enrollment_controller.dart';
import '../../models/test_model.dart';
import '../../models/question_model.dart';
import '../../app/theme/app_theme.dart' as theme;
import '../../app/responsive/responsive_utils.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final ExamController _examController = Get.put(ExamController());
  final QuestionController _questionController = Get.put(QuestionController());
  final ResultController _resultController = Get.put(ResultController());
  final AuthController _authController = Get.find<AuthController>();
  final AttemptController _attemptController = Get.put(AttemptController());
  final EnrollmentController _enrollmentController = Get.put(EnrollmentController());

  final Rx<TestModel?> _test = Rx<TestModel?>(null);

  @override
  void initState() {
    super.initState();
    print('=== DEBUG: TestScreen initState START ===');
    print('QuestionController instance: ${_questionController.hashCode}');
    print('ExamController instance: ${_examController.hashCode}');
    print('QuestionController initial questions: ${_questionController.questions.length}');
    print('QuestionController initial isLoading: ${_questionController.isLoading.value}');
    // Delay test loading to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('=== DEBUG: PostFrameCallback executing ===');
      _loadTest();
    });
    print('=== DEBUG: TestScreen initState END ===');
  }

  Future<void> _loadTest() async {
    print('=== DEBUG: Student TestScreen _loadTest START ===');
    try {
      print('DEBUG: Getting test from Get.arguments');
      _test.value = Get.arguments as TestModel?;
      print('DEBUG: Test object received: ${_test.value != null}');
      if (_test.value != null) {
        print('Test object received from Get.arguments');
        print('Test ID: "${_test.value!.id}"');
        print('Test ID is null: ${_test.value!.id == null}');
        print('Test ID length: ${_test.value!.id?.length}');
        print('Test ID type: ${_test.value!.id.runtimeType}');
        print('Test Title: ${_test.value!.title}');
        print('Test Status: ${_test.value!.status}');
        print('Test Course ID: ${_test.value!.courseId}');
        print('Test Question Count: ${_test.value!.questionCount}');

        if (_test.value!.id == null || _test.value!.id!.isEmpty) {
          print('ERROR: Test ID is null or empty!');
          Get.snackbar(
            'Error',
            'Invalid test ID. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: theme.AppTheme.errorColor,
            colorText: Colors.white,
          );
          Get.back();
          print('=== DEBUG: _loadTest END (invalid test ID) ===');
          return;
        }

        // Verify student is enrolled in the test's course
        print('DEBUG: Fetching student enrollments...');
        print('DEBUG: Before fetch - QuestionController isLoading: ${_questionController.isLoading.value}');
        try {
          await _enrollmentController.fetchStudentEnrollments(
            studentId: _authController.currentUser!.id!,
          );
          print('DEBUG: After fetchStudentEnrollments - QuestionController isLoading: ${_questionController.isLoading.value}');
        } catch (e, stackTrace) {
          print('DEBUG: ERROR fetching enrollments: $e');
          print('DEBUG: Stack trace: $stackTrace');
          print('DEBUG: Continuing with enrollment check using cached data');
        }
        print('DEBUG: Total enrollments: ${_enrollmentController.enrollments.length}');

        final isEnrolled = _enrollmentController.enrollments.any(
          (e) => e.courseId == _test.value!.courseId && e.status == 'active',
        );
        print('DEBUG: Is enrolled in course ${_test.value!.courseId}: $isEnrolled');

        if (!isEnrolled) {
          print('DEBUG: Student not enrolled in course ${_test.value!.courseId}');
          Get.snackbar(
            'Access Denied',
            'You are not enrolled in this course. Please enroll to access this test.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: theme.AppTheme.errorColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          Get.back();
          return;
        }

        // Check if student has already attempted this test
        print('DEBUG: Checking if student already attempted this test...');
        try {
          final hasAttempted = await _attemptController.hasStudentAttemptedTest(
            testId: _test.value!.id!,
            studentId: _authController.currentUser!.id!,
          );
          print('DEBUG: Has attempted: $hasAttempted');

          if (hasAttempted) {
            print('DEBUG: Student already attempted this test');
            Get.snackbar(
              'Test Already Attempted',
              'You have already submitted this test. You cannot attempt it again.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: theme.AppTheme.errorColor,
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
            );
            Get.back();
            return;
          }
        } catch (e, stackTrace) {
          print('DEBUG: ERROR checking attempt status: $e');
          print('DEBUG: Stack trace: $stackTrace');
          print('DEBUG: Continuing despite attempt check error');
        }

        print('DEBUG: Fetching questions for test ${_test.value!.id}...');
        print('DEBUG: Test ID type: ${_test.value!.id.runtimeType}');
        print('DEBUG: Test ID length: ${_test.value!.id?.length}');
        print('DEBUG: Before clear - QuestionController questions: ${_questionController.questions.length}');
        print('DEBUG: Before clear - QuestionController isLoading: ${_questionController.isLoading.value}');
        print('DEBUG: Clearing previous questions from controller');
        _questionController.questions.clear();
        print('DEBUG: After clear - QuestionController questions: ${_questionController.questions.length}');
        print('DEBUG: Controller questions cleared. Current count: ${_questionController.questions.length}');

        print('DEBUG: Before fetchQuestionsByTest - QuestionController isLoading: ${_questionController.isLoading.value}');
        try {
          await _questionController.fetchQuestionsByTest(testId: _test.value!.id!);
          print('DEBUG: After fetchQuestionsByTest - QuestionController isLoading: ${_questionController.isLoading.value}');
        } catch (e, stackTrace) {
          print('DEBUG: EXCEPTION in fetchQuestionsByTest: $e');
          print('DEBUG: Stack trace: $stackTrace');
          print('DEBUG: Error message in controller: ${_questionController.errorMessage.value}');
        }
        print('DEBUG: fetchQuestionsByTest completed');
        print('DEBUG: Loaded ${_questionController.questions.length} questions from controller');
        print('DEBUG: Controller error message: ${_questionController.errorMessage.value}');
        print('DEBUG: Controller isLoading: ${_questionController.isLoading.value}');

        // Only start exam if questions were loaded successfully
        if (_questionController.questions.isEmpty) {
          print('DEBUG: ERROR: No questions loaded, cannot start exam');
          final errorMsg = _questionController.errorMessage.value.isNotEmpty
              ? _questionController.errorMessage.value
              : 'No questions found for this test. Please contact your teacher.';
          Get.snackbar(
            'Error',
            errorMsg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: theme.AppTheme.errorColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 6),
          );
          Get.back();
          return;
        }

        print('DEBUG: Starting exam with ${_questionController.questions.length} questions');
        _examController.startExam(test: _test.value!, testQuestions: _questionController.questions.toList());
        print('DEBUG: Exam started successfully');
        print('DEBUG: ExamController questions count: ${_examController.questions.length}');
        print('DEBUG: ==================================');
      } else {
        print('ERROR: Test object is null from Get.arguments');
        Get.snackbar(
          'Error',
          'Invalid test data. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: theme.AppTheme.errorColor,
          colorText: Colors.white,
        );
        Get.back();
      }
    } catch (e, stackTrace) {
      print('DEBUG: UNEXPECTED ERROR in _loadTest: $e');
      print('DEBUG: Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.AppTheme.errorColor,
        colorText: Colors.white,
      );
      Get.back();
    }
    print('=== DEBUG: Student TestScreen _loadTest END ===');
  }

  @override
  void dispose() {
    _examController.clearExam();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final answeredCount = _examController.answeredCount;
    final totalQuestions = _examController.questions.length;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Submit Test'),
        content: Text(
          'You have answered $answeredCount of $totalQuestions questions.\n\nDo you want to submit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final currentUser = _authController.currentUser!;

      final submitted = await _examController.submitExam(
        studentId: currentUser.id!,
      );

      if (submitted) {
        Get.snackbar(
          'Success',
          'Test Submit Successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: theme.AppTheme.successColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        if (_test.value != null) {
          final resultSaved = await _resultController.calculateAndSaveResult(
            testId: _test.value!.id!,
            studentId: currentUser.id!,
            questions: _examController.questions.toList(),
            answers: _examController.answers,
            totalMarks: _test.value!.totalMarks,
            passingMarks: _test.value!.passingMarks,
          );

          if (resultSaved) {
            await _resultController.fetchStudentResults(
              studentId: currentUser.id!,
            );
            _showResultDialog();
          } else {
            Get.snackbar(
              'Error',
              'Failed to save result. Please try again.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: theme.AppTheme.errorColor,
              colorText: Colors.white,
            );
          }
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to submit test. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: theme.AppTheme.errorColor,
          colorText: Colors.white,
        );
      }
    }
  }

  void _showResultDialog() {
    final results = _resultController.results;
    if (results.isNotEmpty) {
      final latestResult = results.last;
      Get.dialog(
        Builder(
          builder: (context) => AlertDialog(
            title: const Text('Test Submitted'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Marks'),
                Text(
                  '${latestResult.obtainedMarks}/${latestResult.totalMarks}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 32),
                    fontWeight: FontWeight.bold,
                    color: theme.AppTheme.primaryColor,
                  ),
                ),
                SizedBox(
                  height: ResponsiveUtils.responsiveSpacing(context, 16),
                ),
                Text(
                  'Percentage: ${latestResult.percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                  ),
                ),
                Text(
                  'Correct: ${latestResult.correctAnswers}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                  ),
                ),
                Text(
                  'Wrong: ${latestResult.wrongAnswers}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                  ),
                ),
                SizedBox(
                  height: ResponsiveUtils.responsiveSpacing(context, 16),
                ),
                Container(
                  padding: EdgeInsets.all(
                    ResponsiveUtils.responsiveSpacing(context, 12),
                  ),
                  decoration: BoxDecoration(
                    color: latestResult.status == 'PASS'
                        ? theme.AppTheme.successColor
                        : theme.AppTheme.errorColor,
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.responsiveBorderRadius(context, 8),
                    ),
                  ),
                  child: Text(
                    latestResult.status,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.back();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      );
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
        title: const Text('Test'),
        actions: [
          Obx(
            () => Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.responsiveSpacing(context, 16),
              ),
              alignment: Alignment.center,
              child: Text(
                _examController.formattedTime,
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (_test.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return ResponsiveUtils.buildResponsiveContent(
          context: context,
          child: _buildTestBody(),
        );
      }),
    );
  }

  Widget _buildTestBody() {
    return Obx(() {
      print('=== DEBUG: _buildTestBody rebuilding ===');
      print('QuestionController.isLoading: ${_questionController.isLoading.value}');
      print('QuestionController.questions.length: ${_questionController.questions.length}');
      print('QuestionController.errorMessage: "${_questionController.errorMessage.value}"');
      print('ExamController.questions.length: ${_examController.questions.length}');
      print('ExamController.isSubmitted: ${_examController.isSubmitted.value}');

      // Use question controller loading state only during initial load
      // Once exam starts, use exam controller state
      if (_questionController.isLoading.value && !_examController.isSubmitted.value) {
        print('DEBUG: Showing loading indicator');
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading questions...'),
            ],
          ),
        );
      }

      // Show error from question controller during initial load
      if (_questionController.errorMessage.value.isNotEmpty && _examController.questions.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Error Loading Questions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _questionController.errorMessage.value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _loadTest(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      if (_examController.questions.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz_outlined, color: Colors.grey, size: 64),
                SizedBox(height: 16),
                Text(
                  'No Questions Available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'This test has no questions yet. Please contact your teacher.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      if (_examController.isSubmitted.value) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 64),
              SizedBox(height: 16),
              Text(
                'Test Submitted Successfully',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }

      final currentIndex = _examController.currentQuestionIndex.value;
      final currentQuestion = _examController.questions[currentIndex];

      return Column(
        children: [
          _buildQuestionHeader(currentIndex),
          _buildQuestionPalette(),
          Expanded(child: _buildQuestionContent(currentQuestion)),
          _buildNavigationButtons(),
        ],
      );
    });
  }

  Widget _buildQuestionHeader(int currentIndex) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.responsiveSpacing(context, 16),
        vertical: ResponsiveUtils.responsiveSpacing(context, 12),
      ),
      color: theme.AppTheme.primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Question ${currentIndex + 1} / ${_examController.questions.length}',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
              fontWeight: FontWeight.bold,
            ),
          ),
          Obx(
            () => Text(
              'Answered: ${_examController.answeredCount}/${_examController.questions.length}',
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveUtils.responsiveFontSize(context, 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(QuestionModel question) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.responsiveSpacing(context, 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
          _buildOption('A', question.optionA, question),
          SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 8)),
          _buildOption('B', question.optionB, question),
          SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 8)),
          _buildOption('C', question.optionC, question),
          SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 8)),
          _buildOption('D', question.optionD, question),
        ],
      ),
    );
  }

  Widget _buildOption(String option, String text, QuestionModel question) {
    return Obx(() {
      final isSelected =
          _examController.getAnswerForQuestion(question.order) == option;
      return Builder(
        builder: (context) => InkWell(
          onTap: () {
            _examController.selectAnswer(option);
          },
          child: Container(
            padding: EdgeInsets.all(ResponsiveUtils.responsiveSpacing(context, 12)),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? theme.AppTheme.primaryColor : Colors.grey,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.responsiveBorderRadius(context, 8),
              ),
              color: isSelected
                  ? theme.AppTheme.primaryColor.withValues(alpha: 0.1)
                  : Colors.white,
            ),
            child: Row(
              children: [
                Container(
                  width: ResponsiveUtils.responsiveSpacing(context, 28),
                  height: ResponsiveUtils.responsiveSpacing(context, 28),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? theme.AppTheme.primaryColor
                          : Colors.grey,
                    ),
                    color: isSelected
                        ? theme.AppTheme.primaryColor
                        : Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtils.responsiveFontSize(context, 12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.responsiveSpacing(context, 12)),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildQuestionPalette() {
    return Obx(() {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.responsiveSpacing(context, 16),
          vertical: ResponsiveUtils.responsiveSpacing(context, 12),
        ),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Question Palette',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveUtils.responsiveFontSize(context, 12),
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 6)),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.12,
              ),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: ResponsiveUtils.responsiveSpacing(context, 6),
                  runSpacing: ResponsiveUtils.responsiveSpacing(context, 6),
                  children: List.generate(_examController.questions.length, (index) {
                    final question = _examController.questions[index];
                    final isAnswered = _examController.hasAnsweredQuestion(
                      question.order,
                    );
                    final isCurrent =
                        _examController.currentQuestionIndex.value == index;

                    return InkWell(
                      onTap: () {
                        _examController.goToQuestion(index);
                      },
                      child: Container(
                        width: ResponsiveUtils.responsiveSpacing(context, 32),
                        height: ResponsiveUtils.responsiveSpacing(context, 32),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? theme.AppTheme.primaryColor
                              : isAnswered
                              ? theme.AppTheme.successColor
                              : Colors.white,
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.responsiveBorderRadius(context, 6),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrent || isAnswered
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveUtils.responsiveFontSize(context, 11),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNavigationButtons() {
    return Obx(() {
      return Container(
        padding: EdgeInsets.all(ResponsiveUtils.responsiveSpacing(context, 16)),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: ResponsiveUtils.responsiveButtonHeight(context),
                child: ElevatedButton(
                  onPressed: _examController.currentQuestionIndex.value > 0
                      ? _examController.previousQuestion
                      : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.responsiveBorderRadius(context, 12),
                      ),
                    ),
                  ),
                  child: Text(
                    'Previous',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtils.responsiveSpacing(context, 16)),
            Expanded(
              child: SizedBox(
                height: ResponsiveUtils.responsiveButtonHeight(context),
                child: ElevatedButton(
                  onPressed:
                      _examController.currentQuestionIndex.value <
                          _examController.questions.length - 1
                      ? _examController.nextQuestion
                      : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.responsiveBorderRadius(context, 12),
                      ),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtils.responsiveSpacing(context, 16)),
            Expanded(
              child: SizedBox(
                height: ResponsiveUtils.responsiveButtonHeight(context),
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.AppTheme.successColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.responsiveBorderRadius(context, 12),
                      ),
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
