import 'package:get/get.dart';
import '../models/shift_model.dart';
import '../services/firestore_service.dart';

class ShiftController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final RxList<ShiftModel> shifts = <ShiftModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchShifts();
  }

  Future<void> fetchShifts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final snapshot = await _firestoreService.getCollection(
        collectionPath: 'shifts',
      );

      shifts.value = snapshot.docs
          .map((doc) {
            return ShiftModel.fromJson(
              doc.data() as Map<String, dynamic>,
              id: doc.id,
            );
          })
          .where((shift) => shift.isActive)
          .toList();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createShift({
    required String name,
    String? description,
    String? startTime,
    String? endTime,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final shift = ShiftModel(
        name: name,
        description: description,
        startTime: startTime,
        endTime: endTime,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await _firestoreService.addDocument(
        collectionPath: 'shifts',
        data: shift.toJson(),
      );

      await fetchShifts();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateShift({
    required String shiftId,
    required String name,
    String? description,
    String? startTime,
    String? endTime,
    bool? isActive,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = <String, dynamic>{
        'name': name,
        if (description != null) 'description': description,
        if (startTime != null) 'startTime': startTime,
        if (endTime != null) 'endTime': endTime,
        if (isActive != null) 'isActive': isActive,
      };

      await _firestoreService.updateDocument(
        collectionPath: 'shifts',
        documentId: shiftId,
        data: data,
      );

      await fetchShifts();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteShift({required String shiftId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _firestoreService.updateDocument(
        collectionPath: 'shifts',
        documentId: shiftId,
        data: {'isActive': false},
      );

      await fetchShifts();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  ShiftModel? getShiftById(String shiftId) {
    try {
      return shifts.firstWhere((shift) => shift.id == shiftId);
    } catch (e) {
      return null;
    }
  }
}
