import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../app/theme/app_theme.dart' as theme;

class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  State<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.school,
                    size: 80,
                    color: theme.AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'RAINTECH',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: theme.AppTheme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Teacher Portal',
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Login Method Selection
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
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
                        const SizedBox(width: 12),
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
                  const SizedBox(height: 24),

                  // Email Field (only for email login)
                  Obx(
                    () => _loginMethod.value == 'email'
                        ? Column(
                            children: [
                              CustomTextField(
                                label: 'Email',
                                hintText: 'Enter your email',
                                prefixIcon: Icons.email_outlined,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
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
                              const SizedBox(height: 16),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Password Field (only for email login)
                  Obx(
                    () => _loginMethod.value == 'email'
                        ? Column(
                            children: [
                              Obx(
                                () => CustomTextField(
                                  label: 'Password',
                                  hintText: 'Enter your password',
                                  prefixIcon: Icons.lock_outlined,
                                  suffixIcon: _obscurePassword.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  obscureText: _obscurePassword.value,
                                  onSuffixIconPressed: () {
                                    _obscurePassword.value = !_obscurePassword.value;
                                  },
                                  controller: _passwordController,
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
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Get.toNamed('/forgot-password');
                                  },
                                  child: const Text('Forgot Password?'),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Secret Code Field (only for secret code login)
                  Obx(
                    () => _loginMethod.value == 'secret'
                        ? Column(
                            children: [
                              CustomTextField(
                                label: 'Secret Code',
                                hintText: 'Enter 6-digit code (e.g., 112233)',
                                prefixIcon: Icons.security,
                                controller: _secretCodeController,
                                keyboardType: TextInputType.number,
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
                              const SizedBox(height: 24),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),

                  Obx(
                    () => CustomButton(
                      text: 'Login as Teacher',
                      onPressed: _handleLogin,
                      isLoading: _authController.isLoading.value,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have a teacher account? "),
                      TextButton(
                        onPressed: () {
                          Get.toNamed('/teacher-signup');
                        },
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text('Back to Main Login'),
                  ),
                ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? theme.AppTheme.primaryGradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
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
              size: 20,
              color: isSelected ? Colors.white : theme.AppTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : theme.AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
