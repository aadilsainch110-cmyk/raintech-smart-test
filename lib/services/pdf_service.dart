import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/result_model.dart';
import '../models/user_model.dart';
import '../models/test_model.dart';
import '../models/course_model.dart';
import '../models/shift_model.dart';
import '../models/class_model.dart';

class PdfService {
  Future<void> generateResultPDF(ResultModel result) async {
    final pdf = pw.Document();

    // Load logo image from assets
    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/logo/logo.png')).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue800,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Image(
                      logoImage,
                      width: 50,
                      height: 50,
                    ),
                    pw.SizedBox(width: 12),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'RAINTECH',
                          style: pw.TextStyle(
                            fontSize: 32,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Online Testing System',
                          style: pw.TextStyle(fontSize: 16, color: PdfColors.white),
                        ),
                      ],
                    ),
                    pw.SizedBox(width: 12),
                    pw.Text(
                      'RESULT',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Results
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Test Results',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 16),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(16),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.blue100,
                              borderRadius: pw.BorderRadius.circular(8),
                            ),
                            child: pw.Column(
                              children: [
                                pw.Text(
                                  'Obtained Marks',
                                  style: pw.TextStyle(fontSize: 12),
                                ),
                                pw.SizedBox(height: 8),
                                pw.Text(
                                  '${result.obtainedMarks}',
                                  style: pw.TextStyle(
                                    fontSize: 32,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 16),
                        pw.Expanded(
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(16),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.green100,
                              borderRadius: pw.BorderRadius.circular(8),
                            ),
                            child: pw.Column(
                              children: [
                                pw.Text(
                                  'Total Marks',
                                  style: pw.TextStyle(fontSize: 12),
                                ),
                                pw.SizedBox(height: 8),
                                pw.Text(
                                  '${result.totalMarks}',
                                  style: pw.TextStyle(
                                    fontSize: 32,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 16),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(16),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.orange100,
                              borderRadius: pw.BorderRadius.circular(8),
                            ),
                            child: pw.Column(
                              children: [
                                pw.Text(
                                  'Percentage',
                                  style: pw.TextStyle(fontSize: 12),
                                ),
                                pw.SizedBox(height: 8),
                                pw.Text(
                                  '${result.percentage.toStringAsFixed(1)}%',
                                  style: pw.TextStyle(
                                    fontSize: 24,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 16),
                        pw.Expanded(
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(16),
                            decoration: pw.BoxDecoration(
                              color: result.status == 'PASS'
                                  ? PdfColors.green100
                                  : PdfColors.red100,
                              borderRadius: pw.BorderRadius.circular(8),
                            ),
                            child: pw.Column(
                              children: [
                                pw.Text(
                                  'Status',
                                  style: pw.TextStyle(fontSize: 12),
                                ),
                                pw.SizedBox(height: 8),
                                pw.Text(
                                  result.status,
                                  style: pw.TextStyle(
                                    fontSize: 24,
                                    fontWeight: pw.FontWeight.bold,
                                    color: result.status == 'PASS'
                                        ? PdfColors.green800
                                        : PdfColors.red800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 16),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(16),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.green100,
                              borderRadius: pw.BorderRadius.circular(8),
                            ),
                            child: pw.Column(
                              children: [
                                pw.Text(
                                  'Correct Answers',
                                  style: pw.TextStyle(fontSize: 12),
                                ),
                                pw.SizedBox(height: 8),
                                pw.Text(
                                  '${result.correctAnswers}',
                                  style: pw.TextStyle(
                                    fontSize: 24,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 16),
                        pw.Expanded(
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(16),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.red100,
                              borderRadius: pw.BorderRadius.circular(8),
                            ),
                            child: pw.Column(
                              children: [
                                pw.Text(
                                  'Wrong Answers',
                                  style: pw.TextStyle(fontSize: 12),
                                ),
                                pw.SizedBox(height: 8),
                                pw.Text(
                                  '${result.wrongAnswers}',
                                  style: pw.TextStyle(
                                    fontSize: 24,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (result.showPosition && result.position != null) ...[
                      pw.SizedBox(height: 16),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(16),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.purple100,
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Text(
                              'Position: ',
                              style: pw.TextStyle(fontSize: 16),
                            ),
                            pw.Text(
                              result.getPositionDisplay(),
                              style: pw.TextStyle(
                                fontSize: 24,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.purple800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Footer
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'This is an electronically generated result.',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Generated on: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'result_${result.studentId}.pdf',
    );
  }

  Future<void> generateMarksheet({
    required ResultModel result,
    required UserModel student,
    required TestModel test,
    CourseModel? course,
  }) async {
    final pdf = pw.Document();

    // Calculate assessment details
    final totalAttempted = result.correctAnswers + result.wrongAnswers;
    final accuracy = totalAttempted > 0
        ? ((result.correctAnswers / totalAttempted) * 100).toStringAsFixed(1)
        : '0.0';

    // Debug logging - verify actual result data
    debugPrint('=== DEBUG: generateMarksheet ===');
    debugPrint('result.testId: ${result.testId}');
    debugPrint('result.studentId: ${result.studentId}');
    debugPrint('result.obtainedMarks: ${result.obtainedMarks}');
    debugPrint('result.totalMarks: ${result.totalMarks}');
    debugPrint('result.percentage: ${result.percentage}');
    debugPrint('result.status: ${result.status}');
    debugPrint('result.correctAnswers: ${result.correctAnswers}');
    debugPrint('result.wrongAnswers: ${result.wrongAnswers}');
    debugPrint('result.getGrade(): ${result.getGrade()}');
    debugPrint('result.showPosition: ${result.showPosition}');
    debugPrint('result.position: ${result.position}');
    debugPrint('result.getPositionDisplay(): ${result.getPositionDisplay()}');
    debugPrint('result.submittedAt: ${result.submittedAt}');
    debugPrint('==============================');

    // Load logo image from assets
    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/logo/logo.png')).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with Logo and Title
              pw.Container(
                padding: const pw.EdgeInsets.all(24),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue800,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                      children: [
                        pw.Image(
                          logoImage,
                          width: 60,
                          height: 60,
                        ),
                        pw.SizedBox(width: 16),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'RAINTECH',
                              style: pw.TextStyle(
                                fontSize: 36,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Smart Test',
                              style: pw.TextStyle(
                                fontSize: 18,
                                color: PdfColors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'MARKSHEET',
                          style: pw.TextStyle(
                            fontSize: 28,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          DateFormat('dd MMM yyyy').format(DateTime.now()),
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Student Information Card
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 2),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Student Information',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 16),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: _buildInfoRow('Name', student.name),
                        ),
                        pw.SizedBox(width: 16),
                        pw.Expanded(
                          child: _buildInfoRow('Email', student.email),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: _buildInfoRow('Student ID', student.studentId ?? 'N/A'),
                        ),
                        pw.SizedBox(width: 16),
                        pw.Expanded(
                          child: _buildInfoRow('Phone', student.phone ?? 'N/A'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Test Information Card
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 2),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Test Information',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 16),
                    _buildInfoRow('Test Name', test.title),
                    pw.SizedBox(height: 12),
                    _buildInfoRow('Course', course?.name ?? 'N/A'),
                    pw.SizedBox(height: 12),
                    _buildInfoRow('Duration', '${test.durationMinutes} minutes'),
                    pw.SizedBox(height: 12),
                    _buildInfoRow(
                      'Test Date',
                      result.submittedAt != null
                          ? DateFormat('dd MMM yyyy, hh:mm a').format(result.submittedAt!)
                          : 'N/A',
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Results Card
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 2),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Performance',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: _buildResultCard(
                            'Obtained Marks',
                            '${result.obtainedMarks}',
                            PdfColors.blue100,
                            PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(width: 16),
                        pw.Expanded(
                          child: _buildResultCard(
                            'Total Marks',
                            '${result.totalMarks}',
                            PdfColors.green100,
                            PdfColors.green800,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 16),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: _buildResultCard(
                            'Percentage',
                            '${result.percentage.toStringAsFixed(1)}%',
                            PdfColors.orange100,
                            PdfColors.orange800,
                          ),
                        ),
                        pw.SizedBox(width: 16),
                        pw.Expanded(
                          child: _buildResultCard(
                            'Grade',
                            result.getGrade(),
                            result.getGrade() == 'A+' || result.getGrade() == 'A'
                                ? PdfColors.green100
                                : result.getGrade() == 'F'
                                    ? PdfColors.red100
                                    : PdfColors.yellow100,
                            result.getGrade() == 'A+' || result.getGrade() == 'A'
                                ? PdfColors.green800
                                : result.getGrade() == 'F'
                                    ? PdfColors.red800
                                    : PdfColors.orange800,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 16),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: _buildResultCard(
                            'Status',
                            result.status,
                            result.status == 'PASS'
                                ? PdfColors.green100
                                : PdfColors.red100,
                            result.status == 'PASS'
                                ? PdfColors.green800
                                : PdfColors.red800,
                          ),
                        ),
                        pw.SizedBox(width: 16),
                        pw.Expanded(
                          child: _buildResultCard(
                            'Correct',
                            '${result.correctAnswers}',
                            PdfColors.green100,
                            PdfColors.green800,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 16),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: _buildResultCard(
                            'Wrong',
                            '${result.wrongAnswers}',
                            PdfColors.red100,
                            PdfColors.red800,
                          ),
                        ),
                        pw.SizedBox(width: 16),
                        if (result.showPosition && result.position != null)
                          pw.Expanded(
                            child: _buildResultCard(
                              'Position',
                              result.getPositionDisplay(),
                              PdfColors.purple100,
                              PdfColors.purple800,
                            ),
                          )
                        else
                          pw.Expanded(
                            child: _buildResultCard(
                              'Position',
                              'N/A',
                              PdfColors.grey200,
                              PdfColors.grey600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Assessment Details Card
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 2),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Assessment Details',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 16),
                    _buildInfoRow('Total Questions Attempted', '${result.correctAnswers + result.wrongAnswers}'),
                    pw.SizedBox(height: 8),
                    _buildInfoRow('Correct Answers', '${result.correctAnswers}'),
                    pw.SizedBox(height: 8),
                    _buildInfoRow('Wrong Answers', '${result.wrongAnswers}'),
                    pw.SizedBox(height: 8),
                    _buildInfoRow('Accuracy', '$accuracy%'),
                    pw.SizedBox(height: 8),
                    _buildInfoRow(
                      'Submission Date',
                      result.submittedAt != null
                          ? DateFormat('dd MMM yyyy, hh:mm a').format(result.submittedAt!)
                          : 'N/A',
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Footer
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'This is an electronically generated marksheet.',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Generated on: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'marksheet_${student.name}_${test.title}.pdf',
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 120,
          child: pw.Text(
            '$label:',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              color: PdfColors.black,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildResultCard(
    String label,
    String value,
    bgColor,
    textColor,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> generateAllMarksheets({
    required List<ResultModel> results,
    required List<UserModel> students,
    required TestModel test,
    CourseModel? course,
  }) async {
    final pdf = pw.Document();

    // Load logo image from assets
    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/logo/logo.png')).buffer.asUint8List(),
    );

    for (int i = 0; i < results.length; i++) {
      final result = results[i];
      final student = students
          .where((s) => s.id == result.studentId)
          .firstOrNull;

      if (student != null) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(20),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header with Logo and Title
                  pw.Container(
                    padding: const pw.EdgeInsets.all(24),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue800,
                      borderRadius: pw.BorderRadius.circular(12),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Row(
                          children: [
                            pw.Image(
                              logoImage,
                              width: 60,
                              height: 60,
                            ),
                            pw.SizedBox(width: 16),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'RAINTECH',
                                  style: pw.TextStyle(
                                    fontSize: 36,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.white,
                                  ),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  'Smart Test',
                                  style: pw.TextStyle(
                                    fontSize: 18,
                                    color: PdfColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              'MARKSHEET',
                              style: pw.TextStyle(
                                fontSize: 28,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              DateFormat('dd MMM yyyy').format(DateTime.now()),
                              style: pw.TextStyle(
                                fontSize: 14,
                                color: PdfColors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 24),

                  // Student Information Card
                  pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300, width: 2),
                      borderRadius: pw.BorderRadius.circular(12),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Student Information',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 16),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: _buildInfoRow('Name', student.name),
                            ),
                            pw.SizedBox(width: 16),
                            pw.Expanded(
                              child: _buildInfoRow('Email', student.email),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 12),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: _buildInfoRow('Student ID', student.studentId ?? 'N/A'),
                            ),
                            pw.SizedBox(width: 16),
                            pw.Expanded(
                              child: _buildInfoRow('Phone', student.phone ?? 'N/A'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Test Information Card
                  pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300, width: 2),
                      borderRadius: pw.BorderRadius.circular(12),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Test Information',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 16),
                        _buildInfoRow('Test Name', test.title),
                        pw.SizedBox(height: 12),
                        _buildInfoRow('Course', course?.name ?? 'N/A'),
                        pw.SizedBox(height: 12),
                        _buildInfoRow('Duration', '${test.durationMinutes} minutes'),
                        pw.SizedBox(height: 12),
                        _buildInfoRow(
                          'Test Date',
                          result.submittedAt != null
                              ? DateFormat('dd MMM yyyy, hh:mm a').format(result.submittedAt!)
                              : 'N/A',
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Results Card
                  pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300, width: 2),
                      borderRadius: pw.BorderRadius.circular(12),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Performance',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 20),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Expanded(
                              child: _buildResultCard(
                                'Obtained Marks',
                                '${result.obtainedMarks}',
                                PdfColors.blue100,
                                PdfColors.blue800,
                              ),
                            ),
                            pw.SizedBox(width: 16),
                            pw.Expanded(
                              child: _buildResultCard(
                                'Total Marks',
                                '${result.totalMarks}',
                                PdfColors.green100,
                                PdfColors.green800,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 16),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Expanded(
                              child: _buildResultCard(
                                'Percentage',
                                '${result.percentage.toStringAsFixed(1)}%',
                                PdfColors.orange100,
                                PdfColors.orange800,
                              ),
                            ),
                            pw.SizedBox(width: 16),
                            pw.Expanded(
                              child: _buildResultCard(
                                'Grade',
                                result.getGrade(),
                                result.getGrade() == 'A+' || result.getGrade() == 'A'
                                    ? PdfColors.green100
                                    : result.getGrade() == 'F'
                                        ? PdfColors.red100
                                        : PdfColors.yellow100,
                                result.getGrade() == 'A+' || result.getGrade() == 'A'
                                    ? PdfColors.green800
                                    : result.getGrade() == 'F'
                                        ? PdfColors.red800
                                        : PdfColors.orange800,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 16),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Expanded(
                              child: _buildResultCard(
                                'Status',
                                result.status,
                                result.status == 'PASS'
                                    ? PdfColors.green100
                                    : PdfColors.red100,
                                result.status == 'PASS'
                                    ? PdfColors.green800
                                    : PdfColors.red800,
                              ),
                            ),
                            pw.SizedBox(width: 16),
                            pw.Expanded(
                              child: _buildResultCard(
                                'Correct',
                                '${result.correctAnswers}',
                                PdfColors.green100,
                                PdfColors.green800,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 16),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Expanded(
                              child: _buildResultCard(
                                'Wrong',
                                '${result.wrongAnswers}',
                                PdfColors.red100,
                                PdfColors.red800,
                              ),
                            ),
                            pw.SizedBox(width: 16),
                            if (result.showPosition && result.position != null)
                              pw.Expanded(
                                child: _buildResultCard(
                                  'Position',
                                  result.getPositionDisplay(),
                                  PdfColors.purple100,
                                  PdfColors.purple800,
                                ),
                              )
                            else
                              pw.Expanded(
                                child: _buildResultCard(
                                  'Position',
                                  'N/A',
                                  PdfColors.grey200,
                                  PdfColors.grey600,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Footer
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'This is an electronically generated marksheet.',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Generated on: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'all_marksheets_${test.title}.pdf',
    );
  }

  Future<void> generateClassResultSheet({
    required List<ResultModel> results,
    required List<UserModel> students,
    required TestModel test,
    CourseModel? course,
    ShiftModel? shift,
    ClassModel? schoolClass,
  }) async {
    final pdf = pw.Document();

    // Load logo image from assets
    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/logo/logo.png')).buffer.asUint8List(),
    );

    // Calculate statistics
    final totalStudents = results.length;
    final passedStudents = results.where((r) => r.status == 'PASS').length;
    final failedStudents = results.where((r) => r.status == 'FAIL').length;
    final needImprovement = results.where((r) => r.percentage >= 40 && r.percentage < 50).length;
    final highestMarks = results.isEmpty ? 0 : results.map((r) => r.obtainedMarks).reduce((a, b) => a > b ? a : b);
    final lowestMarks = results.isEmpty ? 0 : results.map((r) => r.obtainedMarks).reduce((a, b) => a < b ? a : b);
    final totalObtainedMarks = results.fold(0, (sum, r) => sum + r.obtainedMarks);
    final classAverage = totalStudents > 0 ? (totalObtainedMarks / totalStudents).toStringAsFixed(2) : '0.00';

    // Sort results by obtained marks descending
    final sortedResults = List<ResultModel>.from(results);
    sortedResults.sort((a, b) => b.obtainedMarks.compareTo(a.obtainedMarks));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginBottom: 50,
          marginLeft: 50,
          marginRight: 50,
          marginTop: 50,
        ),
        orientation: pw.PageOrientation.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with RAINTECH branding
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue800,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                      children: [
                        pw.Image(
                          logoImage,
                          width: 50,
                          height: 50,
                        ),
                        pw.SizedBox(width: 12),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'RAINTECH',
                              style: pw.TextStyle(
                                fontSize: 32,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Smart Test - Professional Result Sheet',
                              style: pw.TextStyle(
                                fontSize: 16,
                                color: PdfColors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'CLASS RESULT',
                          style: pw.TextStyle(
                            fontSize: 28,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          DateFormat('dd MMM yyyy').format(DateTime.now()),
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Test Information
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400, width: 2),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: _buildInfoColumn('Course/Shift', course?.name ?? 'N/A'),
                    ),
                    pw.SizedBox(width: 16),
                    pw.Expanded(
                      child: _buildInfoColumn('Test Name', test.title),
                    ),
                    pw.SizedBox(width: 16),
                    pw.Expanded(
                      child: _buildInfoColumn('Total Marks', '${test.totalMarks}'),
                    ),
                    pw.SizedBox(width: 16),
                    pw.Expanded(
                      child: _buildInfoColumn(
                        'Test Date',
                        test.startDate != null
                            ? DateFormat('dd MMM yyyy').format(test.startDate!)
                            : 'N/A',
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Results Table
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400, width: 2),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    // Table Header
                    pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue800,
                      ),
                      child: pw.Row(
                        children: [
                          _buildTableCell('S.No', 40, PdfColors.white, true),
                          _buildTableCell('Student Name', 200, PdfColors.white, true),
                          _buildTableCell('Roll No', 80, PdfColors.white, true),
                          _buildTableCell('Obtained', 60, PdfColors.white, true),
                          _buildTableCell('Total', 60, PdfColors.white, true),
                          _buildTableCell('Percentage', 70, PdfColors.white, true),
                          _buildTableCell('Position', 60, PdfColors.white, true),
                          _buildTableCell('Status', 80, PdfColors.white, true),
                        ],
                      ),
                    ),
                    // Table Body
                    ...List.generate(sortedResults.length, (index) {
                      final result = sortedResults[index];
                      final student = students
                          .where((s) => s.id == result.studentId)
                          .firstOrNull;
                      final position = index + 1;
                      final positionDisplay = test.resultsReleased
                          ? '$position${_getOrdinalSuffix(position)}'
                          : 'N/A';

                      return pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          color: index % 2 == 0 ? PdfColors.white : PdfColors.grey100,
                        ),
                        child: pw.Row(
                          children: [
                            _buildTableCell('${index + 1}', 40, PdfColors.black, false),
                            _buildTableCell(student?.name ?? 'Unknown', 200, PdfColors.black, false),
                            _buildTableCell(student?.studentId ?? 'N/A', 80, PdfColors.black, false),
                            _buildTableCell('${result.obtainedMarks}', 60, PdfColors.black, false),
                            _buildTableCell('${result.totalMarks}', 60, PdfColors.black, false),
                            _buildTableCell('${result.percentage.toStringAsFixed(1)}%', 70, PdfColors.black, false),
                            _buildTableCell(positionDisplay, 60, PdfColors.black, false),
                            pw.Expanded(
                              child: pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: pw.BoxDecoration(
                                  color: result.status == 'PASS'
                                      ? PdfColors.green
                                      : result.percentage >= 40 && result.percentage < 50
                                          ? PdfColors.orange
                                          : PdfColors.red,
                                  borderRadius: pw.BorderRadius.circular(4),
                                ),
                                child: pw.Text(
                                  result.status == 'PASS'
                                      ? 'PASS'
                                      : result.percentage >= 40 && result.percentage < 50
                                          ? 'Need Imp.'
                                          : 'FAIL',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.white,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Summary Statistics
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400, width: 2),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Summary Statistics',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      children: [
                        _buildStatCard('Total Students', '$totalStudents', PdfColors.blue100, PdfColors.blue800),
                        pw.SizedBox(width: 12),
                        _buildStatCard('Passed', '$passedStudents', PdfColors.green100, PdfColors.green800),
                        pw.SizedBox(width: 12),
                        _buildStatCard('Failed', '$failedStudents', PdfColors.red100, PdfColors.red800),
                        pw.SizedBox(width: 12),
                        _buildStatCard('Need Improvement', '$needImprovement', PdfColors.orange100, PdfColors.orange800),
                      ],
                    ),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      children: [
                        _buildStatCard('Class Average', classAverage, PdfColors.purple100, PdfColors.purple800),
                        pw.SizedBox(width: 12),
                        _buildStatCard('Highest Marks', '$highestMarks', PdfColors.green100, PdfColors.green800),
                        pw.SizedBox(width: 12),
                        _buildStatCard('Lowest Marks', '$lowestMarks', PdfColors.red100, PdfColors.red800),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Footer
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Generated by RAINTECH Smart Test System',
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'class_result_${test.title}.pdf',
    );
  }

  pw.Widget _buildInfoColumn(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 11,
            color: PdfColors.grey700,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, double width, color, bool isHeader) {
    return pw.SizedBox(
      width: width,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildStatCard(String label, String value, bgColor, textColor) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: bgColor,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) {
      return 'th';
    }
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  Future<void> generateAllStudentsResultsPDF({
    required List<Map<String, dynamic>> resultsData,
    required List<CourseModel> courses,
    required List<ShiftModel> shifts,
    required List<ClassModel> classes,
  }) async {
    final pdf = pw.Document();

    // Load logo image from assets
    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/logo/logo.png')).buffer.asUint8List(),
    );

    // Calculate statistics
    final totalStudents = resultsData.length;
    final passedStudents = resultsData.where((r) => (r['result'] as ResultModel).status == 'PASS').length;
    final failedStudents = resultsData.where((r) => (r['result'] as ResultModel).status == 'FAIL').length;
    final needImprovement = resultsData.where((r) {
      final result = r['result'] as ResultModel;
      return result.percentage >= 40 && result.percentage < 50;
    }).length;
    final highestMarks = resultsData.isEmpty
        ? 0
        : resultsData.map((r) => (r['result'] as ResultModel).obtainedMarks).reduce((a, b) => a > b ? a : b);
    final lowestMarks = resultsData.isEmpty
        ? 0
        : resultsData.map((r) => (r['result'] as ResultModel).obtainedMarks).reduce((a, b) => a < b ? a : b);
    final totalObtainedMarks = resultsData.fold(0, (sum, r) => sum + (r['result'] as ResultModel).obtainedMarks);
    final classAverage = totalStudents > 0 ? (totalObtainedMarks / totalStudents).toStringAsFixed(2) : '0.00';

    // Generate pages (max 30 results per page)
    const resultsPerPage = 30;
    final totalPages = (resultsData.length / resultsPerPage).ceil();

    for (int page = 0; page < totalPages; page++) {
      final startIndex = page * resultsPerPage;
      final endIndex = (startIndex + resultsPerPage).clamp(0, resultsData.length);
      final pageResults = resultsData.sublist(startIndex, endIndex);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.copyWith(
            marginBottom: 50,
            marginLeft: 50,
            marginRight: 50,
            marginTop: 50,
          ),
          orientation: pw.PageOrientation.landscape,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header with RAINTECH branding
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue800,
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Row(
                        children: [
                          pw.Image(
                            logoImage,
                            width: 50,
                            height: 50,
                          ),
                          pw.SizedBox(width: 12),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'RAINTECH',
                                style: pw.TextStyle(
                                  fontSize: 32,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                'Smart Test - All Students Results',
                                style: pw.TextStyle(
                                  fontSize: 16,
                                  color: PdfColors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'COMPLETE RESULTS',
                            style: pw.TextStyle(
                              fontSize: 28,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            DateFormat('dd MMM yyyy').format(DateTime.now()),
                            style: pw.TextStyle(
                              fontSize: 14,
                              color: PdfColors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Results Table
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400, width: 2),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      // Table Header
                      pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue800,
                        ),
                        child: pw.Row(
                          children: [
                            _buildTableCell('#', 30, PdfColors.white, true),
                            _buildTableCell('Student Name', 150, PdfColors.white, true),
                            _buildTableCell('Student ID', 60, PdfColors.white, true),
                            _buildTableCell('Course', 80, PdfColors.white, true),
                            _buildTableCell('Shift', 50, PdfColors.white, true),
                            _buildTableCell('Test', 100, PdfColors.white, true),
                            _buildTableCell('Obtained', 50, PdfColors.white, true),
                            _buildTableCell('Total', 40, PdfColors.white, true),
                            _buildTableCell('%', 40, PdfColors.white, true),
                            _buildTableCell('Grade', 40, PdfColors.white, true),
                            _buildTableCell('Position', 50, PdfColors.white, true),
                            _buildTableCell('Status', 50, PdfColors.white, true),
                          ],
                        ),
                      ),
                      // Table Body
                      ...List.generate(pageResults.length, (index) {
                        final item = pageResults[index];
                        final result = item['result'] as ResultModel;
                        final student = item['student'] as UserModel;
                        final test = item['test'] as TestModel;
                        final course = courses.where((c) => c.id == test.courseId).firstOrNull;
                        final shift = shifts.where((s) => s.id == test.shiftId).firstOrNull;
                        final position = startIndex + index + 1;
                        final positionDisplay = test.resultsReleased
                            ? '$position${_getOrdinalSuffix(position)}'
                            : 'N/A';

                        return pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            color: index % 2 == 0 ? PdfColors.white : PdfColors.grey100,
                          ),
                          child: pw.Row(
                            children: [
                              _buildTableCell('${startIndex + index + 1}', 30, PdfColors.black, false),
                              _buildTableCell(student.name, 150, PdfColors.black, false),
                              _buildTableCell(student.studentId ?? 'N/A', 60, PdfColors.black, false),
                              _buildTableCell(course?.name ?? 'N/A', 80, PdfColors.black, false),
                              _buildTableCell(shift?.name ?? 'N/A', 50, PdfColors.black, false),
                              _buildTableCell(test.title, 100, PdfColors.black, false),
                              _buildTableCell('${result.obtainedMarks}', 50, PdfColors.black, false),
                              _buildTableCell('${result.totalMarks}', 40, PdfColors.black, false),
                              _buildTableCell('${result.percentage.toStringAsFixed(1)}%', 40, PdfColors.black, false),
                              _buildTableCell(result.getGrade(), 40, PdfColors.black, false),
                              _buildTableCell(positionDisplay, 50, PdfColors.black, false),
                              pw.Expanded(
                                child: pw.Container(
                                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: pw.BoxDecoration(
                                    color: result.status == 'PASS'
                                        ? PdfColors.green
                                        : result.percentage >= 40 && result.percentage < 50
                                            ? PdfColors.orange
                                            : PdfColors.red,
                                    borderRadius: pw.BorderRadius.circular(3),
                                  ),
                                  child: pw.Text(
                                    result.status == 'PASS'
                                        ? 'PASS'
                                        : result.percentage >= 40 && result.percentage < 50
                                            ? 'Need Imp.'
                                            : 'FAIL',
                                    style: pw.TextStyle(
                                      fontSize: 9,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.white,
                                    ),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Summary Statistics (only on last page)
                if (page == totalPages - 1) ...[
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400, width: 2),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Summary Statistics',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 12),
                        pw.Row(
                          children: [
                            _buildStatCard('Total Students', '$totalStudents', PdfColors.blue100, PdfColors.blue800),
                            pw.SizedBox(width: 12),
                            _buildStatCard('Passed', '$passedStudents', PdfColors.green100, PdfColors.green800),
                            pw.SizedBox(width: 12),
                            _buildStatCard('Failed', '$failedStudents', PdfColors.red100, PdfColors.red800),
                            pw.SizedBox(width: 12),
                            _buildStatCard('Need Improvement', '$needImprovement', PdfColors.orange100, PdfColors.orange800),
                          ],
                        ),
                        pw.SizedBox(height: 12),
                        pw.Row(
                          children: [
                            _buildStatCard('Class Average', classAverage, PdfColors.purple100, PdfColors.purple800),
                            pw.SizedBox(width: 12),
                            _buildStatCard('Highest Marks', '$highestMarks', PdfColors.green100, PdfColors.green800),
                            pw.SizedBox(width: 12),
                            _buildStatCard('Lowest Marks', '$lowestMarks', PdfColors.red100, PdfColors.red800),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),
                ],

                // Footer
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Generated by RAINTECH Smart Test System',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        'Page ${page + 1} of $totalPages',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        'Date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'all_students_results.pdf',
    );
  }
}
