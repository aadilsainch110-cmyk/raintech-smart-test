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
      print('DEBUG: QuestionController.fetchQuestionsByTest called for testId: $testId');

      final query = _firestoreService.queryWhereEqualTo(
        collectionPath: 'questions',
        field: 'testId',
        value: testId,
      );

      print('DEBUG: Executing Firestore query...');
      final snapshot = await query.get();
      print('DEBUG: Query returned ${snapshot.docs.length} documents');

      if (snapshot.docs.isEmpty) {
        print('DEBUG: WARNING - No documents found in questions collection for testId: $testId');
        print('DEBUG: This could mean:');
        print('DEBUG: 1. The test has no questions added yet');
        print('DEBUG: 2. Firestore security rules are blocking access');
        print('DEBUG: 3. The questions collection structure is different');
      } else {
        print('DEBUG: Sample question data:');
        if (snapshot.docs.isNotEmpty) {
          final firstDoc = snapshot.docs.first.data();
          print('DEBUG:   ${firstDoc.keys.join(', ')}');
        }
      }

      questions.value = snapshot.docs.map((doc) {
        return QuestionModel.fromJson(
          doc.data() as Map<String, dynamic>,
          id: doc.id,
        );
      }).toList();

      questions.sort((a, b) => a.order.compareTo(b.order));
      print('DEBUG: Loaded ${questions.length} questions after sorting');
    } catch (e) {
      print('DEBUG: Error in fetchQuestionsByTest: $e');
      print('DEBUG: Error type: ${e.runtimeType}');
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

      // Update test's questionCount
      print('DEBUG: Updating test questionCount');
      await fetchQuestionsByTest(testId: testId);
      final questionCount = questions.length;
      await _firestoreService.updateDocument(
        collectionPath: 'tests',
        documentId: testId,
        data: {
          'questionCount': questionCount,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
      print('DEBUG: Test questionCount updated to $questionCount');

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

  Future<bool> addMultipleQuestions({
    required String testId,
    required List<Map<String, dynamic>> questionsData,
  }) async {
    try {
      errorMessage.value = '';

      await fetchQuestionsByTest(testId: testId);
      int startingOrder = questions.length + 1;

      // Prepare all question data for batch write
      final List<Map<String, dynamic>> batchData = [];
      for (int i = 0; i < questionsData.length; i++) {
        final qData = questionsData[i];
        final questionModel = QuestionModel(
          testId: testId,
          question: qData['question'],
          optionA: qData['optionA'],
          optionB: qData['optionB'],
          optionC: qData['optionC'],
          optionD: qData['optionD'],
          correctAnswer: qData['correctAnswer'].toUpperCase(),
          marks: qData['marks'],
          order: startingOrder + i,
          createdAt: DateTime.now(),
        );
        batchData.add(questionModel.toJson());
      }

      // Batch write all questions at once
      await _firestoreService.batchAddDocuments(
        collectionPath: 'questions',
        dataList: batchData,
      );

      await fetchQuestionsByTest(testId: testId);
      final questionCount = questions.length;
      await _firestoreService.updateDocument(
        collectionPath: 'tests',
        documentId: testId,
        data: {
          'questionCount': questionCount,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
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
      // Update test's questionCount
      final questionCount = questions.length;
      await _firestoreService.updateDocument(
        collectionPath: 'tests',
        documentId: testId,
        data: {
          'questionCount': questionCount,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
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
        // Update test's questionCount
        final questionCount = questions.length;
        await _firestoreService.updateDocument(
          collectionPath: 'tests',
          documentId: testId,
          data: {
            'questionCount': questionCount,
            'updatedAt': DateTime.now().toIso8601String(),
          },
        );
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
      // Update test's questionCount to 0
      await _firestoreService.updateDocument(
        collectionPath: 'tests',
        documentId: testId,
        data: {
          'questionCount': 0,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateTestQuestionCount({required String testId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await fetchQuestionsByTest(testId: testId);
      final questionCount = questions.length;
      
      await _firestoreService.updateDocument(
        collectionPath: 'tests',
        documentId: testId,
        data: {
          'questionCount': questionCount,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
      
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
