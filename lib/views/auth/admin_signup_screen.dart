import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../app/theme/app_theme.dart' as theme;

class AdminSignupScreen extends StatefulWidget {
  const AdminSignupScreen({super.key});

  @override
  State<AdminSignupScreen> createState() => _AdminSignupScreenState();
}

class _AdminSignupScreenState extends State<AdminSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _adminCodeController = TextEditingController();
  final _obscurePassword = true.obs;
  final _obscureConfirmPassword = true.obs;

  final AuthController _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _adminCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      // Verify admin code (you can implement this as needed)
      if (_adminCodeController.text.trim() != 'ADMIN123') {
        Get.snackbar(
          'Invalid Code',
          'Please enter a valid admin registration code',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: theme.AppTheme.errorColor,
          colorText: Colors.white,
        );
        return;
      }

      final success = await _authController.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        role: 'admin',
      );

      if (!success && _authController.errorMessage.value.isNotEmpty) {
        Get.snackbar(
          'Signup Failed',
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
      appBar: AppBar(
        title: const Text('Admin Registration'),
      ),
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
                    'Admin Registration',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.AppTheme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Register as an administrator',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    label: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: Icons.person_outlined,
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
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
                  CustomTextField(
                    label: 'Phone (Optional)',
                    hintText: 'Enter your phone number',
                    prefixIcon: Icons.phone_outlined,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Admin Registration Code',
                    hintText: 'Enter admin code',
                    prefixIcon: Icons.security,
                    controller: _adminCodeController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter admin code';
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
                  const SizedBox(height: 16),
                  Obx(
                    () => CustomTextField(
                      label: 'Confirm Password',
                      hintText: 'Confirm your password',
                      prefixIcon: Icons.lock_outlined,
                      suffixIcon: _obscureConfirmPassword.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      obscureText: _obscureConfirmPassword.value,
                      onSuffixIconPressed: () {
                        _obscureConfirmPassword.value =
                            !_obscureConfirmPassword.value;
                      },
                      controller: _confirmPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(
                    () => CustomButton(
                      text: 'Create Admin Account',
                      onPressed: _handleSignup,
                      isLoading: _authController.isLoading.value,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? '),
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text('Login'),
                      ),
                    ],
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
