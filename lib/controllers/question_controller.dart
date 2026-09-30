import 'package:get/get.dart';
import '../models/question_model.dart';
import '../services/firestore_service.dart';

// ignore_for_file: use_null_aware_elements, avoid_print

class QuestionController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final RxList<QuestionModel> questions = <QuestionModel>[].obs;
  final RxList<QuestionBankModel> questionBank = <QuestionBankModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> fetchQuestionsByTest({required String testId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final query = _firestoreService.queryWhereEqualTo(
        collectionPath: 'questions',
        field: 'testId',
        value: testId,
      );

      final snapshot = await query.get();

      questions.value = snapshot.docs.map((doc) {
        return QuestionModel.fromJson(
          doc.data() as Map<String, dynamic>,
          id: doc.id,
        );
      }).toList();

      questions.sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchQuestionBank() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final snapshot = await _firestoreService.getCollection(
        collectionPath: 'questionBank',
      );

      questionBank.value = snapshot.docs.map((doc) {
        return QuestionBankModel.fromJson(
          doc.data() as Map<String, dynamic>,
          id: doc.id,
        );
      }).toList();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchQuestionBankByCourse({required String courseId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final query = _firestoreService.queryWhereEqualTo(
        collectionPath: 'questionBank',
        field: 'courseId',
        value: courseId,
      );

      final snapshot = await query.get();

      questionBank.value = snapshot.docs.map((doc) {
        return QuestionBankModel.fromJson(
          doc.data() as Map<String, dynamic>,
          id: doc.id,
        );
      }).toList();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addQuestion({
    required String testId,
    required String question,
    required String optionA,
    required String optionB,
    required String optionC,
    required String optionD,
    required String correctAnswer,
    required int marks,
    required int order,
  }) async {
    print('DEBUG: QuestionController.addQuestion called');
    print('DEBUG: testId: $testId');
    print('DEBUG: question: $question');
    print('DEBUG: order: $order');
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print('DEBUG: Creating QuestionModel');

      final questionModel = QuestionModel(
        testId: testId,
        question: question,
        optionA: optionA,
        optionB: optionB,
        optionC: optionC,
        optionD: optionD,
        correctAnswer: correctAnswer.toUpperCase(),
        marks: marks,
        order: order,
        createdAt: DateTime.now(),
      );
      print('DEBUG: QuestionModel created: ${questionModel.toJson()}');

      print('DEBUG: Adding document to Firestore collection: questions');
      await _firestoreService.addDocument(
        collectionPath: 'questions',
        data: questionModel.toJson(),
      );
      print('DEBUG: Document added successfully');

      print('DEBUG: Fetching questions by test');
      await fetchQuestionsByTest(testId: testId);
      print('DEBUG: Questions fetched');
      return true;
    } catch (e) {
      print('DEBUG: Error in addQuestion: $e');
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addQuestionToBank({
    required String question,
    required String optionA,
    required String optionB,
    required String optionC,
    required String optionD,
    required String correctAnswer,
    required int marks,
    String? courseId,
    String? category,
    String? difficulty,
    String? createdBy,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final questionModel = QuestionBankModel(
        question: question,
        optionA: optionA,
        optionB: optionB,
        optionC: optionC,
        optionD: optionD,
        correctAnswer: correctAnswer.toUpperCase(),
        marks: marks,
        courseId: courseId,
        category: category,
        difficulty: difficulty,
        createdBy: createdBy,
        createdAt: DateTime.now(),
      );

      await _firestoreService.addDocument(
        collectionPath: 'questionBank',
        data: questionModel.toJson(),
      );

      await fetchQuestionBank();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addQuestionsFromBank({
    required String testId,
    required List<String> questionBankIds,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      int order = 1;
      for (final bankId in questionBankIds) {
        final bankQuestion = questionBank.firstWhere((q) => q.id == bankId);

        final questionModel = QuestionModel(
          testId: testId,
          question: bankQuestion.question,
          optionA: bankQuestion.optionA,
          optionB: bankQuestion.optionB,
          optionC: bankQuestion.optionC,
          optionD: bankQuestion.optionD,
          correctAnswer: bankQuestion.correctAnswer,
          marks: bankQuestion.marks,
          order: order,
          createdAt: DateTime.now(),
        );

        await _firestoreService.addDocument(
          collectionPath: 'questions',
          data: questionModel.toJson(),
        );

        order++;
      }

      await fetchQuestionsByTest(testId: testId);
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateQuestion({
    required String questionId,
    String? question,
    String? optionA,
    String? optionB,
    String? optionC,
    String? optionD,
    String? correctAnswer,
    int? marks,
    int? order,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = <String, dynamic>{
        if (question != null) 'question': question,
        if (optionA != null) 'optionA': optionA,
        if (optionB != null) 'optionB': optionB,
        if (optionC != null) 'optionC': optionC,
        if (optionD != null) 'optionD': optionD,
        if (correctAnswer != null) 'correctAnswer': correctAnswer.toUpperCase(),
        if (marks != null) 'marks': marks,
        if (order != null) 'order': order,
      };

      await _firestoreService.updateDocument(
        collectionPath: 'questions',
        documentId: questionId,
        data: data,
      );

      final existingQuestion = questions.firstWhere((q) => q.id == questionId);
      await fetchQuestionsByTest(testId: existingQuestion.testId!);
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteQuestion({required String questionId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final existingQuestion = questions.firstWhere((q) => q.id == questionId);
      final testId = existingQuestion.testId;

      await _firestoreService.deleteDocument(
        collectionPath: 'questions',
        documentId: questionId,
      );

      if (testId != null) {
        await fetchQuestionsByTest(testId: testId);
      }
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteTestQuestions({required String testId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final query = _firestoreService.queryWhereEqualTo(
        collectionPath: 'questions',
        field: 'testId',
        value: testId,
      );

      final snapshot = await query.get();

      for (final doc in snapshot.docs) {
        await _firestoreService.deleteDocument(
          collectionPath: 'questions',
          documentId: doc.id,
        );
      }

      questions.clear();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
