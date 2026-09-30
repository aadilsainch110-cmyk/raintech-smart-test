import 'package:get/get.dart';
import '../models/enrollment_model.dart';
import '../services/firestore_service.dart';

class EnrollmentController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final RxList<EnrollmentModel> enrollments = <EnrollmentModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> fetchStudentEnrollments({required String studentId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final query = _firestoreService.queryWhereEqualTo(
        collectionPath: 'enrollments',
        field: 'studentId',
        value: studentId,
      );

      final snapshot = await query.get();

      enrollments.value = snapshot.docs
          .map((doc) {
            return EnrollmentModel.fromJson(
              doc.data() as Map<String, dynamic>,
              id: doc.id,
            );
          })
          .where((enrollment) => enrollment.status == 'active')
          .toList();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllEnrollments() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final snapshot = await _firestoreService.getCollection(
        collectionPath: 'enrollments',
      );

      enrollments.value = snapshot.docs.map((doc) {
        return EnrollmentModel.fromJson(
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

  Future<bool> createEnrollment({
    required String studentId,
    required String courseId,
    String? classId,
    required String shiftId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final enrollment = EnrollmentModel(
        studentId: studentId,
        courseId: courseId,
        classId: classId,
        shiftId: shiftId,
        status: 'active',
        createdAt: DateTime.now(),
      );

      await _firestoreService.addDocument(
        collectionPath: 'enrollments',
        data: enrollment.toJson(),
      );

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateEnrollment({
    required String enrollmentId,
    String? status,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = <String, dynamic>{};
      if (status != null) data['status'] = status;

      await _firestoreService.updateDocument(
        collectionPath: 'enrollments',
        documentId: enrollmentId,
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

  Future<bool> deleteEnrollment({required String enrollmentId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _firestoreService.deleteDocument(
        collectionPath: 'enrollments',
        documentId: enrollmentId,
      );

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  List<EnrollmentModel> getStudentEnrollmentsByCourse({
    required String studentId,
    required String courseId,
  }) {
    return enrollments
        .where(
          (e) =>
              e.studentId == studentId &&
              e.courseId == courseId &&
              e.status == 'active',
        )
        .toList();
  }

  EnrollmentModel? getStudentEnrollmentByShift({
    required String studentId,
    required String courseId,
    required String shiftId,
  }) {
    try {
      return enrollments.firstWhere(
        (e) =>
            e.studentId == studentId &&
            e.courseId == courseId &&
            e.shiftId == shiftId &&
            e.status == 'active',
      );
    } catch (e) {
      return null;
    }
  }
}
