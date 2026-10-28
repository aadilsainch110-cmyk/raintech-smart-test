import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart' as theme;
import '../../controllers/auth_controller.dart';
import '../../services/preferences_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final AuthController _authController = Get.put(AuthController());
  final PreferencesService _prefsService = PreferencesService();

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _checkAuthAndNavigate();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward();
  }

  void _checkAuthAndNavigate() async {
    // Wait for Firebase to initialize and check auth state
    await Future.delayed(const Duration(seconds: 2));

    // Check both Firebase auth state and saved preferences
    final isFirebaseLoggedIn = _authController.isAuthenticated;
    final isPrefsLoggedIn = await _prefsService.isLoggedIn();
    final savedRole = await _prefsService.getUserRole();

    if (isFirebaseLoggedIn && _authController.currentUser != null) {
      // Firebase auth is active, use it
      final role = _authController.userRole;
      _navigateBasedOnRole(role);
    } else if (isPrefsLoggedIn && savedRole != null) {
      // Firebase might not be initialized yet, but we have saved login state
      // Navigate to appropriate dashboard (Firebase will load user data)
      _navigateBasedOnRole(savedRole);
    } else {
      // Not logged in, go to login screen
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  void _navigateBasedOnRole(String? role) {
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: theme.AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo/Icon
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha:0.2),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha:0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.school,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // App Name
                          const Text(
                            'RAINTECH',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Tagline
                          const Text(
                            'Smart Testing System',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 48),
                          // Loading Indicator
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 48),
                          // Developed By Section
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: const Column(
                              children: [
                                Text(
                                  'Developed by',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                    letterSpacing: 1,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Aadil Ali & Abdul Rehman',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
