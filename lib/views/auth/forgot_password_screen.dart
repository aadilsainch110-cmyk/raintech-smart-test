import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_text_field.dart';
import '../../app/theme/app_theme.dart' as theme;
import '../../app/responsive/responsive_utils.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  final AuthController _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      final success = await _authController.resetPassword(
        email: _emailController.text.trim(),
      );

      if (!success && _authController.errorMessage.value.isNotEmpty) {
        Get.snackbar(
          'Error',
          _authController.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: theme.AppTheme.errorColor,
          colorText: Colors.white,
        );
      } else if (success) {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
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
                  maxWidth: 500,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.all(ResponsiveUtils.responsiveSpacing(context, 24)),
                        decoration: BoxDecoration(
                          gradient: theme.AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveBorderRadius(context, 20)),
                          boxShadow: [
                            BoxShadow(
                              color: theme.AppTheme.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.lock_reset,
                          size: ResponsiveUtils.responsiveIconSize(context, 64),
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 32)),
                      Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.responsiveFontSize(context, 24),
                          fontWeight: FontWeight.bold,
                          color: theme.AppTheme.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 8)),
                      Text(
                        'Enter your email address and we\'ll send you a link to reset your password.',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                          color: theme.AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 32)),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveBorderRadius(context, 16)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CustomTextField(
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
                      ),
                      SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 24)),
                      Obx(
                        () => SizedBox(
                          height: ResponsiveUtils.responsiveButtonHeight(context),
                          child: ElevatedButton(
                            onPressed: _handleResetPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.AppTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveBorderRadius(context, 16)),
                              ),
                            ),
                            child: _authController.isLoading.value
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Send Reset Link',
                                    style: TextStyle(
                                      fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: Text(
                          'Back to Login',
                          style: TextStyle(
                            color: theme.AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
}
