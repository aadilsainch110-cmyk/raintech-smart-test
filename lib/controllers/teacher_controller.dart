import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class TeacherController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final RxList<UserModel> teachers = <UserModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;


  Future<void> fetchAllTeachers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final query = _firestoreService.queryWhereEqualTo(
        collectionPath: 'users',
        field: 'role',
        value: 'teacher',
      );
      
      final snapshot = await query.get();
      
      teachers.value = snapshot.docs.map((doc) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>, id: doc.id);
      }).toList();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createTeacher({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final userModel = UserModel(
        name: name,
        email: email,
        phone: phone,
        role: 'teacher',
        isActive: true,
        createdAt: DateTime.now(),
      );
      
      await _firestoreService.addDocument(
        collectionPath: 'users',
        data: userModel.toJson(),
      );
      
      await fetchAllTeachers();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateTeacher({
    required String teacherId,
    String? name,
    String? phone,
    bool? isActive,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (isActive != null) data['isActive'] = isActive;
      
      await _firestoreService.updateDocument(
        collectionPath: 'users',
        documentId: teacherId,
        data: data,
      );
      
      await fetchAllTeachers();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deactivateTeacher({required String teacherId}) async {
    return await updateTeacher(
      teacherId: teacherId,
      isActive: false,
    );
  }

  Future<bool> activateTeacher({required String teacherId}) async {
    return await updateTeacher(
      teacherId: teacherId,
      isActive: true,
    );
  }

  Future<bool> deleteTeacher({required String teacherId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await _firestoreService.deleteDocument(
        collectionPath: 'users',
        documentId: teacherId,
      );
      
      await fetchAllTeachers();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  UserModel? getTeacherById(String teacherId) {
    try {
      return teachers.firstWhere((teacher) => teacher.id == teacherId);
    } catch (e) {
      return null;
    }
  }

  List<UserModel> searchTeachers({required String query}) {
    final lowerQuery = query.toLowerCase();
    return teachers.where((teacher) =>
      teacher.name.toLowerCase().contains(lowerQuery) ||
      teacher.email.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}
