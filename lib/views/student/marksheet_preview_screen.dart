import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/result_model.dart';
import '../../models/user_model.dart';
import '../../models/test_model.dart';
import '../../models/course_model.dart';
import '../../services/pdf_service.dart';
import '../../app/theme/app_theme.dart' as theme;

class MarksheetPreviewScreen extends StatelessWidget {
  final ResultModel result;
  final UserModel student;
  final TestModel test;
  final CourseModel? course;

  const MarksheetPreviewScreen({
    super.key,
    required this.result,
    required this.student,
    required this.test,
    this.course,
  });

  @override
  Widget build(BuildContext context) {
    print('DEBUG: Marksheet Preview Screen');
    print('  - Student Firebase UID (id): ${student.id}');
    print('  - Student Custom ID (studentId): ${student.studentId ?? "NULL"}');
    print('  - Student Name: ${student.name}');
    print('  - Student Email: ${student.email}');

    final pdfService = PdfService();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Marksheet Preview'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadMarksheetPdf(pdfService),
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 24),

                    // Student Information
                    _buildStudentInfo(),
                    const SizedBox(height: 24),

                    // Test Information
                    _buildTestInfo(),
                    const SizedBox(height: 24),

                    // Performance Summary
                    _buildPerformanceSummary(),
                    const SizedBox(height: 24),

                    // Detailed Results
                    _buildDetailedResults(),
                    const SizedBox(height: 24),

                    // Footer
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: theme.AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.school,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'RAINTECH',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: theme.AppTheme.primaryColor,
          ),
        ),
        Text(
          'Smart Test',
          style: TextStyle(
            fontSize: 18,
            color: theme.AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'MARKSHEET',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Name', student.name),
          _buildInfoRow('Email', student.email),
          _buildInfoRow('Student ID', student.id ?? 'N/A'),
          if (student.phone != null && student.phone!.isNotEmpty)
            _buildInfoRow('Phone', student.phone!),
        ],
      ),
    );
  }

  Widget _buildTestInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Test Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Test Name', test.title),
          if (course != null) _buildInfoRow('Course', course!.name),
          _buildInfoRow('Duration', '${test.durationMinutes} minutes'),
          _buildInfoRow('Total Questions', '${test.questionCount}'),
          _buildInfoRow('Test Date', _formatDate(test.startDate)),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummary() {
    final grade = result.getGrade();
    final passFail = result.status == 'PASS' ? 'PASS' : 'FAIL';
    final positionDisplay = result.getPositionDisplay();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Summary',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildResultCard('Obtained Marks', '${result.obtainedMarks}', Colors.blue),
            _buildResultCard('Total Marks', '${result.totalMarks}', Colors.green),
            _buildResultCard('Percentage', '${result.percentage.toStringAsFixed(1)}%', Colors.orange),
            _buildResultCard('Grade', grade, _getGradeColor(grade)),
            _buildResultCard('Status', passFail, passFail == 'PASS' ? Colors.green : Colors.red),
            _buildResultCard('Correct', '${result.correctAnswers}', Colors.green),
            _buildResultCard('Wrong', '${result.wrongAnswers}', Colors.red),
            if (result.showPosition)
              _buildResultCard('Position', positionDisplay, Colors.purple),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailedResults() {
    final totalAttempted = result.correctAnswers + result.wrongAnswers;
    final accuracy = totalAttempted > 0
        ? ((result.correctAnswers / totalAttempted) * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assessment Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Total Questions Attempted', '$totalAttempted'),
          _buildDetailRow('Correct Answers', '${result.correctAnswers}'),
          _buildDetailRow('Wrong Answers', '${result.wrongAnswers}'),
          _buildDetailRow('Accuracy', '$accuracy%'),
          _buildDetailRow('Submission Date', _formatDate(result.submittedAt)),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 12),
        Text(
          'This is an electronically generated marksheet',
          style: TextStyle(
            fontSize: 12,
            color: theme.AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Generated on ${_formatDate(DateTime.now())}',
          style: TextStyle(
            fontSize: 11,
            color: theme.AppTheme.textSecondary.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: theme.AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: theme.AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return Colors.green;
      case 'B+':
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.red.shade300;
      case 'F':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _downloadMarksheetPdf(PdfService pdfService) async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Generate PDF
      await pdfService.generateMarksheet(
        result: result,
        student: student,
        test: test,
        course: course,
      );

      // Close loading dialog
      Get.back();

      // Show success message
      Get.snackbar(
        'Success',
        'Marksheet PDF downloaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to download marksheet: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }
}
