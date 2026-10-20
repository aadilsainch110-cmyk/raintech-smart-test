import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/auth_controller.dart';
import '../../app/theme/app_theme.dart' as theme;
import '../../app/responsive/responsive_utils.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _obscureCurrentPassword = true.obs;
  final _obscureNewPassword = true.obs;
  final _obscureConfirmPassword = true.obs;

  final AuthController _authController = Get.find<AuthController>();
  bool _isChanging = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isChanging = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar(
          'Error',
          'No user logged in',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: theme.AppTheme.errorColor,
          colorText: Colors.white,
        );
        return;
      }

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text.trim(),
      );

      try {
        await user.reauthenticateWithCredential(credential);
      } catch (e) {
        setState(() {
          _isChanging = false;
        });
        Get.snackbar(
          'Error',
          'Current password is incorrect',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: theme.AppTheme.errorColor,
          colorText: Colors.white,
        );
        return;
      }

      // Update password
      await user.updatePassword(_newPasswordController.text.trim());

      Get.snackbar(
        'Success',
        'Password changed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.AppTheme.successColor,
        colorText: Colors.white,
      );

      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to change password: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.AppTheme.errorColor,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isChanging = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Change Password'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: ResponsiveUtils.responsivePadding(context),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
              Text(
                'Change your password',
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 24),
                  fontWeight: FontWeight.bold,
                  color: theme.AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 8)),
              Text(
                'Enter your current password and a new password to update your account security.',
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                  color: theme.AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 32)),
              _buildPasswordField(
                context,
                'Current Password',
                _currentPasswordController,
                _obscureCurrentPassword,
                'Enter your current password',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
              _buildPasswordField(
                context,
                'New Password',
                _newPasswordController,
                _obscureNewPassword,
                'Enter your new password',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your new password';
                  }
                  if (value.trim().length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
              _buildPasswordField(
                context,
                'Confirm New Password',
                _confirmPasswordController,
                _obscureConfirmPassword,
                'Confirm your new password',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value.trim() != _newPasswordController.text.trim()) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 32)),
              _buildPasswordRequirements(context),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 32)),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    BuildContext context,
    String label,
    TextEditingController controller,
    RxBool obscureText,
    String hintText, {
    String? Function(String?)? validator,
  }) {
    return Obx(
      () => TextFormField(
        controller: controller,
        obscureText: obscureText.value,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText.value ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              obscureText.value = !obscureText.value;
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.responsiveBorderRadius(context, 12),
            ),
          ),
          filled: true,
          fillColor: Colors.grey.withValues(alpha: 0.05),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordRequirements(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtils.responsiveSpacing(context, 16),
      ),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.responsiveBorderRadius(context, 12),
        ),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue,
                size: ResponsiveUtils.responsiveIconSize(context, 20),
              ),
              SizedBox(width: ResponsiveUtils.responsiveSpacing(context, 8)),
              Text(
                'Password Requirements',
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 12)),
          _buildRequirementItem(context, 'At least 6 characters long'),
          _buildRequirementItem(context, 'Should not be same as current password'),
          _buildRequirementItem(context, 'Use a mix of letters and numbers'),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: ResponsiveUtils.responsiveSpacing(context, 8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: ResponsiveUtils.responsiveIconSize(context, 16),
            color: Colors.blue,
          ),
          SizedBox(width: ResponsiveUtils.responsiveSpacing(context, 8)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 12),
                color: theme.AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final double buttonHeight = ResponsiveUtils.responsiveButtonHeight(context);
    final double radius = ResponsiveUtils.responsiveBorderRadius(context, 12);

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: buttonHeight,
            child: OutlinedButton(
              onPressed: _isChanging ? null : () => Get.back(),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
        ),
        SizedBox(width: ResponsiveUtils.responsiveSpacing(context, 16)),
        Expanded(
          child: SizedBox(
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: _isChanging ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
              child: _isChanging
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Change Password'),
            ),
          ),
        ),
      ],
    );
  }
}
