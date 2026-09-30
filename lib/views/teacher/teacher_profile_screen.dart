import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../app/theme/app_theme.dart';
import '../../app/responsive/responsive_utils.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Obx(
        () => authController.currentUser == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: ResponsiveUtils.responsivePadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: ResponsiveUtils.responsiveSpacing(context, 50),
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          authController.currentUser!.name[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: ResponsiveUtils.responsiveFontSize(
                              context,
                              32,
                            ),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveUtils.responsiveSpacing(context, 24),
                    ),
                    Center(
                      child: Text(
                        authController.currentUser!.name,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.responsiveFontSize(
                            context,
                            24,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveUtils.responsiveSpacing(context, 8),
                    ),
                    Center(
                      child: Chip(
                        label: Text(
                          authController.currentUser!.role.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: AppTheme.primaryColor.withValues(
                          alpha: 0.1,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveUtils.responsiveSpacing(context, 32),
                    ),
                    _buildProfileField(
                      'Email',
                      authController.currentUser!.email,
                      Icons.email_outlined,
                    ),
                    if (authController.currentUser!.phone != null)
                      _buildProfileField(
                        'Phone',
                        authController.currentUser!.phone!,
                        Icons.phone_outlined,
                      ),
                    SizedBox(
                      height: ResponsiveUtils.responsiveSpacing(context, 32),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          authController.signOut();
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.responsiveSpacing(
                              context,
                              24,
                            ),
                            vertical: ResponsiveUtils.responsiveSpacing(
                              context,
                              16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value, IconData icon) {
    return Builder(
      builder: (context) => Card(
        margin: EdgeInsets.only(
          bottom: ResponsiveUtils.responsiveSpacing(context, 12),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: ResponsiveUtils.responsiveIconSize(context, 24),
          ),
          title: Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 12),
              color: AppTheme.textSecondary,
            ),
          ),
          subtitle: Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
