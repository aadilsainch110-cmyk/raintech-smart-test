import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  User? get firebaseUser => _firebaseUser.value;
  UserModel? get currentUser => _currentUser.value;
  bool get isAuthenticated => _firebaseUser.value != null;
  String? get userRole => _currentUser.value?.role;

  @override
  void onInit() {
    super.onInit();
    _firebaseUser.bindStream(_authService.authStateChanges);
    ever(_firebaseUser, _handleAuthStateChange);
  }

  Future<void> _handleAuthStateChange(User? user) async {
    if (user != null) {
      await _loadUserData(user.uid);
    } else {
      _currentUser.value = null;
    }
  }

  Future<void> _loadUserData(String userId) async {
    try {
      isLoading.value = true;
      final doc = await _firestoreService.getDocument(
        collectionPath: 'users',
        documentId: userId,
      );

      if (doc.exists) {
        _currentUser.value = UserModel.fromJson(
          doc.data() as Map<String, dynamic>,
          id: doc.id,
        );

        if (_currentUser.value?.isActive == false) {
          await signOut();
          Get.snackbar(
            'Account Deactivated',
            'Your account has been deactivated. Please contact admin.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        _navigateBasedOnRole();
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _navigateBasedOnRole() {
    final role = _currentUser.value?.role;
    switch (role) {
      case 'student':
        Get.offAllNamed(Routes.STUDENT_HOME);
        break;
      case 'teacher':
        Get.offAllNamed(Routes.TEACHER_DASHBOARD);
        break;
      case 'admin':
        Get.offAllNamed(Routes.ADMIN_DASHBOARD);
        break;
      default:
        Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _getAuthErrorMessage(e.code);
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? studentId,
    String? classId,
    String? shiftId,
    String role = 'student',
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userCredential = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userModel = UserModel(
        id: userCredential.user?.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        studentId: studentId,
        classId: classId,
        shiftId: shiftId,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await _firestoreService.setDocument(
        collectionPath: 'users',
        documentId: userCredential.user!.uid,
        data: userModel.toJson(),
      );

      await _authService.updateDisplayName(displayName: name);

      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _getAuthErrorMessage(e.code);
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resetPassword({required String email}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.sendPasswordResetEmail(email: email);

      Get.snackbar(
        'Password Reset',
        'Password reset email sent to $email',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _getAuthErrorMessage(e.code);
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser.value = null;
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'email-already-in-use':
        return 'Email is already registered.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
