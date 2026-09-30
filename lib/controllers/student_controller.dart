import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class StudentController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final RxList<UserModel> students = <UserModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> fetchAllStudents() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final query = _firestoreService.queryWhereEqualTo(
        collectionPath: 'users',
        field: 'role',
        value: 'student',
      );
      
      final snapshot = await query.get();
      
      students.value = snapshot.docs.map((doc) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>, id: doc.id);
      }).toList();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchActiveStudents() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final query = _firestoreService.queryWhereEqualTo(
        collectionPath: 'users',
        field: 'role',
        value: 'student',
      );
      
      final snapshot = await query.get();
      
      students.value = snapshot.docs.map((doc) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>, id: doc.id);
      }).where((student) => student.isActive).toList();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateStudent({
    required String studentId,
    String? name,
    String? phone,
    String? studentIdNumber,
    bool? isActive,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (studentIdNumber != null) data['studentId'] = studentIdNumber;
      if (isActive != null) data['isActive'] = isActive;
      
      await _firestoreService.updateDocument(
        collectionPath: 'users',
        documentId: studentId,
        data: data,
      );
      
      await fetchAllStudents();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deactivateStudent({required String studentId}) async {
    return await updateStudent(
      studentId: studentId,
      isActive: false,
    );
  }

  Future<bool> activateStudent({required String studentId}) async {
    return await updateStudent(
      studentId: studentId,
      isActive: true,
    );
  }

  Future<bool> deleteStudent({required String studentId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await _firestoreService.deleteDocument(
        collectionPath: 'users',
        documentId: studentId,
      );
      
      await fetchAllStudents();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  UserModel? getStudentById(String studentId) {
    try {
      return students.firstWhere((student) => student.id == studentId);
    } catch (e) {
      return null;
    }
  }

  List<UserModel> searchStudents({required String query}) {
    final lowerQuery = query.toLowerCase();
    return students.where((student) =>
      student.name.toLowerCase().contains(lowerQuery) ||
      student.email.toLowerCase().contains(lowerQuery) ||
      (student.studentId?.toLowerCase().contains(lowerQuery) ?? false)
    ).toList();
  }
}
