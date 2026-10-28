import 'package:get/get.dart';
import '../models/user_model.dart';
import '../models/class_model.dart';
import '../models/shift_model.dart';
import '../services/firestore_service.dart';
import '../controllers/auth_controller.dart';

// ignore_for_file: use_null_aware_elements

class AdminController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<ClassModel> classes = <ClassModel>[].obs;
  final RxList<ShiftModel> shifts = <ShiftModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<UserModel> pendingUsers = <UserModel>[].obs;
  final RxList<UserModel> approvedUsers = <UserModel>[].obs;
  final RxList<UserModel> rejectedUsers = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    await Future.wait([fetchAllUsers(), fetchAllClasses(), fetchAllShifts()]);
  }

  Future<void> fetchAllUsers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final snapshot = await _firestoreService.getCollection(
        collectionPath: 'users',
      );

      users.value = snapshot.docs.map((doc) {
        return UserModel.fromJson(
          doc.data() as Map<String, dynamic>,
          id: doc.id,
        );
      }).toList();

      // Update filtered lists
      _updateFilteredUsers();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _updateFilteredUsers() {
    pendingUsers.value = users
        .where((user) =>
            user.approvalStatus == 'pending' &&
            (user.role == 'student' || user.role == 'teacher'))
        .toList();

    approvedUsers.value = users
        .where((user) =>
            user.approvalStatus == 'approved' &&
            (user.role == 'student' || user.role == 'teacher'))
        .toList();

    rejectedUsers.value = users
        .where((user) =>
            user.approvalStatus == 'rejected' &&
            (user.role == 'student' || user.role == 'teacher'))
        .toList();
  }

  Future<void> fetchAllClasses() async {
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

  Future<void> fetchAllShifts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final snapshot = await _firestoreService.getCollection(
        collectionPath: 'shifts',
      );

      shifts.value = snapshot.docs
          .map((doc) {
            return ShiftModel.fromJson(
              doc.data() as Map<String, dynamic>,
              id: doc.id,
            );
          })
          .where((shift) => shift.isActive)
          .toList();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createClass({required String name, String? description}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final classModel = ClassModel(
        name: name,
        description: description,
        isActive: true,
      );

      await _firestoreService.addDocument(
        collectionPath: 'classes',
        data: classModel.toJson(),
      );

      await fetchAllClasses();
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

      await fetchAllClasses();
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

      await fetchAllClasses();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createShift({
    required String name,
    String? description,
    String? startTime,
    String? endTime,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final shiftModel = ShiftModel(
        name: name,
        description: description,
        startTime: startTime,
        endTime: endTime,
        isActive: true,
      );

      await _firestoreService.addDocument(
        collectionPath: 'shifts',
        data: shiftModel.toJson(),
      );

      await fetchAllShifts();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateShift({
    required String shiftId,
    required String name,
    String? description,
    String? startTime,
    String? endTime,
    bool? isActive,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = <String, dynamic>{
        'name': name,
        if (description != null) 'description': description,
        if (startTime != null) 'startTime': startTime,
        if (endTime != null) 'endTime': endTime,
        if (isActive != null) 'isActive': isActive,
      };

      await _firestoreService.updateDocument(
        collectionPath: 'shifts',
        documentId: shiftId,
        data: data,
      );

      await fetchAllShifts();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteShift({required String shiftId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _firestoreService.updateDocument(
        collectionPath: 'shifts',
        documentId: shiftId,
        data: {'isActive': false},
      );

      await fetchAllShifts();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateUser({
    required String userId,
    String? name,
    String? phone,
    String? studentId,
    String? classId,
    String? shiftId,
    String? role,
    bool? isActive,
    String? approvalStatus,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (studentId != null) data['studentId'] = studentId;
      if (classId != null) data['classId'] = classId;
      if (shiftId != null) data['shiftId'] = shiftId;
      if (role != null) data['role'] = role;
      if (isActive != null) data['isActive'] = isActive;
      if (approvalStatus != null) data['approvalStatus'] = approvalStatus;

      await _firestoreService.updateDocument(
        collectionPath: 'users',
        documentId: userId,
        data: data,
      );

      await fetchAllUsers();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> approveUser({required String userId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = getUserById(userId);
      if (user == null) return false;

      // Determine the actual role from user data or keep it as is
      final actualRole = user.role;

      await _firestoreService.updateDocument(
        collectionPath: 'users',
        documentId: userId,
        data: {
          'approvalStatus': 'approved',
          'role': actualRole,
        },
      );

      await fetchAllUsers();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> rejectUser({required String userId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _firestoreService.updateDocument(
        collectionPath: 'users',
        documentId: userId,
        data: {'approvalStatus': 'rejected'},
      );

      await fetchAllUsers();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  List<UserModel> getPendingUsers() {
    return pendingUsers;
  }

  List<UserModel> getApprovedUsers() {
    return approvedUsers;
  }

  List<UserModel> getRejectedUsers() {
    return rejectedUsers;
  }

  ClassModel? getClassById(String classId) {
    try {
      return classes.firstWhere((cls) => cls.id == classId);
    } catch (e) {
      return null;
    }
  }

  ShiftModel? getShiftById(String shiftId) {
    try {
      return shifts.firstWhere((shift) => shift.id == shiftId);
    } catch (e) {
      return null;
    }
  }

  UserModel? getUserById(String userId) {
    try {
      return users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteUserPermanently({
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('=== DEBUG: deleteUserPermanently START ===');
      print('  - User ID: $userId');
      print('  - User Name: $userName');
      print('  - User Role: $userRole');

      final authController = Get.find<AuthController>();
      final currentAdminId = authController.currentUser?.id;

      print('  - Current Admin ID: $currentAdminId');

      if (currentAdminId == null) {
        print('  - ERROR: Admin not authenticated');
        errorMessage.value = 'Admin not authenticated';
        return false;
      }

      // Prevent self-deletion
      if (userId == currentAdminId) {
        print('  - ERROR: Cannot delete own account');
        errorMessage.value = 'You cannot delete your own account';
        return false;
      }

      // Check if it's an admin account
      final userDoc = await _firestoreService.getDocument(
        collectionPath: 'users',
        documentId: userId,
      );
      final userData = userDoc.data() as Map<String, dynamic>;
      if (userData['role'] == 'admin') {
        print('  - ERROR: Cannot delete admin account');
        errorMessage.value = 'Cannot delete admin accounts';
        return false;
      }

      // For teachers, check if they own any tests
      if (userRole == 'teacher') {
        final testsQuery = _firestoreService.queryWhereEqualTo(
          collectionPath: 'tests',
          field: 'teacherId',
          value: userId,
        );
        final testsSnapshot = await testsQuery.get();
        if (testsSnapshot.docs.isNotEmpty) {
          print('  - ERROR: Teacher has ${testsSnapshot.docs.length} test(s)');
          errorMessage.value = 'Cannot delete teacher with ${testsSnapshot.docs.length} test(s). Please reassign or delete tests first.';
          return false;
        }
      }

      print('  - Deleting Firestore records...');

      // Delete related records based on role
      if (userRole == 'student') {
        // Delete enrollments
        final enrollmentsQuery = _firestoreService.queryWhereEqualTo(
          collectionPath: 'enrollments',
          field: 'studentId',
          value: userId,
        );
        final enrollmentsSnapshot = await enrollmentsQuery.get();
        for (var doc in enrollmentsSnapshot.docs) {
          await _firestoreService.deleteDocument(
            collectionPath: 'enrollments',
            documentId: doc.id,
          );
        }
        print('  - Deleted ${enrollmentsSnapshot.docs.length} enrollment(s)');

        // Delete test attempts
        final attemptsQuery = _firestoreService.queryWhereEqualTo(
          collectionPath: 'attempts',
          field: 'studentId',
          value: userId,
        );
        final attemptsSnapshot = await attemptsQuery.get();
        for (var doc in attemptsSnapshot.docs) {
          await _firestoreService.deleteDocument(
            collectionPath: 'attempts',
            documentId: doc.id,
          );
        }
        print('  - Deleted ${attemptsSnapshot.docs.length} attempt(s)');

        // Delete results
        final resultsQuery = _firestoreService.queryWhereEqualTo(
          collectionPath: 'results',
          field: 'studentId',
          value: userId,
        );
        final resultsSnapshot = await resultsQuery.get();
        for (var doc in resultsSnapshot.docs) {
          await _firestoreService.deleteDocument(
            collectionPath: 'results',
            documentId: doc.id,
          );
        }
        print('  - Deleted ${resultsSnapshot.docs.length} result(s)');
      }

      // Delete the user document
      await _firestoreService.deleteDocument(
        collectionPath: 'users',
        documentId: userId,
      );
      print('  - Deleted user document');

      print('  - SUCCESS: User deleted successfully');
      // Refresh user list after successful deletion
      await fetchAllUsers();
      return true;
    } catch (e) {
      print('  - General Error: $e');
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
      print('=== DEBUG: deleteUserPermanently END ===');
    }
  }
}
