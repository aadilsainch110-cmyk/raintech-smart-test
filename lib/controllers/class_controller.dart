import 'package:get/get.dart';
import '../models/class_model.dart';
import '../services/firestore_service.dart';

class ClassController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final RxList<ClassModel> classes = <ClassModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final snapshot = await _firestoreService.getCollection(
        collectionPath: 'classes',
      );

      classes.value = snapshot.docs
          .map((doc) {
            return ClassModel.fromJson(
              doc.data() as Map<String, dynamic>,
              id: doc.id,
            );
          })
          .where((cls) => cls.isActive)
          .toList();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createClass({
    required String name,
    String? description,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final cls = ClassModel(
        name: name,
        description: description,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await _firestoreService.addDocument(
        collectionPath: 'classes',
        data: cls.toJson(),
      );

      await fetchClasses();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateClass({
    required String classId,
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
        collectionPath: 'classes',
        documentId: classId,
        data: data,
      );

      await fetchClasses();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteClass({required String classId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _firestoreService.updateDocument(
        collectionPath: 'classes',
        documentId: classId,
        data: {'isActive': false},
      );

      await fetchClasses();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  ClassModel? getClassById(String classId) {
    try {
      return classes.firstWhere((cls) => cls.id == classId);
    } catch (e) {
      return null;
    }
  }
}
