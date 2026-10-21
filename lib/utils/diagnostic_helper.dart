import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DiagnosticHelper {
  static Future<Map<String, dynamic>> diagnoseTestQuestions({
    required String testId,
    required String? studentId,
    required String courseId,
  }) async {
    final results = <String, dynamic>{};

    try {
      final firestore = FirebaseFirestore.instance;

      // 1. Check if test exists and its status
      results['step1_test_check'] = 'Checking test document...';
      final testDoc = await firestore.collection('tests').doc(testId).get();
      if (testDoc.exists) {
        final testData = testDoc.data()!;
        results['test_exists'] = true;
        results['test_status'] = testData['status'];
        results['test_questionCount'] = testData['questionCount'];
        results['test_courseId'] = testData['courseId'];
        results['step1_test_check'] = '✓ Test found: ${testData['status']}';
      } else {
        results['test_exists'] = false;
        results['step1_test_check'] = '✗ Test not found';
        return results;
      }

      // 2. Check if questions exist in database
      results['step2_questions_check'] = 'Checking questions collection...';
      final questionsQuery = firestore
          .collection('questions')
          .where('testId', isEqualTo: testId);
      final questionsSnapshot = await questionsQuery.get();
      results['questions_count_in_db'] = questionsSnapshot.docs.length;
      results['step2_questions_check'] =
          '✓ Found ${questionsSnapshot.docs.length} questions in database';

      // 3. Try to read questions (this will fail if rules block access)
      results['step3_permissions_check'] = 'Checking read permissions...';
      try {
        final testRead = questionsSnapshot.docs.first.data();
        results['can_read_questions'] = true;
        results['step3_permissions_check'] = '✓ Can read questions (rules allow access)';
        final questionText = testRead['question'] as String?;
        if (questionText != null && questionText.length > 50) {
          results['sample_question'] = questionText.substring(0, 50);
        } else {
          results['sample_question'] = questionText ?? '';
        }
      } catch (e) {
        results['can_read_questions'] = false;
        results['permission_error'] = e.toString();
        results['step3_permissions_check'] =
            '✗ Cannot read questions (likely blocked by Firestore rules)';
      }

      // 4. Check student enrollment if studentId provided
      if (studentId != null) {
        results['step4_enrollment_check'] = 'Checking student enrollment...';
        final enrollmentQuery = firestore
            .collection('enrollments')
            .where('studentId', isEqualTo: studentId)
            .where('courseId', isEqualTo: courseId)
            .where('status', isEqualTo: 'active');
        final enrollmentSnapshot = await enrollmentQuery.get();
        results['is_enrolled'] = enrollmentSnapshot.docs.isNotEmpty;
        results['step4_enrollment_check'] = results['is_enrolled']
            ? '✓ Student is enrolled in course'
            : '✗ Student is not enrolled in course';
      }

      // 5. Diagnosis summary
      results['diagnosis'] = _generateDiagnosis(results);

    } catch (e) {
      results['error'] = e.toString();
      results['diagnosis'] = 'Error during diagnosis: $e';
    }

    return results;
  }

  static String _generateDiagnosis(Map<String, dynamic> results) {
    // Check if test exists
    if (results['test_exists'] == false) {
      return 'ISSUE: Test does not exist in database';
    }

    // Check if test is published
    if (results['test_status'] != 'published') {
      return 'ISSUE: Test is not published (status: ${results['test_status']})';
    }

    // Check if questions exist
    if (results['questions_count_in_db'] == 0) {
      return 'ISSUE: Test has no questions in database. Teacher needs to add questions.';
    }

    // Check if can read questions
    if (results['can_read_questions'] == false) {
      return 'ISSUE: Firestore security rules are blocking access to questions. '
          'SOLUTION: Deploy the updated rules from FIRESTORE_RULES.md to Firebase Console. '
          'The rules were updated to match the actual enrollment structure (top-level collection with studentId field).';
    }

    // Check enrollment (client-side validation only, not enforced by rules)
    if (results.containsKey('is_enrolled') && results['is_enrolled'] == false) {
      return 'ISSUE: Student is not enrolled in the test\'s course. This is checked client-side before loading questions.';
    }

    // Everything looks good
    return '✓ All checks passed. Questions should load correctly. '
        'If still not working, check client-side error handling.';
  }

  static void printDiagnostics(Map<String, dynamic> results) {
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('DIAGNOSTIC RESULTS');
    debugPrint('═══════════════════════════════════════════════════════════');
    results.forEach((key, value) {
      debugPrint('$key: $value');
    });
    debugPrint('═══════════════════════════════════════════════════════════');
  }
}
