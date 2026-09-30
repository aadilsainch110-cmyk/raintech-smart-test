import 'package:get/get.dart';
import '../models/result_model.dart';
import '../models/question_model.dart';
import '../services/firestore_service.dart';

class ResultController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final RxList<ResultModel> results = <ResultModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

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

      for (final question in questions) {
        final studentAnswer = answers[question.order];
        if (studentAnswer != null) {
          if (studentAnswer.toUpperCase() ==
              question.correctAnswer.toUpperCase()) {
            obtainedMarks += question.marks;
            correctAnswers++;
          } else {
            wrongAnswers++;
          }
        } else {
          wrongAnswers++;
        }
      }

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
}
