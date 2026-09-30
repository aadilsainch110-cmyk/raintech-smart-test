import '../models/course_model.dart';
import '../models/class_model.dart';
import '../models/shift_model.dart';
import 'firestore_service.dart';

class DataInitService {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> initializeDefaultData() async {
    await _initializeCourses();
    await _initializeClasses();
    await _initializeShifts();
  }

  Future<void> _initializeCourses() async {
    final courses = [
      CourseModel(
        name: 'CIT',
        description: 'Certificate in Information Technology',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      CourseModel(
        name: 'AI',
        description: 'Artificial Intelligence',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      CourseModel(
        name: 'App Development',
        description: 'Mobile Application Development',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      CourseModel(
        name: 'Python',
        description: 'Python Programming',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      CourseModel(
        name: 'Agentic AI',
        description: 'Agentic Artificial Intelligence',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      CourseModel(
        name: 'Graphic Designing',
        description: 'Graphic Design and Multimedia',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      CourseModel(
        name: 'Web Development',
        description: 'Web Development and Design',
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];

    final snapshot = await _firestoreService.getCollection(
      collectionPath: 'courses',
    );

    final existingCourses = snapshot.docs.map((doc) {
      return CourseModel.fromJson(
        doc.data() as Map<String, dynamic>,
        id: doc.id,
      );
    }).toList();

    for (final course in courses) {
      final exists = existingCourses.any(
        (c) => c.name.toLowerCase() == course.name.toLowerCase(),
      );
      if (!exists) {
        await _firestoreService.addDocument(
          collectionPath: 'courses',
          data: course.toJson(),
        );
      }
    }
  }

  Future<void> _initializeClasses() async {
    final classes = [
      ClassModel(name: '9th', description: '9th Class', isActive: true),
      ClassModel(name: '10th', description: '10th Class', isActive: true),
      ClassModel(name: '11th', description: '11th Class', isActive: true),
      ClassModel(name: '12th', description: '12th Class', isActive: true),
    ];

    final snapshot = await _firestoreService.getCollection(
      collectionPath: 'classes',
    );

    final existingClasses = snapshot.docs.map((doc) {
      return ClassModel.fromJson(
        doc.data() as Map<String, dynamic>,
        id: doc.id,
      );
    }).toList();

    for (final classModel in classes) {
      final exists = existingClasses.any(
        (c) => c.name.toLowerCase() == classModel.name.toLowerCase(),
      );
      if (!exists) {
        await _firestoreService.addDocument(
          collectionPath: 'classes',
          data: classModel.toJson(),
        );
      }
    }
  }

  Future<void> _initializeShifts() async {
    final shifts = [
      ShiftModel(name: 'Morning', description: 'Morning Shift', isActive: true),
      ShiftModel(name: 'Evening', description: 'Evening Shift', isActive: true),
    ];

    final snapshot = await _firestoreService.getCollection(
      collectionPath: 'shifts',
    );

    final existingShifts = snapshot.docs.map((doc) {
      return ShiftModel.fromJson(
        doc.data() as Map<String, dynamic>,
        id: doc.id,
      );
    }).toList();

    for (final shift in shifts) {
      final exists = existingShifts.any(
        (s) => s.name.toLowerCase() == shift.name.toLowerCase(),
      );
      if (!exists) {
        await _firestoreService.addDocument(
          collectionPath: 'shifts',
          data: shift.toJson(),
        );
      }
    }
  }
}
