import 'package:get/get.dart';
import '../models/test_model.dart';
import '../services/firestore_service.dart';
import 'result_controller.dart';

// ignore_for_file: use_null_aware_elements, avoid_print

class TestController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final RxList<TestModel> tests = <TestModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> fetchAllTests() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final snapshot = await _firestoreService.getCollection(
        collectionPath: 'tests',
      );

      tests.value = snapshot.docs.map((doc) {
        print('DEBUG: Fetching test document ${doc.id}');
        print('DEBUG:   doc.id: "${doc.id}"');
        print('DEBUG:   doc.id type: ${doc.id.runtimeType}');
        final testModel = TestModel.fromJson(
          doc.data() as Map<String, dynamic>,
          id: doc.id,
        );
        print('DEBUG:   TestModel.id after parse: "${testModel.id}"');
        return testModel;
      }).toList();
    } catch (e) {
      print('DEBUG: Error in fetchAllTests: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPublishedTests() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final query = _firestoreService.queryWhereEqualTo(
        collectionPath: 'tests',
        field: 'status',
        value: 'published',
      );

      final snapshot = await query.get();

      tests.value = snapshot.docs.map((doc) {
        return TestModel.fromJson(
          doc.data() as Map<String, dynamic>,
          id: doc.id,
        );
      }).toList();

      // Sync question counts with actual questions in database
      await syncQuestionCountsForTests();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> syncQuestionCountsForTests() async {
    try {
      for (final test in tests) {
        // Fetch actual question count from questions collection
        final query = _firestoreService.queryWhereEqualTo(
          collectionPath: 'questions',
          field: 'testId',
          value: test.id,
        );
        
        final questionSnapshot = await query.get();
        final actualQuestionCount = questionSnapshot.docs.length;
        
        // Update the test's questionCount with actual count
        final updatedTest = test.copyWith(questionCount: actualQuestionCount);
        
        // Update in the list
        final index = tests.indexWhere((t) => t.id == test.id);
        if (index != -1) {
          tests[index] = updatedTest;
        }
        
        // Also update in Firestore if count is different
        if (test.questionCount != actualQuestionCount) {
          await _firestoreService.updateDocument(
            collectionPath: 'tests',
            documentId: test.id!,
            data: {
              'questionCount': actualQuestionCount,
              'updatedAt': DateTime.now().toIso8601String(),
            },
          );
        }
      }
    } catch (e) {
      print('Error syncing question counts: $e');
    }
  }

  Future<void> fetchTestsByCourse({required String courseId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final query = _firestoreService.queryWhereEqualTo(
        collectionPath: 'tests',
        field: 'courseId',
        value: courseId,
      );

      final snapshot = await query.get();

      tests.value = snapshot.docs.map((doc) {
        return TestModel.fromJson(
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

  Future<void> fetchTestsByTeacher({required String teacherId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final query = _firestoreService.queryWhereEqualTo(
        collectionPath: 'tests',
        field: 'createdBy',
        value: teacherId,
      );

      final snapshot = await query.get();

      tests.value = snapshot.docs.map((doc) {
        return TestModel.fromJson(
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

  /// Fetch published tests for specific enrolled courses (server-side filtering)
  /// This ensures tests are filtered at the data-fetching level, not just in UI
  Future<void> fetchPublishedTestsByCourseIds({required List<String> courseIds}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print('DEBUG: TestController.fetchPublishedTestsByCourseIds called');
      print('DEBUG: Course IDs: $courseIds');

      if (courseIds.isEmpty) {
        // No enrolled courses - return empty list
        print('DEBUG: No enrolled courses, returning empty list');
        tests.value = [];
        return;
      }

      // Fetch published tests for enrolled courses
      // Firestore doesn't support 'in' with 'whereEqualTo' for multiple fields in one query
      // So we fetch all published tests and filter by course IDs
      print('DEBUG: Querying published tests...');
      final query = _firestoreService.queryWhereEqualTo(
        collectionPath: 'tests',
        field: 'status',
        value: 'published',
      );

      final snapshot = await query.get();
      print('DEBUG: Published tests query returned ${snapshot.docs.length} documents');

      // Filter tests by enrolled course IDs (client-side but after fetching only published tests)
      tests.value = snapshot.docs
          .map((doc) => TestModel.fromJson(
                doc.data() as Map<String, dynamic>,
                id: doc.id,
              ))
          .where((test) => courseIds.contains(test.courseId))
          .toList();

      print('DEBUG: After filtering by enrolled courses: ${tests.length} tests');

      // Sync question counts with actual questions in database
      print('DEBUG: Syncing question counts...');
      await syncQuestionCountsForTests();
      print('DEBUG: Question counts synced');
    } catch (e) {
      print('DEBUG: ERROR in fetchPublishedTestsByCourseIds: $e');
      print('DEBUG: Error type: ${e.runtimeType}');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> createTest({
    required String title,
    String? description,
    required String courseId,
    String? classId,
    required String shiftId,
    required int durationMinutes,
    required int totalMarks,
    required int passingMarks,
    required String createdBy,
    DateTime? startDate,
    DateTime? endDate,
    String status = 'draft',
  }) async {
    print('DEBUG: TestController.createTest called');
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print(
        'DEBUG: Validation check - passingMarks: $passingMarks, totalMarks: $totalMarks',
      );

      if (passingMarks > totalMarks) {
        errorMessage.value = 'Passing marks cannot be greater than total marks';
        print('DEBUG: Validation failed - passing marks > total marks');
        return null;
      }
      print('DEBUG: Validation passed');

      final test = TestModel(
        title: title,
        description: description,
        courseId: courseId,
        classId: classId,
        shiftId: shiftId,
        durationMinutes: durationMinutes,
        totalMarks: totalMarks,
        passingMarks: passingMarks,
        status: status,
        createdBy: createdBy,
        questionCount: 0,
        startDate: startDate,
        endDate: endDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        resultsReleased: false,
      );
      print('DEBUG: TestModel created: ${test.toJson()}');

      print('DEBUG: Adding document to Firestore collection: tests');
      final docRef = await _firestoreService.addDocument(
        collectionPath: 'tests',
        data: test.toJson(),
      );
      print('DEBUG: Document added successfully, ID: ${docRef.id}');

      print('DEBUG: Fetching all tests');
      await fetchAllTests();
      print('DEBUG: All tests fetched');
      return docRef.id;
    } catch (e) {
      print('DEBUG: Error in createTest: $e');
      errorMessage.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateTest({
    required String testId,
    String? title,
    String? description,
    String? courseId,
    String? classId,
    String? shiftId,
    int? durationMinutes,
    int? totalMarks,
    int? passingMarks,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? questionCount,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (passingMarks != null &&
          totalMarks != null &&
          passingMarks > totalMarks) {
        errorMessage.value = 'Passing marks cannot be greater than total marks';
        return false;
      }

      final data = <String, dynamic>{
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (courseId != null) 'courseId': courseId,
        if (classId != null) 'classId': classId,
        if (shiftId != null) 'shiftId': shiftId,
        if (durationMinutes != null) 'durationMinutes': durationMinutes,
        if (totalMarks != null) 'totalMarks': totalMarks,
        if (passingMarks != null) 'passingMarks': passingMarks,
        if (status != null) 'status': status,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (questionCount != null) 'questionCount': questionCount,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _firestoreService.updateDocument(
        collectionPath: 'tests',
        documentId: testId,
        data: data,
      );

      await fetchAllTests();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteTest({required String testId, String? teacherId}) async {
    print('DEBUG: deleteTest called for testId: $testId');
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Delete all questions associated with this test using batch delete
      print('DEBUG: Deleting questions for test: $testId');
      await _firestoreService.deleteDocumentsByQuery(
        collectionPath: 'questions',
        field: 'testId',
        value: testId,
      );

      // Delete all attempts associated with this test using batch delete
      print('DEBUG: Deleting attempts for test: $testId');
      await _firestoreService.deleteDocumentsByQuery(
        collectionPath: 'attempts',
        field: 'testId',
        value: testId,
      );

      // Delete all results associated with this test using batch delete
      print('DEBUG: Deleting results for test: $testId');
      await _firestoreService.deleteDocumentsByQuery(
        collectionPath: 'results',
        field: 'testId',
        value: testId,
      );

      // Finally, delete the test itself
      print('DEBUG: Deleting test: $testId');
      await _firestoreService.deleteDocument(
        collectionPath: 'tests',
        documentId: testId,
      );
      print('DEBUG: Test deleted successfully');

      // Refresh the appropriate list based on context
      if (teacherId != null) {
        await fetchTestsByTeacher(teacherId: teacherId);
      } else {
        await fetchAllTests();
      }
      return true;
    } catch (e) {
      print('DEBUG: Error in deleteTest: $e');
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> publishTest({required String testId}) async {
    print('DEBUG: ============================================');
    print('DEBUG: TestController.publishTest called');
    print('DEBUG: testId: $testId');
    print('DEBUG: ============================================');

    try {
      // Check if test has questions before publishing
      print('DEBUG: Checking if test has questions...');
      final query = _firestoreService.queryWhereEqualTo(
        collectionPath: 'questions',
        field: 'testId',
        value: testId,
      );

      final questionSnapshot = await query.get();
      final questionCount = questionSnapshot.docs.length;
      print('DEBUG: Question count for test $testId: $questionCount');

      if (questionCount == 0) {
        print('DEBUG: Cannot publish test - no questions added');
        errorMessage.value = 'Cannot publish test without questions. Please add at least one question before publishing.';
        return false;
      }

      print('DEBUG: Test has $questionCount questions, proceeding to publish');
      return await updateTest(testId: testId, status: 'published');
    } catch (e) {
      print('DEBUG: Error in publishTest: $e');
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> closeTest({required String testId}) async {
    return await updateTest(testId: testId, status: 'closed');
  }

  Future<bool> releaseResults({required String testId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final resultController = Get.put(ResultController());

      // Calculate rankings first
      await resultController.calculateRankings(testId: testId);

      // Then update test status and mark results as released
      await _firestoreService.updateDocument(
        collectionPath: 'tests',
        documentId: testId,
        data: {
          'status': 'results_released',
          'resultsReleased': true,
          'resultsReleasedAt': DateTime.now().toIso8601String(),
        },
      );

      // Update all results to show position
      await resultController.fetchTestResults(testId: testId);
      for (final result in resultController.results) {
        await resultController.updateResultStatus(
          resultId: result.id!,
          showPosition: true,
        );
      }

      await fetchAllTests();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  TestModel? getTestById(String testId) {
    try {
      return tests.firstWhere((test) => test.id == testId);
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateTestQuestionCount({
    required String testId,
    required int questionCount,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _firestoreService.updateDocument(
        collectionPath: 'tests',
        documentId: testId,
        data: {
          'questionCount': questionCount,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      await fetchAllTests();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> syncAllTestQuestionCounts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final testSnapshot = await _firestoreService.getCollection(
        collectionPath: 'tests',
      );

      for (final testDoc in testSnapshot.docs) {
        final testId = testDoc.id;
        
        // Count questions for this test
        final query = _firestoreService.queryWhereEqualTo(
          collectionPath: 'questions',
          field: 'testId',
          value: testId,
        );
        
        final questionSnapshot = await query.get();
        final questionCount = questionSnapshot.docs.length;
        
        // Update test's questionCount
        await _firestoreService.updateDocument(
          collectionPath: 'tests',
          documentId: testId,
          data: {
            'questionCount': questionCount,
            'updatedAt': DateTime.now().toIso8601String(),
          },
        );
      }

      await fetchAllTests();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
