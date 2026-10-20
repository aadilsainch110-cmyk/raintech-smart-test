import 'package:get/get.dart';
import '../models/result_model.dart';
import '../models/question_model.dart';
import '../services/firestore_service.dart';

class ResultController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final RxList<ResultModel> results = <ResultModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  /// Normalize answer for comparison - handles both letter (A/B/C/D) and text matching
  String _normalizeAnswer(String answer) {
    return answer.trim().toUpperCase();
  }

  /// Check if student answer matches correct answer
  /// Handles both letter (A/B/C/D) and text-based comparisons
  bool _isAnswerCorrect({
    required String studentAnswer,
    required String correctAnswer,
    required QuestionModel question,
  }) {
    final normalizedStudent = _normalizeAnswer(studentAnswer);
    final normalizedCorrect = _normalizeAnswer(correctAnswer);

    // Direct match (both are letters or both are same text)
    if (normalizedStudent == normalizedCorrect) {
      return true;
    }

    // If correct answer is a letter (A/B/C/D), map to option text
    if (normalizedCorrect == 'A' && normalizedStudent == _normalizeAnswer(question.optionA)) {
      return true;
    }
    if (normalizedCorrect == 'B' && normalizedStudent == _normalizeAnswer(question.optionB)) {
      return true;
    }
    if (normalizedCorrect == 'C' && normalizedStudent == _normalizeAnswer(question.optionC)) {
      return true;
    }
    if (normalizedCorrect == 'D' && normalizedStudent == _normalizeAnswer(question.optionD)) {
      return true;
    }

    // If student answer is a letter (A/B/C/D), map to option text
    if (normalizedStudent == 'A' && normalizedCorrect == _normalizeAnswer(question.optionA)) {
      return true;
    }
    if (normalizedStudent == 'B' && normalizedCorrect == _normalizeAnswer(question.optionB)) {
      return true;
    }
    if (normalizedStudent == 'C' && normalizedCorrect == _normalizeAnswer(question.optionC)) {
      return true;
    }
    if (normalizedStudent == 'D' && normalizedCorrect == _normalizeAnswer(question.optionD)) {
      return true;
    }

    return false;
  }

  Future<void> fetchStudentResults({required String studentId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final query = _firestoreService.queryWhereEqualTo(
        collectionPath: 'results',
        field: 'studentId',
        value: studentId,
      );

      final snapshot = await query.get();

      results.value = snapshot.docs.map((doc) {
        return ResultModel.fromJson(
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

  Future<void> fetchTestResults({required String testId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final query = _firestoreService.queryWhereEqualTo(
        collectionPath: 'results',
        field: 'testId',
        value: testId,
      );

      final snapshot = await query.get();

      results.value = snapshot.docs.map((doc) {
        return ResultModel.fromJson(
          doc.data() as Map<String, dynamic>,
          id: doc.id,
        );
      }).toList();

      results.sort((a, b) => b.obtainedMarks.compareTo(a.obtainedMarks));
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllResults() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final snapshot = await _firestoreService.getCollection(
        collectionPath: 'results',
      );

      results.value = snapshot.docs.map((doc) {
        return ResultModel.fromJson(
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

  Future<bool> calculateAndSaveResult({
    required String testId,
    required String studentId,
    required List<QuestionModel> questions,
    required Map<int, String> answers,
    required int totalMarks,
    required int passingMarks,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      int obtainedMarks = 0;
      int correctAnswers = 0;
      int wrongAnswers = 0;

      print('========== DEBUG: RESULT CALCULATION START ==========');
      print('Test ID: $testId');
      print('Student ID (Firebase UID): $studentId');
      print('Total Questions: ${questions.length}');
      print('Total Answers Provided: ${answers.length}');
      print('Total Marks: $totalMarks');
      print('Passing Marks: $passingMarks');

      for (final question in questions) {
        final studentAnswer = answers[question.order];
        final correctAnswer = question.correctAnswer;

        print('\n--- Question ${question.order} ---');
        print('Question: ${question.question}');
        print('Option A: ${question.optionA}');
        print('Option B: ${question.optionB}');
        print('Option C: ${question.optionC}');
        print('Option D: ${question.optionD}');
        print('Correct Answer (from Firestore): "$correctAnswer"');
        print('Student Answer: "${studentAnswer ?? "NULL"}"');

        if (studentAnswer != null) {
          final isCorrect = _isAnswerCorrect(
            studentAnswer: studentAnswer,
            correctAnswer: correctAnswer,
            question: question,
          );

          print('Normalized Student Answer: "${_normalizeAnswer(studentAnswer)}"');
          print('Normalized Correct Answer: "${_normalizeAnswer(correctAnswer)}"');
          print('Is Correct: $isCorrect');

          if (isCorrect) {
            obtainedMarks += question.marks;
            correctAnswers++;
            print('Result: CORRECT (+${question.marks} marks)');
          } else {
            wrongAnswers++;
            print('Result: WRONG');
          }
        } else {
          wrongAnswers++;
          print('Result: UNANSWERED (counted as wrong)');
        }
      }

      print('\n========== DEBUG: FINAL RESULT ==========');
      print('Correct Answers: $correctAnswers');
      print('Wrong Answers: $wrongAnswers');
      print('Obtained Marks: $obtainedMarks');
      print('Total Marks: $totalMarks');
      print('Percentage: ${totalMarks > 0 ? (obtainedMarks / totalMarks) * 100 : 0.0}%');
      print('Status: ${obtainedMarks >= passingMarks ? "PASS" : "FAIL"}');
      print('==============================================');

      final percentage = totalMarks > 0
          ? (obtainedMarks / totalMarks) * 100
          : 0.0;
      final status = obtainedMarks >= passingMarks ? 'PASS' : 'FAIL';

      final result = ResultModel(
        testId: testId,
        studentId: studentId,
        totalMarks: totalMarks,
        obtainedMarks: obtainedMarks,
        percentage: percentage,
        correctAnswers: correctAnswers,
        wrongAnswers: wrongAnswers,
        status: status,
        submittedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await _firestoreService.addDocument(
        collectionPath: 'results',
        data: result.toJson(),
      );

      // Auto-calculate rankings after saving result
      await calculateRankings(testId: testId);

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> calculateRankings({required String testId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await fetchTestResults(testId: testId);

      results.sort((a, b) => b.obtainedMarks.compareTo(a.obtainedMarks));

      int currentPosition = 1;
      for (int i = 0; i < results.length; i++) {
        if (i > 0 && results[i].obtainedMarks < results[i - 1].obtainedMarks) {
          currentPosition = i + 1;
        }

        await _firestoreService.updateDocument(
          collectionPath: 'results',
          documentId: results[i].id!,
          data: {'position': currentPosition},
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

  Future<bool> releaseResults({required String testId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // First calculate rankings
      await calculateRankings(testId: testId);

      // Then mark test as results_released
      await _firestoreService.updateDocument(
        collectionPath: 'tests',
        documentId: testId,
        data: {'status': 'results_released'},
      );

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateResultStatus({
    required String resultId,
    required bool showPosition,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _firestoreService.updateDocument(
        collectionPath: 'results',
        documentId: resultId,
        data: {'showPosition': showPosition},
      );

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateResultPosition({
    required String resultId,
    required int position,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _firestoreService.updateDocument(
        collectionPath: 'results',
        documentId: resultId,
        data: {'position': position},
      );

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  ResultModel? getStudentTestResult({
    required String testId,
    required String studentId,
  }) {
    try {
      return results.firstWhere(
        (result) => result.testId == testId && result.studentId == studentId,
      );
    } catch (e) {
      return null;
    }
  }

  ResultModel? getResultById(String resultId) {
    try {
      return results.firstWhere((result) => result.id == resultId);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> getOverallPerformance({required String studentId}) {
    final studentResults = results
        .where((r) => r.studentId == studentId)
        .toList();

    if (studentResults.isEmpty) {
      return {
        'testsAttempted': 0,
        'totalMarks': 0,
        'obtainedMarks': 0,
        'averagePercentage': 0.0,
        'passedTests': 0,
        'failedTests': 0,
      };
    }

    final totalMarks = studentResults.fold(0, (sum, r) => sum + r.totalMarks);
    final obtainedMarks = studentResults.fold(
      0,
      (sum, r) => sum + r.obtainedMarks,
    );
    final averagePercentage = totalMarks / studentResults.length > 0
        ? studentResults.fold(0.0, (sum, r) => sum + r.percentage) /
              studentResults.length
        : 0.0;
    final passedTests = studentResults.where((r) => r.status == 'PASS').length;
    final failedTests = studentResults.where((r) => r.status == 'FAIL').length;

    return {
      'testsAttempted': studentResults.length,
      'totalMarks': totalMarks,
      'obtainedMarks': obtainedMarks,
      'averagePercentage': averagePercentage,
      'passedTests': passedTests,
      'failedTests': failedTests,
    };
  }

  List<ResultModel> getResultsByCourse({
    required String studentId,
    required String courseId,
  }) {
    return results.where((r) => r.studentId == studentId).toList();
  }

  Future<Map<String, dynamic>> calculateOverallLeaderboard() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await fetchAllResults();

      // Group results by student
      final Map<String, List<ResultModel>> studentResults = {};
      for (final result in results) {
        if (!studentResults.containsKey(result.studentId)) {
          studentResults[result.studentId] = [];
        }
        studentResults[result.studentId]!.add(result);
      }

      // Calculate overall performance for each student
      final List<Map<String, dynamic>> leaderboard = [];
      studentResults.forEach((studentId, studentResultList) {
        final totalMarks = studentResultList.fold(0, (sum, r) => sum + r.totalMarks);
        final obtainedMarks = studentResultList.fold(0, (sum, r) => sum + r.obtainedMarks);
        final averagePercentage = studentResultList.isNotEmpty
            ? studentResultList.fold(0.0, (sum, r) => sum + r.percentage) / studentResultList.length
            : 0.0;
        final passedTests = studentResultList.where((r) => r.status == 'PASS').length;
        final totalTests = studentResultList.length;

        leaderboard.add({
          'studentId': studentId,
          'totalTests': totalTests,
          'totalMarks': totalMarks,
          'obtainedMarks': obtainedMarks,
          'averagePercentage': averagePercentage,
          'passedTests': passedTests,
        });
      });

      // Sort by average percentage (descending)
      leaderboard.sort((a, b) => b['averagePercentage'].compareTo(a['averagePercentage']));

      // Assign positions
      int currentPosition = 1;
      for (int i = 0; i < leaderboard.length; i++) {
        if (i > 0 && leaderboard[i]['averagePercentage'] < leaderboard[i - 1]['averagePercentage']) {
          currentPosition = i + 1;
        }
        leaderboard[i]['position'] = currentPosition;
      }

      return {
        'leaderboard': leaderboard,
        'totalStudents': leaderboard.length,
      };
    } catch (e) {
      errorMessage.value = e.toString();
      return {
        'leaderboard': <Map<String, dynamic>>[],
        'totalStudents': 0,
      };
    } finally {
      isLoading.value = false;
    }
  }
}
