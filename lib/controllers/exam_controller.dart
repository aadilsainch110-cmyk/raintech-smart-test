import 'dart:async';
import 'package:get/get.dart';
import '../models/test_model.dart';
import '../models/question_model.dart';
import '../models/attempt_model.dart';
import '../services/firestore_service.dart';
import 'auth_controller.dart';

class ExamController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final Rx<TestModel?> currentTest = Rx<TestModel?>(null);
  final RxList<QuestionModel> questions = <QuestionModel>[].obs;
  final RxMap<int, String> answers = <int, String>{}.obs;
  final RxInt currentQuestionIndex = 0.obs;
  final RxInt remainingSeconds = 0.obs;
  final RxBool isSubmitted = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  Timer? _timer;
  DateTime? _testStartTime;

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startExam({
    required TestModel test,
    required List<QuestionModel> testQuestions,
  }) {
    currentTest.value = test;
    questions.value = testQuestions;
    answers.clear();
    currentQuestionIndex.value = 0;
    isSubmitted.value = false;
    errorMessage.value = '';
    
    remainingSeconds.value = test.durationMinutes * 60;
    _testStartTime = DateTime.now();
    
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        _timer?.cancel();
        autoSubmit();
      }
    });
  }

  void selectAnswer(String option) {
    final questionOrder = questions[currentQuestionIndex.value].order;
    answers[questionOrder] = option.toUpperCase();
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      currentQuestionIndex.value = index;
    }
  }

  int get answeredCount => answers.length;
  int get unansweredCount => questions.length - answeredCount;

  Future<bool> submitExam({required String studentId}) async {
    if (isSubmitted.value) return false;
    
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      _timer?.cancel();
      
      final testStartTime = _testStartTime ?? DateTime.now();
      final submittedAt = DateTime.now();
      final timeTaken = submittedAt.difference(testStartTime).inSeconds;
      
      final attempt = AttemptModel(
        testId: currentTest.value!.id!,
        studentId: studentId,
        answers: answers,
        startedAt: testStartTime,
        submittedAt: submittedAt,
        timeTakenSeconds: timeTaken,
      );
      
      await _firestoreService.addDocument(
        collectionPath: 'attempts',
        data: attempt.toJson(),
      );
      
      isSubmitted.value = true;
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> autoSubmit() async {
    if (!isSubmitted.value && currentTest.value != null) {
      final authController = Get.find<AuthController>();
      if (authController.currentUser != null) {
        await submitExam(studentId: authController.currentUser!.id!);
      }
    }
  }

  String get formattedTime {
    final minutes = remainingSeconds.value ~/ 60;
    final seconds = remainingSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get isTimeUp => remainingSeconds.value <= 0;

  void clearExam() {
    _timer?.cancel();
    currentTest.value = null;
    questions.clear();
    answers.clear();
    currentQuestionIndex.value = 0;
    remainingSeconds.value = 0;
    isSubmitted.value = false;
    _testStartTime = null;
  }

  bool hasAnsweredQuestion(int questionOrder) {
    return answers.containsKey(questionOrder);
  }

  String? getAnswerForQuestion(int questionOrder) {
    return answers[questionOrder];
  }
}
