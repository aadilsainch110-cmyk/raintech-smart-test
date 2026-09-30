import 'package:get/get.dart';
import '../models/course_model.dart';
import '../services/firestore_service.dart';

// ignore_for_file: use_null_aware_elements

class CourseController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final RxList<CourseModel> courses = <CourseModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final snapshot = await _firestoreService.getCollection(
        collectionPath: 'courses',
      );

      courses.value = snapshot.docs
          .map((doc) {
            return CourseModel.fromJson(
              doc.data() as Map<String, dynamic>,
              id: doc.id,
            );
          })
          .where((course) => course.isActive)
          .toList();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createCourse({required String name, String? description}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final course = CourseModel(
        name: name,
        description: description,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await _firestoreService.addDocument(
        collectionPath: 'courses',
        data: course.toJson(),
      );

      await fetchCourses();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateCourse({
    required String courseId,
    required String name,
    String? description,
    bool? isActive,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = <String, dynamic>{
        'name': name,
        if (description != null) 'description': description,
        if (isActive != null) 'isActive': isActive,
      };

      await _firestoreService.updateDocument(
        collectionPath: 'courses',
        documentId: courseId,
        data: data,
      );

      await fetchCourses();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteCourse({required String courseId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _firestoreService.updateDocument(
        collectionPath: 'courses',
        documentId: courseId,
        data: {'isActive': false},
      );

      await fetchCourses();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  CourseModel? getCourseById(String courseId) {
    try {
      return courses.firstWhere((course) => course.id == courseId);
    } catch (e) {
      return null;
    }
  }
}
