import 'package:get/get.dart';
import '../models/attempt_model.dart';
import '../services/firestore_service.dart';

class AttemptController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final RxList<AttemptModel> attempts = <AttemptModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> fetchAttemptsByTest({required String testId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final query = _firestoreService.queryWhereEqualTo(
        collectionPath: 'attempts',
        field: 'testId',
        value: testId,
      );

      final snapshot = await query.get();

      attempts.value = snapshot.docs.map((doc) {
        return AttemptModel.fromJson(
          Map<String, dynamic>.from(doc.data() as Map),
          id: doc.id,
        );
      }).toList();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAttemptsByStudent({required String studentId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final query = _firestoreService.queryWhereEqualTo(
        collectionPath: 'attempts',
        field: 'studentId',
        value: studentId,
      );

      final snapshot = await query.get();

      attempts.value = snapshot.docs.map((doc) {
        return AttemptModel.fromJson(
          Map<String, dynamic>.from(doc.data() as Map),
          id: doc.id,
        );
      }).toList();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllAttempts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final snapshot = await _firestoreService.getCollection(
        collectionPath: 'attempts',
      );

      attempts.value = snapshot.docs.map((doc) {
        return AttemptModel.fromJson(
          Map<String, dynamic>.from(doc.data() as Map),
          id: doc.id,
        );
      }).toList();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createAttempt({
    required String testId,
    required String studentId,
    required Map<int, String> answers,
    DateTime? startedAt,
    DateTime? submittedAt,
    int? timeTakenSeconds,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final attempt = AttemptModel(
        testId: testId,
        studentId: studentId,
        answers: answers,
        startedAt: startedAt,
        submittedAt: submittedAt,
        timeTakenSeconds: timeTakenSeconds,
      );

      await _firestoreService.addDocument(
        collectionPath: 'attempts',
        data: attempt.toJson(),
      );

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateAttempt({
    required String attemptId,
    Map<int, String>? answers,
    DateTime? submittedAt,
    int? timeTakenSeconds,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = <String, dynamic>{};

      if (answers != null) {
        data['answers'] = answers;
      }

      if (submittedAt != null) {
        data['submittedAt'] = submittedAt.toIso8601String();
      }

      if (timeTakenSeconds != null) {
        data['timeTakenSeconds'] = timeTakenSeconds;
      }

      await _firestoreService.updateDocument(
        collectionPath: 'attempts',
        documentId: attemptId,
        data: data,
      );

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteAttempt({required String attemptId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _firestoreService.deleteDocument(
        collectionPath: 'attempts',
        documentId: attemptId,
      );

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  AttemptModel? getAttemptById(String attemptId) {
    try {
      return attempts.firstWhere(
        (attempt) => attempt.id == attemptId,
      );
    } catch (e) {
      return null;
    }
  }

  AttemptModel? getStudentTestAttempt({
    required String testId,
    required String studentId,
  }) {
    try {
      return attempts.firstWhere(
        (attempt) =>
            attempt.testId == testId &&
            attempt.studentId == studentId,
      );
    } catch (e) {
      return null;
    }
  }

  Future<bool> hasStudentAttemptedTest({
    required String testId,
    required String studentId,
  }) async {
    try {
      final query = _firestoreService.queryWhereEqualTo(
        collectionPath: 'attempts',
        field: 'studentId',
        value: studentId,
      );

      final snapshot = await query.get();

      for (final doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(
          doc.data() as Map,
        );

        if (data['testId']?.toString() == testId) {
          return data['submittedAt'] != null;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  List<AttemptModel> getTestAttempts(String testId) {
    return attempts
        .where((attempt) => attempt.testId == testId)
        .toList();
  }

  Map<String, dynamic> getTestStatistics({required String testId}) {
    final testAttempts = getTestAttempts(testId);

    if (testAttempts.isEmpty) {
      return {
        'totalAttempts': 0,
        'completedAttempts': 0,
        'inProgressAttempts': 0,
        'averageTimeTaken': 0.0,
      };
    }

    final completedAttempts = testAttempts
        .where((a) => a.submittedAt != null)
        .length;

    final inProgressAttempts =
        testAttempts.length - completedAttempts;

    final totalTimes = testAttempts
        .where((a) => a.timeTakenSeconds != null)
        .map((a) => a.timeTakenSeconds!)
        .toList();

    final averageTime = totalTimes.isNotEmpty
        ? totalTimes.reduce((a, b) => a + b) / totalTimes.length
        : 0.0;

    return {
      'totalAttempts': testAttempts.length,
      'completedAttempts': completedAttempts,
      'inProgressAttempts': inProgressAttempts,
      'averageTimeTaken': averageTime,
    };
  }
}
