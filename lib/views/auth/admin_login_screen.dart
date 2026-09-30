import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../app/theme/app_theme.dart' as theme;

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _obscurePassword = true.obs;

  final AuthController _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await _authController.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

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
                    Icons.admin_panel_settings,
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
                    'Admin Portal',
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  CustomTextField(
                    label: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
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
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
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
                  Obx(
                    () => CustomButton(
                      text: 'Login as Admin',
                      onPressed: _handleLogin,
                      isLoading: _authController.isLoading.value,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an admin account? "),
                      TextButton(
                        onPressed: () {
                          Get.toNamed('/admin-signup');
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
}
