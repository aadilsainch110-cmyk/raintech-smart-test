import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../app/theme/app_theme.dart';
import '../../models/shift_model.dart';

class ShiftsManagementScreen extends StatefulWidget {
  const ShiftsManagementScreen({super.key});

  @override
  State<ShiftsManagementScreen> createState() => _ShiftsManagementScreenState();
}

class _ShiftsManagementScreenState extends State<ShiftsManagementScreen> {
  final AdminController _adminController = Get.put(AdminController());

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _adminController.fetchAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Shifts Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddShiftDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Obx(
          () => _adminController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : _adminController.shifts.isEmpty
              ? _buildEmptyState()
              : _buildShiftsList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time, size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          const Text(
            'No shifts yet',
            style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddShiftDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add First Shift'),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _adminController.shifts.length,
      itemBuilder: (context, index) {
        final shift = _adminController.shifts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              shift.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: shift.startTime != null && shift.endTime != null
                ? Text('${shift.startTime} - ${shift.endTime}')
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditShiftDialog(shift),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: AppTheme.errorColor,
                  onPressed: () => _showDeleteDialog(shift),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddShiftDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final startTimeController = TextEditingController();
    final endTimeController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Shift'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Shift Name (e.g., Morning, Evening)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: startTimeController,
              decoration: const InputDecoration(
                labelText: 'Start Time (e.g., 9:00 AM)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: endTimeController,
              decoration: const InputDecoration(
                labelText: 'End Time (e.g., 12:00 PM)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter shift name',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.errorColor,
                  colorText: Colors.white,
                );
                return;
              }
              final success = await _adminController.createShift(
                name: nameController.text,
                description: descriptionController.text.isEmpty
                    ? null
                    : descriptionController.text,
                startTime: startTimeController.text.isEmpty
                    ? null
                    : startTimeController.text,
                endTime: endTimeController.text.isEmpty
                    ? null
                    : endTimeController.text,
              );
              if (success) {
                Get.back();
                Get.snackbar(
                  'Success',
                  'Shift created successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.successColor,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditShiftDialog(ShiftModel shift) {
    final nameController = TextEditingController(text: shift.name);
    final descriptionController = TextEditingController(
      text: shift.description ?? '',
    );
    final startTimeController = TextEditingController(
      text: shift.startTime ?? '',
    );
    final endTimeController = TextEditingController(text: shift.endTime ?? '');

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Shift'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Shift Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: startTimeController,
              decoration: const InputDecoration(
                labelText: 'Start Time',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: endTimeController,
              decoration: const InputDecoration(
                labelText: 'End Time',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter shift name',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.errorColor,
                  colorText: Colors.white,
                );
                return;
              }
              final success = await _adminController.updateShift(
                shiftId: shift.id!,
                name: nameController.text,
                description: descriptionController.text.isEmpty
                    ? null
                    : descriptionController.text,
                startTime: startTimeController.text.isEmpty
                    ? null
                    : startTimeController.text,
                endTime: endTimeController.text.isEmpty
                    ? null
                    : endTimeController.text,
              );
              if (success) {
                Get.back();
                Get.snackbar(
                  'Success',
                  'Shift updated successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.successColor,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(ShiftModel shift) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Shift'),
        content: Text('Are you sure you want to delete "${shift.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final success = await _adminController.deleteShift(
                shiftId: shift.id!,
              );
              if (success) {
                Get.back();
                Get.snackbar(
                  'Success',
                  'Shift deleted successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.successColor,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
