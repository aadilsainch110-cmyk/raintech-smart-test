import 'package:cloud_firestore/cloud_firestore.dart';

// ignore_for_file: avoid_print

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get coursesCollection => _firestore.collection('courses');
  CollectionReference get classesCollection => _firestore.collection('classes');
  CollectionReference get shiftsCollection => _firestore.collection('shifts');
  CollectionReference get enrollmentsCollection =>
      _firestore.collection('enrollments');
  CollectionReference get testsCollection => _firestore.collection('tests');
  CollectionReference get questionsCollection =>
      _firestore.collection('questions');
  CollectionReference get questionBankCollection =>
      _firestore.collection('questionBank');
  CollectionReference get attemptsCollection =>
      _firestore.collection('attempts');
  CollectionReference get resultsCollection => _firestore.collection('results');

  Future<DocumentSnapshot> getDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    try {
      return await _firestore.collection(collectionPath).doc(documentId).get();
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot> getCollection({required String collectionPath}) async {
    try {
      return await _firestore.collection(collectionPath).get();
    } catch (e) {
      rethrow;
    }
  }

  Future<DocumentReference> addDocument({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    print('DEBUG: FirestoreService.addDocument called');
    print('DEBUG: Collection: $collectionPath');
    print('DEBUG: Data: $data');
    try {
      final result = await _firestore.collection(collectionPath).add(data);
      print('DEBUG: Document added successfully, ID: ${result.id}');
      return result;
    } catch (e) {
      print('DEBUG: Error in addDocument: $e');
      rethrow;
    }
  }

  Future<void> setDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).set(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDocumentsByQuery({
    required String collectionPath,
    required String field,
    required dynamic value,
  }) async {
    print(
      'DEBUG: deleteDocumentsByQuery called for collection: $collectionPath, field: $field, value: $value',
    );
    try {
      final query = _firestore
          .collection(collectionPath)
          .where(field, isEqualTo: value);
      final snapshot = await query.get();
      print('DEBUG: Found ${snapshot.docs.length} documents to delete');

      // Use batch delete for efficiency
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      print('DEBUG: Batch delete completed');
    } catch (e) {
      print('DEBUG: Error in deleteDocumentsByQuery: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> streamCollection({
    required String collectionPath,
    Query? query,
  }) {
    if (query != null) {
      return query.snapshots();
    }
    return _firestore.collection(collectionPath).snapshots();
  }

  Stream<DocumentSnapshot> streamDocument({
    required String collectionPath,
    required String documentId,
  }) {
    return _firestore.collection(collectionPath).doc(documentId).snapshots();
  }

  Query queryWhereEqualTo({
    required String collectionPath,
    required String field,
    required dynamic value,
  }) {
    return _firestore.collection(collectionPath).where(field, isEqualTo: value);
  }

  Query queryWhereArrayContains({
    required String collectionPath,
    required String field,
    required dynamic value,
  }) {
    return _firestore
        .collection(collectionPath)
        .where(field, arrayContains: value);
  }

  Future<void> runTransaction(TransactionHandler transactionHandler) async {
    try {
      await _firestore.runTransaction(transactionHandler);
    } catch (e) {
      rethrow;
    }
  }
}
