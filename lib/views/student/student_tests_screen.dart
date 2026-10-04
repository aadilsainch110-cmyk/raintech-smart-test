import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/test_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart' as theme;
import '../../app/responsive/responsive_utils.dart';

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
      appBar: AppBar(
        title: const Text('Available Tests'),
      ),
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
                    size: ResponsiveUtils.responsiveIconSize(context, 80),
                    color: theme.AppTheme.textSecondary,
                  ),
                  SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
                  Text(
                    'No tests available',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
                      color: theme.AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: ResponsiveUtils.responsivePadding(context),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveUtils.getGridColumns(context),
              childAspectRatio: ResponsiveUtils.isMobile(context) ? 1.1 : 1.3,
              crossAxisSpacing: ResponsiveUtils.responsiveSpacing(context, 16),
              mainAxisSpacing: ResponsiveUtils.responsiveSpacing(context, 16),
            ),
            itemCount: controller.tests.length,
            itemBuilder: (context, index) {
              final test = controller.tests[index];
              return Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.responsiveBorderRadius(context, 16),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(
                    ResponsiveUtils.responsiveSpacing(context, 20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                          Container(
                            padding: EdgeInsets.all(
                              ResponsiveUtils.responsiveSpacing(context, 12),
                            ),
                            decoration: BoxDecoration(
                              gradient: theme.AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(
                                ResponsiveUtils.responsiveBorderRadius(context, 12),
                              ),
                            ),
                            child: Icon(
                              Icons.quiz,
                              color: Colors.white,
                              size: ResponsiveUtils.responsiveIconSize(context, 32),
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
                          Text(
                            test.title,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (test.description != null) ...[
                            SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 8)),
                            Text(
                              test.description!,
                              style: TextStyle(
                                fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                                color: theme.AppTheme.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const Spacer(),
                          SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 12)),
                          Wrap(
                            spacing: ResponsiveUtils.responsiveSpacing(context, 8),
                            runSpacing: ResponsiveUtils.responsiveSpacing(context, 8),
                            children: [
                              _buildInfoChip(
                                Icons.help_outline,
                                '${test.questionCount} Questions',
                              ),
                              _buildInfoChip(
                                Icons.access_time,
                                '${test.durationMinutes} min',
                              ),
                              _buildInfoChip(
                                Icons.star_outline,
                                '${test.totalMarks} Marks',
                              ),
                            ],
                          ),
                          SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
                          SizedBox(
                            width: double.infinity,
                            height: ResponsiveUtils.responsiveButtonHeight(context),
                            child: ElevatedButton(
                              onPressed: () {
                                Get.toNamed(Routes.TEST_SCREEN, arguments: test);
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveUtils.responsiveBorderRadius(context, 12),
                                  ),
                                ),
                              ),
                              child: Text(
                                'Start Test',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                                ),
                              ),
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
    return Builder(
      builder: (context) => Chip(
        avatar: Icon(
          icon,
          size: ResponsiveUtils.responsiveIconSize(context, 16),
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, 12),
          ),
        ),
      ),
    );
  }
}
