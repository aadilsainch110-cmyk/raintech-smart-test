import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/admin_controller.dart';
import '../../app/theme/app_theme.dart' as theme;
import '../../app/responsive/responsive_utils.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final authController = Get.find<AuthController>();
  final adminController = Get.put(AdminController());

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await adminController.fetchAllData();
  }

  @override
  Widget build(BuildContext context) {
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
                        backgroundColor: theme.AppTheme.primaryColor,
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
                        backgroundColor: theme.AppTheme.primaryColor.withValues(
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
                    if (authController.currentUser!.studentId != null)
                      _buildProfileField(
                        'Student ID',
                        authController.currentUser!.studentId!,
                        Icons.badge_outlined,
                      ),
                    if (authController.currentUser!.classId != null)
                      _buildProfileField(
                        'Class',
                        adminController.classes
                                .where(
                                  (c) =>
                                      c.id ==
                                      authController.currentUser!.classId,
                                )
                                .firstOrNull
                                ?.name ??
                            'Unknown',
                        Icons.class_,
                      ),
                    if (authController.currentUser!.shiftId != null)
                      _buildProfileField(
                        'Shift',
                        adminController.shifts
                                .where(
                                  (s) =>
                                      s.id ==
                                      authController.currentUser!.shiftId,
                                )
                                .firstOrNull
                                ?.name ??
                            'Unknown',
                        Icons.access_time,
                      ),
                    SizedBox(
                      height: ResponsiveUtils.responsiveSpacing(context, 32),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showEditProfileDialog,
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                        style: ElevatedButton.styleFrom(
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
                    SizedBox(
                      height: ResponsiveUtils.responsiveSpacing(context, 12),
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
                          backgroundColor: theme.AppTheme.errorColor,
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: theme.AppTheme.primaryColor),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: theme.AppTheme.textSecondary,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(
      text: authController.currentUser!.name,
    );
    final phoneController = TextEditingController(
      text: authController.currentUser!.phone ?? '',
    );
    final studentIdController = TextEditingController(
      text: authController.currentUser!.studentId ?? '',
    );

    String? selectedClassId = authController.currentUser!.classId;
    String? selectedShiftId = authController.currentUser!.shiftId;

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: studentIdController,
                decoration: const InputDecoration(
                  labelText: 'Student ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => DropdownButtonFormField<String>(
                  initialValue: selectedClassId,
                  decoration: const InputDecoration(
                    labelText: 'Class (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: adminController.classes.map((cls) {
                    return DropdownMenuItem<String>(
                      value: cls.id,
                      child: Text(cls.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedClassId = value;
                  },
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => DropdownButtonFormField<String>(
                  initialValue: selectedShiftId,
                  decoration: const InputDecoration(
                    labelText: 'Shift (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: adminController.shifts.map((shift) {
                    return DropdownMenuItem<String>(
                      value: shift.id,
                      child: Text(shift.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedShiftId = value;
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter your name',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: theme.AppTheme.errorColor,
                  colorText: Colors.white,
                );
                return;
              }

              final success = await adminController.updateUser(
                userId: authController.currentUser!.id!,
                name: nameController.text,
                phone: phoneController.text.isEmpty
                    ? null
                    : phoneController.text,
                studentId: studentIdController.text.isEmpty
                    ? null
                    : studentIdController.text,
                classId: selectedClassId,
                shiftId: selectedShiftId,
              );

              if (success) {
                // Note: This would normally be done through the auth controller
                // For now, just show success message
                Get.back();
                Get.snackbar(
                  'Success',
                  'Profile updated successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: theme.AppTheme.successColor,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
