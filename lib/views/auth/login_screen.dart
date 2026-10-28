import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart' as theme;
import '../../app/responsive/responsive_utils.dart';
import '../../widgets/responsive_wrapper.dart';

// ignore_for_file: deprecated_member_use

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _secretCodeController = TextEditingController();
  final _obscurePassword = true.obs;
  final _loginMethod = 'email'.obs; // 'email' or 'secret'

  final AuthController _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _secretCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      bool success = false;

      if (_loginMethod.value == 'email') {
        success = await _authController.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        success = await _authController.signInWithSecretCode(
          secretCode: _secretCodeController.text.trim().toUpperCase(),
        );
      }

      if (!success && _authController.errorMessage.value.isNotEmpty) {
        Get.snackbar(
          'Login Failed',
          _authController.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: theme.AppTheme.errorColor,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.AppTheme.backgroundColor,
              theme.AppTheme.surfaceColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: ResponsiveUtils.responsivePadding(context),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveUtils.getMaxWidth(context),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    // Logo and Title
                    Container(
                      padding: EdgeInsets.all(ResponsiveUtils.responsiveSpacing(context, 24)),
                      decoration: BoxDecoration(
                        gradient: theme.AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveBorderRadius(context, 20)),
                        boxShadow: [
                          BoxShadow(
                            color: theme.AppTheme.primaryColor.withValues(alpha:0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(ResponsiveUtils.responsiveSpacing(context, 20)),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha:0.2),
                              borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveBorderRadius(context, 16)),
                            ),
                            child: Icon(
                              Icons.school,
                              size: ResponsiveUtils.responsiveIconSize(context, 64),
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
                          Text(
                            'RAINTECH',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.responsiveFontSize(context, 28),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 4)),
                          Text(
                            'Online Testing System',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                              color: Colors.white.withValues(alpha:0.9),
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 40)),

                    // User type selection
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveUtils.responsiveSpacing(context, 20),
                        horizontal: ResponsiveUtils.responsiveSpacing(context, 24),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.responsiveBorderRadius(context, 16),
                        ),
                        border: Border.all(
                          color: theme.AppTheme.primaryColor.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'LOGIN AS',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                              fontWeight: FontWeight.bold,
                              color: theme.AppTheme.primaryColor,
                              letterSpacing: 2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 20)),
                          ResponsiveRow(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildUserTypeButton(
                                icon: Icons.school,
                                label: 'Student',
                                isSelected: true,
                                onTap: () {
                                  // Continue with student login (default)
                                },
                              ),
                              _buildUserTypeButton(
                                icon: Icons.person,
                                label: 'Teacher',
                                isSelected: false,
                                onTap: () {
                                  Get.toNamed('/teacher-login');
                                },
                              ),
                              _buildUserTypeButton(
                                icon: Icons.admin_panel_settings,
                                label: 'Admin',
                                isSelected: false,
                                onTap: () {
                                  Get.toNamed('/admin-login');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 32)),

                    // Login Method Selection
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveUtils.responsiveSpacing(context, 16),
                        horizontal: ResponsiveUtils.responsiveSpacing(context, 20),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.responsiveBorderRadius(context, 16),
                        ),
                        border: Border.all(
                          color: theme.AppTheme.primaryColor.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => _buildLoginMethodButton(
                                icon: Icons.email,
                                label: 'Email',
                                isSelected: _loginMethod.value == 'email',
                                onTap: () {
                                  _loginMethod.value = 'email';
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.responsiveSpacing(context, 12)),
                          Expanded(
                            child: Obx(
                              () => _buildLoginMethodButton(
                                icon: Icons.security,
                                label: 'Secret Code',
                                isSelected: _loginMethod.value == 'secret',
                                onTap: () {
                                  _loginMethod.value = 'secret';
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 24)),

                    // Email Field (only for email login)
                    Obx(
                      () => _loginMethod.value == 'email'
                          ? Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveBorderRadius(context, 16)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha:0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email Address',
                                  hintText: 'Enter your email',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveBorderRadius(context, 16)),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: ResponsiveUtils.responsiveSpacing(context, 20),
                                    vertical: ResponsiveUtils.responsiveSpacing(context, 16),
                                  ),
                                ),
                                validator: (value) {
                                  if (_loginMethod.value == 'email') {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!GetUtils.isEmail(value)) {
                                      return 'Please enter a valid email';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),

                    // Password Field (only for email login)
                    Obx(
                      () => _loginMethod.value == 'email'
                          ? Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveBorderRadius(context, 16)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha:0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Obx(
                                () => TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword.value,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: 'Enter your password',
                                    prefixIcon: const Icon(Icons.lock_outlined),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword.value
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                      onPressed: () {
                                        _obscurePassword.value =
                                            !_obscurePassword.value;
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveBorderRadius(context, 16)),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: ResponsiveUtils.responsiveSpacing(context, 20),
                                      vertical: ResponsiveUtils.responsiveSpacing(context, 16),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (_loginMethod.value == 'email') {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),

                    // Secret Code Field (only for secret code login)
                    Obx(
                      () => _loginMethod.value == 'secret'
                          ? Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveBorderRadius(context, 16)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha:0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _secretCodeController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Secret Code',
                                  hintText: 'Enter 6-digit code (e.g., 112233)',
                                  prefixIcon: const Icon(Icons.security),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveBorderRadius(context, 16)),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: ResponsiveUtils.responsiveSpacing(context, 20),
                                    vertical: ResponsiveUtils.responsiveSpacing(context, 16),
                                  ),
                                ),
                                validator: (value) {
                                  if (_loginMethod.value == 'secret') {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your secret code';
                                    }
                                    if (value.length != 6) {
                                      return 'Secret code must be exactly 6 digits';
                                    }
                                    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                                      return 'Secret code must contain only digits';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 12)),

                    // Forgot Password (only for email login)
                    Obx(
                      () => _loginMethod.value == 'email'
                          ? Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Get.toNamed(Routes.FORGOT_PASSWORD);
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: theme.AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    Obx(
                      () => Container(
                        height: ResponsiveUtils.responsiveButtonHeight(context),
                        decoration: BoxDecoration(
                          gradient: theme.AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveBorderRadius(context, 16)),
                          boxShadow: [
                            BoxShadow(
                              color: theme.AppTheme.primaryColor.withValues(alpha:
                                0.3,
                              ),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveBorderRadius(context, 16)),
                            ),
                          ),
                          child: _authController.isLoading.value
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 24)),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: theme.AppTheme.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.toNamed(Routes.SIGNUP);
                          },
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              color: theme.AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 32)),

                    // Developer Credits Footer
                    Column(
                      children: [
                        Text(
                          'Developed by',
                          style: TextStyle(
                            color: theme.AppTheme.textSecondary.withValues(alpha: 0.7),
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 4)),
                        Text(
                          'Aadil Ali & Abdul Rehman',
                          style: TextStyle(
                            color: theme.AppTheme.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildLoginMethodButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveBorderRadius(context, 12)),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveUtils.responsiveSpacing(context, 12),
            horizontal: ResponsiveUtils.responsiveSpacing(context, 16),
          ),
          decoration: BoxDecoration(
            gradient: isSelected ? theme.AppTheme.primaryGradient : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveBorderRadius(context, 12)),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : theme.AppTheme.primaryColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: ResponsiveUtils.responsiveIconSize(context, 20),
                color: isSelected ? Colors.white : theme.AppTheme.primaryColor,
              ),
              SizedBox(width: ResponsiveUtils.responsiveSpacing(context, 8)),
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : theme.AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) => Flexible(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.responsiveSpacing(context, 6)),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveBorderRadius(context, 16)),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveUtils.responsiveSpacing(context, 20),
                horizontal: ResponsiveUtils.responsiveSpacing(context, 16),
              ),
              decoration: BoxDecoration(
                gradient: isSelected ? theme.AppTheme.primaryGradient : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveBorderRadius(context, 16)),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : theme.AppTheme.primaryColor.withValues(alpha: 0.3),
                  width: 2.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.AppTheme.primaryColor.withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: ResponsiveUtils.responsiveIconSize(context, 36),
                    color: isSelected
                        ? Colors.white
                        : theme.AppTheme.primaryColor,
                  ),
                  SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 12)),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 15),
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : theme.AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
