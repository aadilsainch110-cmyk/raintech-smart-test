import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/test_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart' as theme;

class StudentTestsScreen extends StatefulWidget {
  const StudentTestsScreen({super.key});

  @override
  State<StudentTestsScreen> createState() => _StudentTestsScreenState();
}

class _StudentTestsScreenState extends State<StudentTestsScreen> {
  final TestController _testController = Get.put(TestController());

  @override
  void initState() {
    super.initState();
    _testController.fetchPublishedTests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Tests')),
      body: GetX<TestController>(
        init: _testController,
        builder: (controller) {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.tests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    size: 80,
                    color: theme.AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No tests available',
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.tests.length,
            itemBuilder: (context, index) {
              final test = controller.tests[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        test.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (test.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          test.description!,
                          style: const TextStyle(
                            color: theme.AppTheme.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildInfoChip(
                              Icons.help_outline,
                              '${test.questionCount} Questions',
                            ),
                            const SizedBox(width: 8),
                            _buildInfoChip(
                              Icons.access_time,
                              '${test.durationMinutes} min',
                            ),
                            const SizedBox(width: 8),
                            _buildInfoChip(
                              Icons.star_outline,
                              '${test.totalMarks} Marks',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.toNamed(Routes.TEST_SCREEN, arguments: test);
                          },
                          child: const Text('Start Test'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 12),
    );
  }
}
