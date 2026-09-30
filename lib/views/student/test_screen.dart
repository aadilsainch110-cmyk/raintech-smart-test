import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/exam_controller.dart';
import '../../controllers/question_controller.dart';
import '../../controllers/result_controller.dart';
import '../../controllers/auth_controller.dart';
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

  TestModel? _test;
  List<QuestionModel> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadTest();
  }

  Future<void> _loadTest() async {
    _test = Get.arguments as TestModel?;
    if (_test != null) {
      await _questionController.fetchQuestionsByTest(testId: _test!.id!);
      _questions = _questionController.questions;

      _examController.startExam(test: _test!, testQuestions: _questions);
    }
  }

  @override
  void dispose() {
    _examController.clearExam();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final answeredCount = _examController.answeredCount;
    final totalQuestions = _questions.length;

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
      final submitted = await _examController.submitExam(
        studentId: _authController.currentUser!.id!,
      );

      if (submitted && _test != null) {
        await _resultController.calculateAndSaveResult(
          testId: _test!.id!,
          studentId: _authController.currentUser!.id!,
          questions: _questions,
          answers: _examController.answers,
          totalMarks: _test!.totalMarks,
          passingMarks: _test!.passingMarks,
        );

        _showResultDialog();
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
        if (_test == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_questions.isEmpty) {
          return const Center(child: Text('No questions available'));
        }

        if (_examController.isSubmitted.value) {
          return const Center(child: Text('Test submitted'));
        }

        final currentIndex = _examController.currentQuestionIndex.value;
        final currentQuestion = _questions[currentIndex];

        return Column(
          children: [
            _buildQuestionHeader(currentIndex),
            Expanded(child: _buildQuestionContent(currentQuestion)),
            _buildQuestionPalette(),
            _buildNavigationButtons(),
          ],
        );
      }),
    );
  }

  Widget _buildQuestionHeader(int currentIndex) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.AppTheme.primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Question ${currentIndex + 1} / ${_questions.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Obx(
            () => Text(
              'Answered: ${_examController.answeredCount}/${_questions.length}',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(QuestionModel question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildOption('A', question.optionA, question),
          const SizedBox(height: 12),
          _buildOption('B', question.optionB, question),
          const SizedBox(height: 12),
          _buildOption('C', question.optionC, question),
          const SizedBox(height: 12),
          _buildOption('D', question.optionD, question),
        ],
      ),
    );
  }

  Widget _buildOption(String option, String text, QuestionModel question) {
    return Obx(() {
      final isSelected =
          _examController.getAnswerForQuestion(question.order) == option;
      return InkWell(
        onTap: () {
          _examController.selectAnswer(option);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? theme.AppTheme.primaryColor : Colors.grey,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? theme.AppTheme.primaryColor.withValues(alpha: 0.1)
                : Colors.white,
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
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
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildQuestionPalette() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Question Palette',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_questions.length, (index) {
              final question = _questions[index];
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? theme.AppTheme.primaryColor
                        : isAnswered
                        ? theme.AppTheme.successColor
                        : Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isCurrent || isAnswered
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Obx(
            () => Expanded(
              child: ElevatedButton(
                onPressed: _examController.currentQuestionIndex.value > 0
                    ? _examController.previousQuestion
                    : null,
                child: const Text('Previous'),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Obx(
            () => Expanded(
              child: ElevatedButton(
                onPressed:
                    _examController.currentQuestionIndex.value <
                        _questions.length - 1
                    ? _examController.nextQuestion
                    : null,
                child: const Text('Next'),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.AppTheme.successColor,
              ),
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
