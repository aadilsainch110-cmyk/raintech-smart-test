import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile({
    required String path,
    required String fileName,
    required dynamic fileData,
  }) async {
    try {
      final ref = _storage.ref().child('$path/$fileName');
      final uploadTask = ref.putData(fileData);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadFileFromBytes({
    required String path,
    required String fileName,
    required Uint8List bytes,
  }) async {
    try {
      final ref = _storage.ref().child('$path/$fileName');
      final uploadTask = ref.putData(bytes);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFile({required String fileUrl}) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getDownloadURL({required String path}) async {
    try {
      final ref = _storage.ref(path);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}
