import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/preferences_service.dart';
import '../services/secret_code_service.dart';
import '../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final PreferencesService _prefsService = PreferencesService();

  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString generatedSecretCode = ''.obs;
  bool _hasNavigated = false; // Flag to prevent multiple navigations

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
      _hasNavigated = false; // Reset flag on logout
    }
  }

  Future<void> _loadUserData(String userId) async {
    try {
      isLoading.value = true;
      print('DEBUG: Loading user data from Firestore');
      print('  - Firebase UID: $userId');

      final doc = await _firestoreService.getDocument(
        collectionPath: 'users',
        documentId: userId,
      );

      if (doc.exists) {
        _currentUser.value = UserModel.fromJson(
          doc.data() as Map<String, dynamic>,
          id: doc.id,
        );

        print('DEBUG: User data loaded successfully');
        print('  - Firebase UID (id): ${_currentUser.value?.id}');
        print('  - Custom Student ID (studentId): ${_currentUser.value?.studentId ?? "NULL"}');
        print('  - Name: ${_currentUser.value?.name}');
        print('  - Email: ${_currentUser.value?.email}');
        print('  - Role: ${_currentUser.value?.role}');
        print('  - Address: ${_currentUser.value?.address ?? "NULL"}');

        if (_currentUser.value?.isActive == false) {
          await signOut();
          Get.snackbar(
            'Account Deactivated',
            'Your account has been deactivated. Please contact admin.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        // Only navigate if we haven't navigated yet (prevents repeated navigation)
        if (!_hasNavigated) {
          _navigateBasedOnRole();
          _hasNavigated = true;
        }
      } else {
        print('DEBUG: User document does not exist for UID: $userId');
      }
    } catch (e) {
      print('DEBUG: Error loading user data: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshUserData() async {
    if (_firebaseUser.value != null) {
      _hasNavigated = false; // Reset flag to allow re-navigation
      await _loadUserData(_firebaseUser.value!.uid);
    }
  }

  void _navigateBasedOnRole() {
    final role = _currentUser.value?.role;
    final approvalStatus = _currentUser.value?.approvalStatus ?? 'pending';

    // Check approval status for student and teacher
    if (role == 'student' || role == 'teacher') {
      if (approvalStatus == 'pending') {
        Get.offAllNamed(Routes.PENDING_APPROVAL);
        return;
      } else if (approvalStatus == 'rejected') {
        Get.offAllNamed(Routes.LOGIN);
        Get.snackbar(
          'Account Rejected',
          'Your account has been rejected by Admin.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

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

      // Save login state to preferences after successful login
      if (_firebaseUser.value != null && _currentUser.value != null) {
        await _prefsService.setLoginState(
          isLoggedIn: true,
          userRole: _currentUser.value?.role,
          userId: _firebaseUser.value?.uid,
        );
      }

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

  Future<bool> signInWithSecretCode({required String secretCode}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('DEBUG: signInWithSecretCode called');
      print('  - Secret Code: $secretCode');

      // Validate secret code format (exactly 6 digits)
      if (!SecretCodeService.isValidSecretCodeFormat(secretCode)) {
        errorMessage.value = 'Secret code must be exactly 6 digits.';
        print('  - Invalid format');
        return false;
      }

      print('  - Format valid, querying Firestore directly (fallback)...');

      // Fallback: Query Firestore directly instead of using Cloud Functions
      final query = _firestoreService.queryWhereEqualTo(
        collectionPath: 'users',
        field: 'secretCode',
        value: secretCode,
      );

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        errorMessage.value = 'Invalid secret code.';
        print('  - No user found with this secret code');
        return false;
      }

      final userDoc = snapshot.docs.first;
      final userData = userDoc.data() as Map<String, dynamic>?;

      if (userData == null) {
        errorMessage.value = 'User data not found.';
        print('  - User data is null');
        return false;
      }

      print('  - User found:');
      print('    - Name: ${userData['name']}');
      print('    - Email: ${userData['email']}');
      print('    - Role: ${userData['role']}');
      print('    - isActive: ${userData['isActive']}');
      print('    - approvalStatus: ${userData['approvalStatus']}');

      // Check if account is active
      if (userData['isActive'] == false) {
        errorMessage.value = 'This account has been deactivated.';
        print('  - Account is deactivated');
        return false;
      }

      // Check approval status
      final approvalStatus = userData['approvalStatus'];
      if (approvalStatus == 'pending') {
        errorMessage.value = 'Your account is pending approval. Admin Approved you and then enter.';
        print('  - Account is pending approval');
        return false;
      }

      if (approvalStatus == 'rejected') {
        errorMessage.value = 'Your account has been rejected by Admin.';
        print('  - Account is rejected');
        return false;
      }

      // Admin cannot login with secret code
      if (userData['role'] == 'admin') {
        errorMessage.value = 'Admin must use email/password login.';
        print('  - Admin cannot use secret code');
        return false;
      }

      // Set current user
      _currentUser.value = UserModel.fromJson(
        {
          'name': userData['name'],
          'email': userData['email'],
          'role': userData['role'],
          'isActive': userData['isActive'],
          'approvalStatus': userData['approvalStatus'],
        },
        id: userDoc.id,
      );

      // Save login state
      await _prefsService.setLoginState(
        isLoggedIn: true,
        userRole: userData['role'],
        userId: userDoc.id,
      );

      print('  - Login state saved');

      // Navigate based on role
      _hasNavigated = false;
      _navigateBasedOnRole();
      _hasNavigated = true;

      print('  - Navigation completed');
      return true;
    } catch (e) {
      print('  - General Error: $e');
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
    String? address,
    String? studentId,
    String? classId,
    String? shiftId,
    String role = 'student',
    String? manualSecretCode, // Optional manually generated secret code
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      generatedSecretCode.value = '';

      final userCredential = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Use manual secret code if provided, otherwise generate one
      String secretCode;
      if (manualSecretCode != null && manualSecretCode.isNotEmpty) {
        // Validate manual secret code format (exactly 6 digits)
        if (!SecretCodeService.isValidSecretCodeFormat(manualSecretCode)) {
          errorMessage.value = 'Secret code must be exactly 6 digits.';
          return false;
        }
        secretCode = manualSecretCode;
        generatedSecretCode.value = secretCode;
      } else {
        // Generate unique secret code
        bool isUnique = false;
        int attempts = 0;
        final maxAttempts = 10;

        while (!isUnique && attempts < maxAttempts) {
          secretCode = SecretCodeService.generateSecretCode(role: role);

          // Check if this code already exists
          final query = _firestoreService.queryWhereEqualTo(
            collectionPath: 'users',
            field: 'secretCode',
            value: secretCode,
          );

          final snapshot = await query.get();
          if (snapshot.docs.isEmpty) {
            isUnique = true;
            generatedSecretCode.value = secretCode;
          } else {
            attempts++;
          }
        }

        if (!isUnique) {
          errorMessage.value = 'Failed to generate unique secret code. Please try again.';
          return false;
        }
      }

      // Set approval status based on role
      final approvalStatus = role == 'admin' ? 'approved' : 'pending';

      final userModel = UserModel(
        id: userCredential.user?.uid,
        name: name,
        email: email,
        phone: phone,
        address: address,
        role: role,
        studentId: studentId,
        classId: classId,
        shiftId: shiftId,
        isActive: true,
        approvalStatus: approvalStatus,
        createdAt: DateTime.now(),
        secretCode: generatedSecretCode.value,
      );

      print('DEBUG: Saving user to Firestore');
      print('  - Firebase UID (id): ${userModel.id}');
      print('  - Custom Student ID (studentId): ${userModel.studentId ?? "NULL"}');
      print('  - Name: ${userModel.name}');
      print('  - Email: ${userModel.email}');
      print('  - Role: ${userModel.role}');
      print('  - Address: ${userModel.address ?? "NULL"}');
      print('  - Secret Code: ${userModel.secretCode}');

      await _firestoreService.setDocument(
        collectionPath: 'users',
        documentId: userCredential.user!.uid,
        data: userModel.toJson(),
      );

      print('DEBUG: User saved successfully');

      await _authService.updateDisplayName(displayName: name);

      // Save login state to preferences after successful signup
      await _prefsService.setLoginState(
        isLoggedIn: true,
        userRole: role,
        userId: userCredential.user?.uid,
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
      _hasNavigated = false; // Reset navigation flag
      generatedSecretCode.value = '';
      await _prefsService.clearLoginState(); // Clear saved login state
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
