import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/result_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../services/pdf_service.dart';
import '../../app/theme/app_theme.dart' as theme;
import '../../app/responsive/responsive_utils.dart';

class StudentResultsScreen extends StatefulWidget {
  const StudentResultsScreen({super.key});

  @override
  State<StudentResultsScreen> createState() => _StudentResultsScreenState();
}

class _StudentResultsScreenState extends State<StudentResultsScreen> {
  final ResultController _resultController = Get.put(ResultController());
  final AuthController _authController = Get.find<AuthController>();
  final PdfService _pdfService = PdfService();

  @override
  void initState() {
    super.initState();
    if (_authController.currentUser != null) {
      _resultController.fetchStudentResults(
        studentId: _authController.currentUser!.id!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.description),
            onPressed: () => Get.toNamed('/overall-marksheet'),
            tooltip: 'Overall Marksheet',
          ),
        ],
      ),
      body: Obx(
        () => _resultController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : _resultController.results.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assessment_outlined,
                      size: ResponsiveUtils.responsiveIconSize(context, 80),
                      color: theme.AppTheme.textSecondary,
                    ),
                    SizedBox(
                      height: ResponsiveUtils.responsiveSpacing(context, 16),
                    ),
                    Text(
                      'No results yet',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          18,
                        ),
                        color: theme.AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                padding: ResponsiveUtils.responsivePadding(context),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveUtils.getGridColumns(context),
                  childAspectRatio: ResponsiveUtils.isMobile(context) ? 1.1 : 1.3,
                  crossAxisSpacing: ResponsiveUtils.responsiveSpacing(context, 16),
                  mainAxisSpacing: ResponsiveUtils.responsiveSpacing(context, 16),
                ),
                itemCount: _resultController.results.length,
                itemBuilder: (context, index) {
                  final result = _resultController.results[index];
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.responsiveSpacing(context, 16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Test ${index + 1}',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveUtils.responsiveFontSize(
                                        context,
                                        16,
                                      ),
                                    fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveUtils.responsiveSpacing(
                                    context,
                                    8,
                                  ),
                                  vertical: ResponsiveUtils.responsiveSpacing(
                                    context,
                                    4,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  color: result.status == 'PASS'
                                      ? theme.AppTheme.successColor
                                      : theme.AppTheme.errorColor,
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveUtils.responsiveBorderRadius(
                                      context,
                                      8,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  result.status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            '${result.obtainedMarks}/${result.totalMarks}',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.responsiveFontSize(
                                context,
                                20,
                              ),
                              fontWeight: FontWeight.bold,
                              color: theme.AppTheme.primaryColor,
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveUtils.responsiveSpacing(
                              context,
                              8,
                            ),
                          ),
                          Text(
                            '${result.percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.responsiveFontSize(
                                context,
                                14,
                              ),
                              color: theme.AppTheme.textSecondary,
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveUtils.responsiveSpacing(
                              context,
                              8,
                            ),
                          ),
                          Text(
                            '✓ ${result.correctAnswers} | ✗ ${result.wrongAnswers}',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.responsiveFontSize(
                                context,
                                12,
                              ),
                              color: theme.AppTheme.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            height: ResponsiveUtils.responsiveButtonHeight(context) * 0.7,
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _pdfService.generateResultPDF(result),
                              icon: const Icon(Icons.download, size: 16),
                              label: const Text('PDF', style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      ResponsiveUtils.responsiveSpacing(
                                        context,
                                        8,
                                      ),
                                  vertical:
                                      ResponsiveUtils.responsiveSpacing(
                                        context,
                                        8,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
