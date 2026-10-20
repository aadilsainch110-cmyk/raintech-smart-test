import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../../controllers/auth_controller.dart';
import '../../services/firestore_service.dart';
import '../../app/theme/app_theme.dart' as theme;
import '../../app/responsive/responsive_utils.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final FirestoreService _firestoreService = FirestoreService();
  final ImagePicker _imagePicker = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String? _photoBase64; // Store Base64 string instead of URL
  dynamic _pickedImage; // Can be File (mobile) or XFile (web)
  Uint8List? _pickedImageBytes; // For web display
  bool _isProcessing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final user = _authController.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address ?? '';
      // Check if photoUrl contains Base64 or a Firebase Storage URL
      if (user.photoUrl != null && user.photoUrl!.startsWith('data:image')) {
        _photoBase64 = user.photoUrl;
      } else if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
        // Legacy Firebase Storage URL - we'll still display it but won't upload new ones
        _photoBase64 = user.photoUrl;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      print('DEBUG: _pickImage called');
      print('DEBUG: Platform: ${kIsWeb ? "Web" : "Mobile/Desktop"}');
      
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 70,
      );

      print('DEBUG: Image picker result: ${image != null ? "Image selected" : "No image selected"}');
      
      if (image != null && mounted) {
        print('DEBUG: Image path: ${image.path}');
        print('DEBUG: Image name: ${image.name}');
        final imageSize = await image.length();
        print('DEBUG: Image size: $imageSize bytes (${(imageSize / 1024).toStringAsFixed(2)} KB)');
        
        // Validate image size (max 500KB before compression)
        if (imageSize > 500 * 1024) {
          print('DEBUG: Image too large: ${(imageSize / 1024).toStringAsFixed(2)} KB');
          Get.snackbar(
            'Error',
            'Image too large. Please select an image under 500KB.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: theme.AppTheme.errorColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          return;
        }
        
        // On mobile/desktop, convert to File
        // On web, keep as XFile and also store bytes for display
        if (!kIsWeb) {
          setState(() {
            _pickedImage = File(image.path);
          });
        } else {
          final bytes = await image.readAsBytes();
          setState(() {
            _pickedImage = image;
            _pickedImageBytes = bytes;
          });
        }
      }
    } catch (e) {
      print('DEBUG: Error in _pickImage: $e');
      print('DEBUG: Error type: ${e.runtimeType}');
      
      String errorMessage = 'Failed to pick image';
      if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied. Please grant storage permission in settings.';
      } else if (e.toString().contains('cancelled')) {
        errorMessage = 'Image selection cancelled';
      }
      
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }

  Future<String?> _compressAndEncodeImage() async {
    if (_pickedImage == null) return null;

    setState(() {
      _isProcessing = true;
    });

    try {
      print('DEBUG: _compressAndEncodeImage called');
      
      Uint8List bytes;
      if (kIsWeb) {
        bytes = await (_pickedImage as XFile).readAsBytes();
      } else {
        bytes = await (_pickedImage as File).readAsBytes();
      }
      
      print('DEBUG: Original image size: ${bytes.length} bytes (${(bytes.length / 1024).toStringAsFixed(2)} KB)');
      
      // Decode image
      img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }
      
      print('DEBUG: Original dimensions: ${image.width}x${image.height}');
      
      // Resize if needed (max 300x300 to keep Base64 small)
      if (image.width > 300 || image.height > 300) {
        image = img.copyResize(
          image,
          width: image.width > 300 ? 300 : null,
          height: image.height > 300 ? 300 : null,
          maintainAspect: true,
        );
        print('DEBUG: Resized to: ${image.width}x${image.height}');
      }
      
      // Compress to JPEG with quality 60
      final compressedBytes = img.encodeJpg(image, quality: 60);
      print('DEBUG: Compressed size: ${compressedBytes.length} bytes (${(compressedBytes.length / 1024).toStringAsFixed(2)} KB)');
      
      // Validate compressed size (max 100KB to stay well under 1MB Firestore limit)
      if (compressedBytes.length > 100 * 1024) {
        throw Exception('Compressed image too large (${(compressedBytes.length / 1024).toStringAsFixed(2)} KB). Please select a smaller image.');
      }
      
      // Encode to Base64
      final base64String = base64Encode(compressedBytes);
      final dataUrl = 'data:image/jpeg;base64,$base64String';
      
      print('DEBUG: Base64 string length: ${dataUrl.length} characters');
      print('DEBUG: Base64 size: ${(dataUrl.length / 1024).toStringAsFixed(2)} KB');
      
      // Update state with bytes for display
      if (mounted) {
        setState(() {
          _pickedImageBytes = compressedBytes;
          _isProcessing = false;
        });
      }
      
      return dataUrl;
    } catch (e) {
      print('DEBUG: Error in _compressAndEncodeImage: $e');
      print('DEBUG: Error type: ${e.runtimeType}');
      
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
      
      Get.snackbar(
        'Error',
        'Failed to process image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.AppTheme.errorColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      return null;
    }
  }



  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (mounted) {
      setState(() {
        _isSaving = true;
      });
    }

    try {
      print('DEBUG: _saveProfile called');
      
      final user = _authController.currentUser;
      if (user == null) {
        print('DEBUG: ERROR - No current user');
        throw Exception('No user logged in');
      }
      print('DEBUG: User ID: ${user.id}');

      // Process photo if a new one was selected
      String? newPhotoBase64 = _photoBase64;
      if (_pickedImage != null) {
        print('DEBUG: New photo selected, compressing and encoding...');
        newPhotoBase64 = await _compressAndEncodeImage();
        
        if (newPhotoBase64 == null || newPhotoBase64.isEmpty) {
          print('DEBUG: Image processing failed');
          // Don't throw exception - just don't update the photo
          // Allow other fields to be saved even if photo processing fails
          newPhotoBase64 = _photoBase64; // Keep old photo
        } else {
          print('DEBUG: Image processed successfully');
        }
      }

      // Prepare update data - only allow editing safe fields
      final updateData = <String, dynamic>{
        'name': _nameController.text.trim(),
        if (_phoneController.text.trim().isNotEmpty)
          'phone': _phoneController.text.trim()
        else if (user.phone != null)
          'phone': null, // Remove phone if it was set before
        if (_addressController.text.trim().isNotEmpty)
          'address': _addressController.text.trim()
        else if (user.address != null)
          'address': null, // Remove address if it was set before
        if (newPhotoBase64 != null && newPhotoBase64.isNotEmpty) 'photoUrl': newPhotoBase64,
      };

      print('DEBUG: Updating Firestore with data (excluding photoUrl from log for size)');

      // Update in Firestore
      await _firestoreService.updateDocument(
        collectionPath: 'users',
        documentId: user.id!,
        data: updateData,
      );

      print('DEBUG: Firestore update successful');

      // Refresh user data in AuthController
      await _authController.refreshUserData();

      print('DEBUG: User data refreshed');

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.AppTheme.successColor,
        colorText: Colors.white,
      );

      Get.back();
    } catch (e) {
      print('DEBUG: Error in _saveProfile: $e');
      print('DEBUG: Error type: ${e.runtimeType}');
      
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.AppTheme.errorColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authController.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Edit Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: ResponsiveUtils.responsivePadding(context),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfilePhotoSection(context),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 24)),
              _buildFormField(
                context,
                'Full Name',
                _nameController,
                Icons.person_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
              _buildFormField(
                context,
                'Phone Number',
                _phoneController,
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (value.trim().length < 10) {
                      return 'Please enter a valid phone number';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
              _buildFormField(
                context,
                'Address',
                _addressController,
                Icons.location_on_outlined,
                maxLines: 3,
                validator: null,
              ),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 32)),
              _buildProtectedFieldsInfo(context, user),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 32)),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePhotoSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              InkWell(
                onTap: (_isProcessing || _isSaving) ? null : _showProfileOptionsDialog,
                child: CircleAvatar(
                  radius: ResponsiveUtils.responsiveSpacing(context, 60),
                  backgroundColor: theme.AppTheme.primaryColor.withValues(alpha: 0.1),
                  backgroundImage: _getProfileImage(),
                  child: _pickedImage == null &&
                      _pickedImageBytes == null &&
                      (_photoBase64 == null || _photoBase64!.isEmpty)
                      ? Icon(
                    Icons.person,
                    size: ResponsiveUtils.responsiveIconSize(context, 60),
                    color: theme.AppTheme.primaryColor,
                  )
                      : null,
                ),
              ),
              if (_isProcessing || _isSaving)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 12)),
          Text(
            'Tap camera icon to change photo (max 500KB)',
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 12),
              color: theme.AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(
      BuildContext context,
      String label,
      TextEditingController controller,
      IconData icon, {
        TextInputType? keyboardType,
        int maxLines = 1,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.responsiveBorderRadius(context, 12),
          ),
        ),
        filled: true,
        fillColor: Colors.grey.withValues(alpha: 0.05),
      ),
      validator: validator,
    );
  }

  Widget _buildProtectedFieldsInfo(BuildContext context, user) {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtils.responsiveSpacing(context, 16),
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.responsiveBorderRadius(context, 12),
        ),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.orange,
                size: ResponsiveUtils.responsiveIconSize(context, 20),
              ),
              SizedBox(width: ResponsiveUtils.responsiveSpacing(context, 8)),
              Text(
                'Protected Information',
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 12)),
          _buildProtectedField(context, 'Student ID', user?.studentId),
          _buildProtectedField(context, 'Class', user?.classId != null ? _getClassDisplay(user!.classId!) : null),
          _buildProtectedField(context, 'Shift', user?.shiftId != null ? _getShiftDisplay(user!.shiftId!) : null),
          _buildProtectedField(context, 'Role', user?.role),
          _buildProtectedField(context, 'Status', user?.approvalStatus),
          SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 8)),
          Text(
            'These fields cannot be changed. Contact Admin for modifications.',
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 11),
              color: Colors.orange.withValues(alpha: 0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtectedField(BuildContext context, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(
        bottom: ResponsiveUtils.responsiveSpacing(context, 8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: ResponsiveUtils.responsiveSpacing(context, 100),
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 12),
                color: theme.AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 12),
                fontWeight: FontWeight.w500,
                color: theme.AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getClassDisplay(String classId) {
    // For now, return the ID. In production, fetch class name from controller
    return classId;
  }

  String _getShiftDisplay(String shiftId) {
    // For now, return the ID. In production, fetch shift name from controller
    return shiftId;
  }

  ImageProvider? _getProfileImage() {
    // First check if we have a newly picked image
    if (_pickedImageBytes != null) {
      return MemoryImage(_pickedImageBytes!);
    }

    if (_pickedImage != null && !kIsWeb && _pickedImage is File) {
      return FileImage(_pickedImage as File);
    }

    // Check if we have a Base64 string (new format)
    if (_photoBase64 != null && _photoBase64!.isNotEmpty) {
      if (_photoBase64!.startsWith('data:image')) {
        // It's a Base64 data URL
        try {
          final base64String = _photoBase64!.split(',').last;
          final bytes = base64Decode(base64String);
          return MemoryImage(bytes);
        } catch (e) {
          print('DEBUG: Failed to decode Base64 image: $e');
        }
      } else {
        // It's a legacy Firebase Storage URL
        return NetworkImage(_photoBase64!);
      }
    }

    return null;
  }

  void _showProfileOptionsDialog() {
    final hasPhoto = _photoBase64 != null && _photoBase64!.isNotEmpty;

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
                  _pickImage();
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
      final user = _authController.currentUser;
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
        await _authController.refreshUserData();

        // Clear local state
        setState(() {
          _photoBase64 = null;
          _pickedImage = null;
          _pickedImageBytes = null;
        });

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
      print('DEBUG: Error deleting profile photo: $e');
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

  Widget _buildActionButtons(BuildContext context) {
    final double buttonHeight = ResponsiveUtils.responsiveButtonHeight(context);
    final double radius = ResponsiveUtils.responsiveBorderRadius(context, 12);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: buttonHeight,
                child: OutlinedButton(
                  onPressed: _isSaving ? null : () => Get.back(),
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
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text('Save Changes',style: TextStyle(color: Colors.white),),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _showDeleteAccountDialog,
            icon: const Icon(Icons.delete_forever),
            label: const Text('Delete Account'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone. All your data including profile, enrollments, test attempts, and results will be permanently deleted.',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteAccount();
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

  Future<void> _deleteAccount() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Text(
          'This is your last chance! Are you absolutely sure you want to delete your account? This action is permanent and cannot be undone.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Delete My Account'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isSaving = true;
      });

      try {
        final user = _authController.currentUser;
        if (user != null) {
          // Delete user document from Firestore
          await _firestoreService.deleteDocument(
            collectionPath: 'users',
            documentId: user.id!,
          );

          // Delete user's enrollments
          final enrollmentsQuery = _firestoreService.queryWhereEqualTo(
            collectionPath: 'enrollments',
            field: 'studentId',
            value: user.id!,
          );
          final enrollmentsSnapshot = await enrollmentsQuery.get();
          for (final doc in enrollmentsSnapshot.docs) {
            await _firestoreService.deleteDocument(
              collectionPath: 'enrollments',
              documentId: doc.id,
            );
          }

          // Delete user's test attempts
          final attemptsQuery = _firestoreService.queryWhereEqualTo(
            collectionPath: 'attempts',
            field: 'studentId',
            value: user.id!,
          );
          final attemptsSnapshot = await attemptsQuery.get();
          for (final doc in attemptsSnapshot.docs) {
            await _firestoreService.deleteDocument(
              collectionPath: 'attempts',
              documentId: doc.id,
            );
          }

          // Delete user's results
          final resultsQuery = _firestoreService.queryWhereEqualTo(
            collectionPath: 'results',
            field: 'studentId',
            value: user.id!,
          );
          final resultsSnapshot = await resultsQuery.get();
          for (final doc in resultsSnapshot.docs) {
            await _firestoreService.deleteDocument(
              collectionPath: 'results',
              documentId: doc.id,
            );
          }

          // Sign out from Firebase Auth
          await _authController.signOut();

          if (mounted) {
            Get.snackbar(
              'Account Deleted',
              'Your account has been permanently deleted.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
            Get.offAllNamed('/login');
          }
        }
      } catch (e) {
        print('DEBUG: Error deleting account: $e');
        if (mounted) {
          Get.snackbar(
            'Error',
            'Failed to delete account: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: theme.AppTheme.errorColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }
}
