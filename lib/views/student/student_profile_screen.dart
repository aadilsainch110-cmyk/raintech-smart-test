import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

import '../../controllers/auth_controller.dart';
import '../../controllers/admin_controller.dart';
import '../../services/firestore_service.dart';
import '../../app/theme/app_theme.dart' as theme;
import '../../app/responsive/responsive_utils.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  late final AuthController authController;
  late final AdminController adminController;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();

    authController = Get.find<AuthController>();
    adminController = Get.put(AdminController());

    _loadData();
  }

  Future<void> _loadData() async {
    await adminController.fetchAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('My Profile'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Get.toNamed('/student/edit-profile');
            },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Get.toNamed('/settings');
            },
          ),
        ],
      ),

      body: Obx(() {
        final user = authController.currentUser;

        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          padding: ResponsiveUtils.responsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(context),

              SizedBox(
                height: ResponsiveUtils.responsiveSpacing(
                  context,
                  24,
                ),
              ),

              _buildProfileField(
                context,
                'Email',
                user.email,
                Icons.email_outlined,
              ),

              if (user.phone != null && user.phone!.isNotEmpty)
                _buildProfileField(
                  context,
                  'Phone',
                  user.phone!,
                  Icons.phone_outlined,
                ),

              if (user.studentId != null &&
                  user.studentId!.isNotEmpty)
                _buildProfileField(
                  context,
                  'Student ID',
                  user.studentId!,
                  Icons.badge_outlined,
                ),

              if (user.classId != null)
                _buildProfileField(
                  context,
                  'Class',
                  _getClassName(user.classId!),
                  Icons.class_outlined,
                ),

              if (user.shiftId != null)
                _buildProfileField(
                  context,
                  'Shift',
                  _getShiftName(user.shiftId!),
                  Icons.access_time_outlined,
                ),

              SizedBox(
                height: ResponsiveUtils.responsiveSpacing(
                  context,
                  32,
                ),
              ),

              _buildActionButtons(context),

              SizedBox(
                height: ResponsiveUtils.responsiveSpacing(
                  context,
                  32,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ===========================================================================
  // PROFILE HEADER
  // ===========================================================================

  Widget _buildProfileHeader(BuildContext context) {
    final user = authController.currentUser!;

    final String userName = user.name.trim().isEmpty
        ? 'Student'
        : user.name.trim();

    final String firstLetter = userName.isNotEmpty
        ? userName[0].toUpperCase()
        : 'S';

    // Get profile image provider from Base64 or legacy URL
    ImageProvider? profileImage = _getProfileImage(user.photoUrl);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        ResponsiveUtils.responsiveSpacing(
          context,
          24,
        ),
      ),
      decoration: BoxDecoration(
        gradient: theme.AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.responsiveBorderRadius(
            context,
            24,
          ),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _showProfileOptionsDialog,
            child: CircleAvatar(
              radius: ResponsiveUtils.responsiveSpacing(
                context,
                50,
              ),
              backgroundColor: Colors.white.withValues(
                alpha: 0.20,
              ),
              backgroundImage: profileImage,
              child: profileImage == null
                  ? Text(
                      firstLetter,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          32,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ),

          SizedBox(
            height: ResponsiveUtils.responsiveSpacing(
              context,
              16,
            ),
          ),

          Text(
            userName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(
                context,
                24,
              ),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          SizedBox(
            height: ResponsiveUtils.responsiveSpacing(
              context,
              8,
            ),
          ),

          Chip(
            label: Text(
              user.role.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            backgroundColor: Colors.white,
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PROFILE FIELD
  // ===========================================================================

  Widget _buildProfileField(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      ) {
    return Card(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.responsiveSpacing(
          context,
          12,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.responsiveSpacing(
            context,
            16,
          ),
          vertical: 4,
        ),
        leading: Container(
          padding: EdgeInsets.all(
            ResponsiveUtils.responsiveSpacing(
              context,
              12,
            ),
          ),
          decoration: BoxDecoration(
            color: theme.AppTheme.primaryColor.withValues(
              alpha: 0.10,
            ),
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.responsiveBorderRadius(
                context,
                12,
              ),
            ),
          ),
          child: Icon(
            icon,
            color: theme.AppTheme.primaryColor,
            size: ResponsiveUtils.responsiveIconSize(
              context,
              24,
            ),
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(
              context,
              12,
            ),
            color: theme.AppTheme.textSecondary,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(
              context,
              16,
            ),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // ACTION BUTTONS
  // ===========================================================================

  Widget _buildActionButtons(BuildContext context) {
    final double buttonHeight =
    ResponsiveUtils.responsiveButtonHeight(context);

    final double radius =
    ResponsiveUtils.responsiveBorderRadius(
      context,
      12,
    );

    return Column(
      children: [


        SizedBox(
          height: ResponsiveUtils.responsiveSpacing(
            context,
            12,
          ),
        ),

        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: OutlinedButton.icon(
            onPressed: () {
              Get.toNamed('/settings');
            },
            icon: const Icon(Icons.settings_outlined),
            label: const Text('Settings'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          ),
        ),

        SizedBox(
          height: ResponsiveUtils.responsiveSpacing(
            context,
            12,
          ),
        ),

        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: OutlinedButton.icon(
            onPressed: () {
              Get.toNamed('/help');
            },
            icon: const Icon(Icons.help_outline),
            label: const Text('Help & Support'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          ),
        ),

        SizedBox(
          height: ResponsiveUtils.responsiveSpacing(
            context,
            12,
          ),
        ),

        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: OutlinedButton.icon(
            onPressed: () {
              Get.toNamed('/about');
            },
            icon: const Icon(Icons.info_outline),
            label: const Text('About Us'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          ),
        ),

        SizedBox(
          height: ResponsiveUtils.responsiveSpacing(
            context,
            24,
          ),
        ),

        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton.icon(
            onPressed: () {
              _showLogoutConfirmation(context);
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.AppTheme.errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // CLASS NAME
  // ===========================================================================

  String _getClassName(String classId) {
    for (final cls in adminController.classes) {
      if (cls.id == classId) {
        return cls.name;
      }
    }

    return 'Unknown';
  }

  // ===========================================================================
  // SHIFT NAME
  // ===========================================================================

  String _getShiftName(String shiftId) {
    for (final shift in adminController.shifts) {
      if (shift.id == shiftId) {
        return shift.name;
      }
    }

    return 'Unknown';
  }

  // ===========================================================================
  // LOGOUT
  // ===========================================================================

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                authController.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.AppTheme.errorColor,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // PROFILE OPTIONS DIALOG
  // ===========================================================================

  void _showProfileOptionsDialog() {
    final user = authController.currentUser;
    final hasPhoto = user?.photoUrl != null && user!.photoUrl!.isNotEmpty;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Profile Photo'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: theme.AppTheme.primaryColor),
                title: const Text('Change Photo'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  Get.toNamed('/student/edit-profile');
                },
              ),
              if (hasPhoto)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete Photo'),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    _showDeletePhotoDialog();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // DELETE PROFILE PHOTO
  // ===========================================================================

  void _showDeletePhotoDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Profile Photo'),
          content: const Text(
            'Are you sure you want to delete your profile photo?',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteProfilePhoto();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProfilePhoto() async {
    try {
      final user = authController.currentUser;
      if (user != null && user.id != null) {
        // Update user document to remove photoUrl
        await _firestoreService.updateDocument(
          collectionPath: 'users',
          documentId: user.id!,
          data: {
            'photoUrl': '',
            'updatedAt': DateTime.now().toIso8601String(),
          },
        );

        // Refresh user data
        await authController.refreshUserData();

        if (mounted) {
          Get.snackbar(
            'Success',
            'Profile photo deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to delete profile photo: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: theme.AppTheme.errorColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  // ===========================================================================
  // EDIT PROFILE
  // ===========================================================================

  void _showEditProfileDialog() {
    final user = authController.currentUser!;

    final nameController = TextEditingController(
      text: user.name,
    );

    final phoneController = TextEditingController(
      text: user.phone ?? '',
    );

    final studentIdController = TextEditingController(
      text: user.studentId ?? '',
    );

    String? selectedClassId = user.classId;
    String? selectedShiftId = user.shiftId;

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
                  value: _validClassValue(selectedClassId),
                  decoration: const InputDecoration(
                    labelText: 'Class (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: adminController.classes.map((cls) {
                    return DropdownMenuItem<String>(
                      value: cls.id,
                      child: Text(
                        cls.name,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                  value: _validShiftValue(selectedShiftId),
                  decoration: const InputDecoration(
                    labelText: 'Shift (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: adminController.shifts.map((shift) {
                    return DropdownMenuItem<String>(
                      value: shift.id,
                      child: Text(
                        shift.name,
                        overflow: TextOverflow.ellipsis,
                      ),
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
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cancel'),
          ),

          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();

              if (name.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter your name',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: theme.AppTheme.errorColor,
                  colorText: Colors.white,
                );
                return;
              }

              final success =
              await adminController.updateUser(
                userId: user.id!,
                name: name,
                phone: phoneController.text.trim().isEmpty
                    ? null
                    : phoneController.text.trim(),
                studentId:
                studentIdController.text.trim().isEmpty
                    ? null
                    : studentIdController.text.trim(),
                classId: selectedClassId,
                shiftId: selectedShiftId,
              );

              if (success) {
                Get.back();

                Get.snackbar(
                  'Success',
                  'Profile updated successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor:
                  theme.AppTheme.successColor,
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

  String? _validClassValue(String? value) {
    if (value == null) {
      return null;
    }

    for (final cls in adminController.classes) {
      if (cls.id == value) {
        return value;
      }
    }

    return null;
  }

  String? _validShiftValue(String? value) {
    if (value == null) {
      return null;
    }

    for (final shift in adminController.shifts) {
      if (shift.id == value) {
        return value;
      }
    }

    return null;
  }

  ImageProvider? _getProfileImage(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) {
      return null;
    }

    // Check if it's a Base64 data URL
    if (photoUrl.startsWith('data:image')) {
      try {
        final base64String = photoUrl.split(',').last;
        final bytes = base64Decode(base64String);
        return MemoryImage(bytes);
      } catch (e) {
        print('DEBUG: Failed to decode Base64 image: $e');
        return null;
      }
    }

    // Legacy Firebase Storage URL
    try {
      return NetworkImage(photoUrl);
    } catch (e) {
      print('DEBUG: Failed to load network image: $e');
      return null;
    }
  }

  // ===========================================================================
  // NAVIGATION
  // ===========================================================================
}