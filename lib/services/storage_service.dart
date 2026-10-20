import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile({
    required String path,
    required String fileName,
    required dynamic fileData,
  }) async {
    try {
      print('DEBUG: StorageService.uploadFile called');
      print('  - Path: $path');
      print('  - FileName: $fileName');
      
      final ref = _storage.ref().child('$path/$fileName');
      final uploadTask = ref.putData(fileData);
      
      print('DEBUG: Upload task started');
      final snapshot = await uploadTask;
      print('DEBUG: Upload completed successfully');
      
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('DEBUG: Download URL obtained: $downloadUrl');
      
      return downloadUrl;
    } catch (e) {
      print('DEBUG: Error in uploadFile: $e');
      print('DEBUG: Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  Future<String> uploadFileFromBytes({
    required String path,
    required String fileName,
    required Uint8List bytes,
  }) async {
    try {
      print('DEBUG: StorageService.uploadFileFromBytes called');
      print('  - Path: $path');
      print('  - FileName: $fileName');
      print('  - Bytes length: ${bytes.length} (${(bytes.length / 1024).toStringAsFixed(2)} KB)');
      
      // Check if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('DEBUG: ERROR - No authenticated user');
        throw Exception('User not authenticated. Please login again.');
      }
      print('DEBUG: User authenticated: ${user.email}');
      print('DEBUG: Firebase project ID: raintech-smart-test');
      print('DEBUG: Storage bucket: raintech-smart-test.firebasestorage.app');
      
      final ref = _storage.ref().child('$path/$fileName');
      print('DEBUG: Storage reference created: ${ref.fullPath}');
      
      final uploadTask = ref.putData(bytes);
      print('DEBUG: Upload task started');
      
      final snapshot = await uploadTask;
      print('DEBUG: Upload completed successfully');
      print('  - State: ${snapshot.state}');
      print('  - Bytes transferred: ${snapshot.bytesTransferred}');
      print('  - Total bytes: ${snapshot.totalBytes}');
      
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('DEBUG: Download URL obtained: $downloadUrl');
      
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('DEBUG: FirebaseException caught in uploadFileFromBytes');
      print('DEBUG: Error code: ${e.code}');
      print('DEBUG: Error message: ${e.message}');
      
      // Handle specific Firebase error codes
      switch (e.code) {
        case 'quota-exceeded':
          print('DEBUG: QUOTA EXCEEDED - Storage limit reached');
          throw Exception(
            'Storage quota exceeded. Your Firebase project is on the free Spark plan (5GB limit). '
            'Please upgrade to Blaze plan in Firebase Console to enable Cloud Storage. '
            'Alternatively, use a smaller image (max 2MB) or disable photo upload.',
          );
        case 'unauthorized':
          print('DEBUG: UNAUTHORIZED - Authentication or permission error');
          throw Exception(
            'Permission denied. You do not have permission to upload files. '
            'Ensure you are logged in and Firebase Storage security rules allow uploads.',
          );
        case 'object-not-found':
          print('DEBUG: OBJECT NOT FOUND - Storage bucket or path issue');
          throw Exception(
            'Storage configuration error. The storage bucket may not exist. '
            'Please ensure Cloud Storage is enabled in Firebase Console.',
          );
        case 'canceled':
          print('DEBUG: UPLOAD CANCELED');
          throw Exception('Upload was canceled.');
        case 'unknown':
          print('DEBUG: UNKNOWN ERROR');
          throw Exception(
            'Firebase error: ${e.message}. '
            'Check Firebase Console for more details.',
          );
        default:
          print('DEBUG: OTHER ERROR CODE: ${e.code}');
          throw Exception(
            'Firebase error (${e.code}): ${e.message}',
          );
      }
    } catch (e) {
      print('DEBUG: Non-FirebaseException error in uploadFileFromBytes: $e');
      print('DEBUG: Error type: ${e.runtimeType}');
      
      // Handle non-Firebase exceptions
      if (e.toString().contains('network') || e.toString().contains('connection')) {
        print('DEBUG: Network error detected');
        throw Exception('Network error. Please check your internet connection.');
      }
      
      rethrow;
    }
  }

  Future<void> deleteFile({required String fileUrl}) async {
    try {
      print('DEBUG: StorageService.deleteFile called');
      print('  - File URL: $fileUrl');
      
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      
      print('DEBUG: File deleted successfully');
    } catch (e) {
      print('DEBUG: Error in deleteFile: $e');
      // Don't rethrow - deletion failure should not block the main operation
      print('DEBUG: Ignoring delete error');
    }
  }

  Future<String?> getDownloadURL({required String path}) async {
    try {
      print('DEBUG: StorageService.getDownloadURL called');
      print('  - Path: $path');
      
      final ref = _storage.ref(path);
      final url = await ref.getDownloadURL();
      
      print('DEBUG: Download URL obtained: $url');
      return url;
    } catch (e) {
      print('DEBUG: Error in getDownloadURL: $e');
      return null;
    }
  }
}
