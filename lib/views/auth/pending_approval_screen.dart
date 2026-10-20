import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../app/theme/app_theme.dart' as theme;
import '../../app/responsive/responsive_utils.dart';

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  final AuthController _authController = Get.find<AuthController>();
  bool _isChecking = false;

  Future<void> _checkApproval() async {
    setState(() {
      _isChecking = true;
    });

    await _authController.refreshUserData();

    setState(() {
      _isChecking = false;
    });
  }

  Future<void> _handleLogout() async {
    await _authController.signOut();
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon
                    Container(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.responsiveSpacing(context, 32),
                      ),
                      decoration: BoxDecoration(
                        gradient: theme.AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.AppTheme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.pending_outlined,
                        size: ResponsiveUtils.responsiveIconSize(context, 80),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 32)),

                    // Title
                    Text(
                      'Admin Approval Required',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.responsiveFontSize(context, 28),
                        fontWeight: FontWeight.bold,
                        color: theme.AppTheme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),

                    // Description
                    Container(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.responsiveSpacing(context, 24),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.responsiveBorderRadius(context, 16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Admin Approved you and then you can enter the application.',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                              color: theme.AppTheme.textSecondary,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 24)),
                          _buildInfoRow(
                            icon: Icons.person,
                            label: 'Name',
                            value: _authController.currentUser?.name ?? 'Loading...',
                          ),
                          SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
                          _buildInfoRow(
                            icon: Icons.email,
                            label: 'Email',
                            value: _authController.currentUser?.email ?? 'Loading...',
                          ),
                          SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
                          _buildInfoRow(
                            icon: Icons.badge,
                            label: 'Status',
                            value: 'Pending',
                            valueColor: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 32)),

                    // Check Approval Button
                    ElevatedButton.icon(
                      onPressed: _isChecking ? null : _checkApproval,
                      icon: _isChecking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(
                        _isChecking ? 'Checking...' : 'Check Approval',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveUtils.responsiveSpacing(context, 16),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.responsiveBorderRadius(context, 12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),

                    // Logout Button
                    OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout),
                      label: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.AppTheme.errorColor,
                        side: BorderSide(
                          color: theme.AppTheme.errorColor,
                          width: 2,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveUtils.responsiveSpacing(context, 16),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.responsiveBorderRadius(context, 12),
                          ),
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
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: theme.AppTheme.primaryColor,
          size: 20,
        ),
        SizedBox(width: ResponsiveUtils.responsiveSpacing(context, 12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 12),
                  color: theme.AppTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? theme.AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
