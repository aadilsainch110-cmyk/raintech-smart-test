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
    print('=== DEBUG: fetchQuestionsByTest ENTRY ===');
    print('Before isLoading set to true: ${isLoading.value}');
    try {
      isLoading.value = true;
      print('After isLoading set to true: ${isLoading.value}');
      errorMessage.value = '';
      print('DEBUG: QuestionController.fetchQuestionsByTest called for testId: $testId');

      print('=== DEBUG: fetchQuestionsByTest START ===');
      print('Input testId: "$testId"');
      print('testId length: ${testId.length}');
      print('testId type: ${testId.runtimeType}');

      final query = _firestoreService.queryWhereEqualTo(
        collectionPath: 'questions',
        field: 'testId',
        value: testId,
      );

      print('Executing Firestore query...');
      print('Collection: questions');
      print('Field: testId');
      print('Value: "$testId"');

      final snapshot = await query.get();
      print('Query completed');
      print('Document count returned: ${snapshot.docs.length}');

      if (snapshot.docs.isEmpty) {
        print('*** ZERO DOCUMENTS RETURNED ***');
        print('Query: questions where testId == "$testId"');
        print('This suggests no questions exist with this testId in Firestore');
        print('Possible causes:');
        print('1. Questions were never saved with this testId');
        print('2. Questions were saved with a different testId value');
        print('3. Firestore security rules are blocking read access');
      } else {
        print('*** ${snapshot.docs.length} DOCUMENTS FOUND ***');
        print('Sample question data:');
        final firstDoc = snapshot.docs.first.data() as Map<String, dynamic>;
        print('Document testId field: ${firstDoc['testId']}');
        print('testId matches: ${firstDoc['testId'] == testId}');
        print('Fields: ${firstDoc.keys.join(', ')}');
      }

      print('Starting to parse ${snapshot.docs.length} documents...');
      questions.value = snapshot.docs.map((doc) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          print('Parsing document ${doc.id}');
          print('  testId in document: ${data['testId']}');
          print('  testId matches input: ${data['testId'] == testId}');
          final model = QuestionModel.fromJson(
            data,
            id: doc.id,
          );
          print('  Parsed successfully');
          return model;
        } catch (e) {
          print('  ERROR parsing document ${doc.id}: $e');
          rethrow;
        }
      }).toList();

      print('Parsed ${questions.length} questions successfully');
      questions.sort((a, b) => a.order.compareTo(b.order));
      print('Questions assigned to controller: ${questions.length}');
      print('Controller isLoading: ${isLoading.value}');
      print('Controller errorMessage: "${errorMessage.value}"');
      print('=== DEBUG: fetchQuestionsByTest END ===');
    } catch (e, stackTrace) {
      print('*** EXCEPTION IN fetchQuestionsByTest ***');
      print('Exception: $e');
      print('Exception type: ${e.runtimeType}');
      print('Stack trace: $stackTrace');
      errorMessage.value = e.toString();
      print('errorMessage set to: "${errorMessage.value}"');
      print('=== DEBUG: fetchQuestionsByTest END (exception) ===');
    } finally {
      print('Before isLoading set to false: ${isLoading.value}');
      isLoading.value = false;
      print('After isLoading set to false: ${isLoading.value}');
      print('=== DEBUG: fetchQuestionsByTest EXIT ===');
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
    print('=== DEBUG: addQuestion START ===');
    print('Input testId: "$testId"');
    print('testId length: ${testId.length}');
    print('testId type: ${testId.runtimeType}');
    print('question: $question');
    print('order: $order');
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print('Creating QuestionModel');

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
      print('=== DEBUG: addQuestion START ===');
      print('Input testId: "$testId"');
      print('testId length: ${testId.length}');
      print('testId type: ${testId.runtimeType}');
      print('QuestionModel created');
      print('QuestionModel.testId: "${questionModel.testId}"');
      print('Question data to save:');
      print(questionModel.toJson());

      print('Saving to Firestore...');
      print('Collection: questions');
      print('Data: ${questionModel.toJson()}');
      await _firestoreService.addDocument(
        collectionPath: 'questions',
        data: questionModel.toJson(),
      );
      print('Question saved successfully to Firestore');

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
      print('Question count after refresh: ${questions.length}');
      print('=== DEBUG: addQuestion END (success) ===');
      return true;
    } catch (e) {
      print('*** EXCEPTION IN addQuestion ***');
      print('Exception: $e');
      print('Exception type: ${e.runtimeType}');
      errorMessage.value = e.toString();
      print('errorMessage set to: "${errorMessage.value}"');
      print('=== DEBUG: addQuestion END (exception) ===');
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
    print('=== DEBUG: addMultipleQuestions START ===');
    print('Input testId: "$testId"');
    print('testId length: ${testId.length}');
    print('testId type: ${testId.runtimeType}');
    print('Number of questions to import: ${questionsData.length}');
    try {
      errorMessage.value = '';

      await fetchQuestionsByTest(testId: testId);
      int startingOrder = questions.length + 1;
      print('Existing questions count: $startingOrder');

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

      print('Prepared ${batchData.length} questions for batch import');
      print('Each question has testId: "$testId"');

      // Batch write all questions at once
      print('Executing batch write to Firestore...');
      print('Collection: questions');
      print('Number of documents: ${batchData.length}');
      await _firestoreService.batchAddDocuments(
        collectionPath: 'questions',
        dataList: batchData,
      );
      print('Batch write completed successfully');

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

      print('Question count after refresh: $questionCount');
      print('=== DEBUG: addMultipleQuestions END (success) ===');
      return true;
    } catch (e) {
      print('*** EXCEPTION IN addMultipleQuestions ***');
      print('Exception: $e');
      print('Exception type: ${e.runtimeType}');
      errorMessage.value = e.toString();
      print('errorMessage set to: "${errorMessage.value}"');
      print('=== DEBUG: addMultipleQuestions END (exception) ===');
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
