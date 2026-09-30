import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/result_model.dart';
import '../models/user_model.dart';
import '../models/test_model.dart';

class PdfService {
  Future<void> generateMarksheet({
    required ResultModel result,
    required UserModel student,
    required TestModel test,
  }) async {
    final pdf = pw.Document();

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
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'RAINTECH',
                      style: pw.TextStyle(
                        fontSize: 32,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Online Testing System',
                      style: pw.TextStyle(fontSize: 16, color: PdfColors.white),
                    ),
                    pw.SizedBox(height: 16),
                    pw.Text(
                      'MARKSHEET',
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

              // Student Information
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
                      'Student Information',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      children: [
                        pw.Expanded(child: pw.Text('Name: ${student.name}')),
                        pw.Expanded(child: pw.Text('Email: ${student.email}')),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            'Student ID: ${student.studentId ?? "N/A"}',
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text('Phone: ${student.phone ?? "N/A"}'),
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
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Test Information',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Text('Test: ${test.title}'),
                    pw.SizedBox(height: 8),
                    pw.Text('Duration: ${test.durationMinutes} minutes'),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Date: ${result.submittedAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(result.submittedAt!) : "N/A"}',
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

  Future<void> generateAllMarksheets({
    required List<ResultModel> results,
    required List<UserModel> students,
    required TestModel test,
  }) async {
    final pdf = pw.Document();

    for (int i = 0; i < results.length; i++) {
      final result = results[i];
      final student = students
          .where((s) => s.id == result.studentId)
          .firstOrNull;

      if (student != null) {
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
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'RAINTECH',
                          style: pw.TextStyle(
                            fontSize: 32,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Online Testing System',
                          style: pw.TextStyle(
                            fontSize: 16,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 16),
                        pw.Text(
                          'MARKSHEET',
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

                  // Student Information
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
                          'Student Information',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 12),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text('Name: ${student.name}'),
                            ),
                            pw.Expanded(
                              child: pw.Text('Email: ${student.email}'),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Student ID: ${student.studentId ?? "N/A"}',
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Text(
                                'Phone: ${student.phone ?? "N/A"}',
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
                      border: pw.Border.all(color: PdfColors.grey400),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Test Information',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 12),
                        pw.Text('Test: ${test.title}'),
                        pw.SizedBox(height: 8),
                        pw.Text('Duration: ${test.durationMinutes} minutes'),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Date: ${result.submittedAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(result.submittedAt!) : "N/A"}',
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
}
