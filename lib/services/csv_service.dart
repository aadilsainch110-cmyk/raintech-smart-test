import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class CsvService {
  List<List<dynamic>> parseCsv(String csvData) {
    return const CsvToListConverter().convert(csvData);
  }

  String generateCsv(List<List<dynamic>> rows) {
    return const ListToCsvConverter().convert(rows);
  }

  Map<String, dynamic> validateQuestionRow(List<dynamic> row, int rowIndex) {
    final errors = <String>[];

    if (row.length < 7) {
      errors.add(
        'Row has insufficient columns (expected 7, got ${row.length})',
      );
      return {'isValid': false, 'errors': errors};
    }

    final question = row[0]?.toString().trim() ?? '';
    final optionA = row[1]?.toString().trim() ?? '';
    final optionB = row[2]?.toString().trim() ?? '';
    final optionC = row[3]?.toString().trim() ?? '';
    final optionD = row[4]?.toString().trim() ?? '';
    final correctAnswer = row[5]?.toString().trim().toUpperCase() ?? '';
    final marks = row[6]?.toString().trim() ?? '';

    if (question.isEmpty) {
      errors.add('Question is empty');
    }

    if (optionA.isEmpty) {
      errors.add('Option A is empty');
    }

    if (optionB.isEmpty) {
      errors.add('Option B is empty');
    }

    if (optionC.isEmpty) {
      errors.add('Option C is empty');
    }

    if (optionD.isEmpty) {
      errors.add('Option D is empty');
    }

    if (correctAnswer.isEmpty ||
        !['A', 'B', 'C', 'D'].contains(correctAnswer)) {
      errors.add('Correct answer must be A, B, C, or D');
    }

    final marksValue = int.tryParse(marks);
    if (marksValue == null || marksValue <= 0) {
      errors.add('Marks must be a positive number');
    }

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
      'question': question,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'correctAnswer': correctAnswer,
      'marks': marksValue ?? 1,
    };
  }

  String generateQuestionTemplate() {
    final rows = [
      [
        'question',
        'optionA',
        'optionB',
        'optionC',
        'optionD',
        'correctAnswer',
        'marks',
      ],
      [
        'What is Python?',
        'Programming Language',
        'Operating System',
        'Database',
        'Browser',
        'A',
        '1',
      ],
      [
        'What is Flutter?',
        'Framework',
        'Database',
        'Operating System',
        'Browser',
        'A',
        '1',
      ],
    ];
    return generateCsv(rows);
  }

  String generateResultCsv(List<Map<String, dynamic>> results) {
    final rows = [
      [
        'position',
        'studentName',
        'studentId',
        'course',
        'class',
        'shift',
        'totalMarks',
        'obtainedMarks',
        'percentage',
        'status',
      ],
      ...results.map(
        (result) => [
          result['position'] ?? 'N/A',
          result['studentName'] ?? '',
          result['studentId'] ?? '',
          result['course'] ?? '',
          result['class'] ?? '',
          result['shift'] ?? '',
          result['totalMarks'] ?? 0,
          result['obtainedMarks'] ?? 0,
          result['percentage'] ?? 0,
          result['status'] ?? '',
        ],
      ),
    ];
    return generateCsv(rows);
  }

  Future<String?> exportResultsToCsv(List<Map<String, dynamic>> results) async {
    try {
      final headers = [
        'Student Name',
        'Email',
        'Student ID',
        'Obtained Marks',
        'Total Marks',
        'Percentage',
        'Status',
        'Position',
        'Submitted At',
      ];

      final rows = results.map((result) {
        return [
          result['studentName'] ?? 'Unknown',
          result['email'] ?? '',
          result['studentId'] ?? 'N/A',
          result['obtainedMarks'] ?? 0,
          result['totalMarks'] ?? 0,
          (result['percentage'] ?? 0.0).toStringAsFixed(2),
          result['status'] ?? 'FAIL',
          result['position'] != null ? result['position'].toString() : 'N/A',
          result['submittedAt'] != null
              ? DateFormat(
                  'yyyy-MM-dd HH:mm:ss',
                ).format(DateTime.parse(result['submittedAt']))
              : 'N/A',
        ];
      }).toList();

      final csvData = [headers, ...rows];
      final csvString = const ListToCsvConverter().convert(csvData);

      // Let user choose save location
      final resultPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Results CSV',
        fileName:
            'results_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (resultPath != null) {
        final file = File(resultPath);
        await file.writeAsString(csvString);
        return resultPath;
      }

      return null;
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }

  Future<String?> exportQuestionsToCsv(
    List<Map<String, dynamic>> questions,
  ) async {
    try {
      final headers = [
        'Question',
        'Option A',
        'Option B',
        'Option C',
        'Option D',
        'Correct Answer',
        'Marks',
      ];

      final rows = questions.map((question) {
        return [
          question['question'] ?? '',
          question['optionA'] ?? '',
          question['optionB'] ?? '',
          question['optionC'] ?? '',
          question['optionD'] ?? '',
          question['correctAnswer'] ?? '',
          question['marks'] ?? 1,
        ];
      }).toList();

      final csvData = [headers, ...rows];
      final csvString = const ListToCsvConverter().convert(csvData);

      final resultPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Questions CSV',
        fileName:
            'questions_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (resultPath != null) {
        final file = File(resultPath);
        await file.writeAsString(csvString);
        return resultPath;
      }

      return null;
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }
}
