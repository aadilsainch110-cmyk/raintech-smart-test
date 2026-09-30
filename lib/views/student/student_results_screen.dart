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
            : ListView.builder(
                padding: ResponsiveUtils.responsivePadding(context),
                itemCount: _resultController.results.length,
                itemBuilder: (context, index) {
                  final result = _resultController.results[index];
                  return Card(
                    margin: EdgeInsets.only(
                      bottom: ResponsiveUtils.responsiveSpacing(context, 16),
                    ),
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
                              Expanded(
                                child: Text(
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
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveUtils.responsiveSpacing(
                                    context,
                                    12,
                                  ),
                                  vertical: ResponsiveUtils.responsiveSpacing(
                                    context,
                                    6,
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
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: ResponsiveUtils.responsiveSpacing(
                              context,
                              12,
                            ),
                          ),
                          Text(
                            'Marks: ${result.obtainedMarks}/${result.totalMarks}',
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
                            'Percentage: ${result.percentage.toStringAsFixed(1)}%',
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
                            'Correct: ${result.correctAnswers} | Wrong: ${result.wrongAnswers}',
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
                              12,
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      _pdfService.generateResultPDF(result),
                                  icon: const Icon(Icons.download),
                                  label: const Text('Download PDF'),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          ResponsiveUtils.responsiveSpacing(
                                            context,
                                            16,
                                          ),
                                      vertical:
                                          ResponsiveUtils.responsiveSpacing(
                                            context,
                                            12,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
