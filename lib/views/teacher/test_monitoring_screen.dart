import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/result_controller.dart';
import '../../controllers/student_controller.dart';
import '../../controllers/attempt_controller.dart';
import '../../controllers/test_controller.dart';
import '../../models/test_model.dart';
import '../../app/theme/app_theme.dart';

class TestMonitoringScreen extends StatefulWidget {
  const TestMonitoringScreen({super.key});

  @override
  State<TestMonitoringScreen> createState() => _TestMonitoringScreenState();
}

class _TestMonitoringScreenState extends State<TestMonitoringScreen> {
  final ResultController _resultController = Get.put(ResultController());
  final StudentController _studentController = Get.put(StudentController());
  final AttemptController _attemptController = Get.put(AttemptController());
  final TestController _testController = Get.put(TestController());

  TestModel? _test;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _test = Get.arguments as TestModel?;
    if (_test != null) {
      await Future.wait([
        _resultController.fetchTestResults(testId: _test!.id!),
        _studentController.fetchAllStudents(),
        _attemptController.fetchAttemptsByTest(testId: _test!.id!),
      ]);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_test?.title ?? 'Test Monitoring'),
        actions: [
          if (_test?.status == 'published')
            IconButton(
              icon: const Icon(Icons.publish),
              onPressed: _releaseResults,
              tooltip: 'Release Results',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _test == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTestInfo(),
                    const SizedBox(height: 24),
                    _buildStats(),
                    const SizedBox(height: 24),
                    _buildSubmissionsList(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTestInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _test!.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Duration: ${_test!.durationMinutes} minutes'),
            Text('Total Marks: ${_test!.totalMarks}'),
            Text('Passing Marks: ${_test!.passingMarks}'),
            const SizedBox(height: 8),
            Chip(
              label: Text(_test!.status.toUpperCase()),
              backgroundColor: _getStatusColor(_test!.status),
              labelStyle: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    final totalStudents = _studentController.students.length;
    final submittedCount = _resultController.results.length;
    final pendingCount = totalStudents - submittedCount;
    final inProgressCount = _attemptController.attempts.length - submittedCount;
    final statistics = _attemptController.getTestStatistics(testId: _test!.id!);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Students',
                totalStudents.toString(),
                Icons.people,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Submitted',
                submittedCount.toString(),
                Icons.check_circle,
                AppTheme.successColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Pending',
                pendingCount.toString(),
                Icons.pending,
                AppTheme.warningColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'In Progress',
                inProgressCount.toString(),
                Icons.sync,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Avg Time',
                '${(statistics['averageTimeTaken'] / 60).toStringAsFixed(1)} min',
                Icons.timer,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Completion Rate',
                '${((submittedCount / (totalStudents > 0 ? totalStudents : 1)) * 100).toStringAsFixed(0)}%',
                Icons.pie_chart,
                Colors.teal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon, [
    Color? color,
  ]) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color ?? AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionsList() {
    final hasResults = _resultController.results.isNotEmpty;
    final hasAttempts = _attemptController.attempts.isNotEmpty;

    if (!hasResults && !hasAttempts) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.hourglass_empty,
                  size: 64,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No submissions yet',
                  style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Student Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Show in-progress attempts first
        if (hasAttempts) ...[
          const Text(
            'In Progress',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _attemptController.attempts.length,
            itemBuilder: (context, index) {
              final attempt = _attemptController.attempts[index];
              // Skip if this attempt has a result (already submitted)
              if (_resultController.results.any(
                (r) => r.studentId == attempt.studentId,
              )) {
                return const SizedBox.shrink();
              }

              final student = _studentController.students
                  .where((s) => s.id == attempt.studentId)
                  .firstOrNull;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.orange.withValues(alpha: 0.1),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(student?.name[0].toUpperCase() ?? '?'),
                  ),
                  title: Text(student?.name ?? 'Unknown Student'),
                  subtitle: Text(
                    'Started: ${attempt.startedAt != null ? _formatDateTime(attempt.startedAt!) : 'N/A'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (attempt.timeTakenSeconds != null)
                        Text(
                          '${(attempt.timeTakenSeconds! / 60).toStringAsFixed(1)} min',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(width: 8),
                      const Chip(
                        label: Text('IN PROGRESS'),
                        backgroundColor: Colors.orange,
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],

        // Show completed submissions
        if (hasResults) ...[
          const Text(
            'Completed',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _resultController.results.length,
            itemBuilder: (context, index) {
              final result = _resultController.results[index];
              final student = _studentController.students
                  .where((s) => s.id == result.studentId)
                  .firstOrNull;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(student?.name[0].toUpperCase() ?? '?'),
                  ),
                  title: Text(student?.name ?? 'Unknown Student'),
                  subtitle: Text(
                    'Marks: ${result.obtainedMarks}/${result.totalMarks}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${result.percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(result.status),
                        backgroundColor: result.status == 'PASS'
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _releaseResults() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Release Results'),
        content: const Text(
          'This will calculate rankings and make results visible to students. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Release'),
          ),
        ],
      ),
    );

    if (confirmed == true && _test != null) {
      final success = await _testController.releaseResults(testId: _test!.id!);
      if (success) {
        Get.snackbar(
          'Success',
          'Results released successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.successColor,
          colorText: Colors.white,
        );
        await _loadData();
      } else {
        Get.snackbar(
          'Error',
          'Failed to release results',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.errorColor,
          colorText: Colors.white,
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'published':
        return AppTheme.successColor;
      case 'draft':
        return AppTheme.warningColor;
      case 'closed':
        return AppTheme.errorColor;
      case 'results_released':
        return AppTheme.primaryColor;
      default:
        return Colors.grey;
    }
  }
}
