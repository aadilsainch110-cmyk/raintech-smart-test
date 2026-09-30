import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import '../../controllers/question_controller.dart';
import '../../models/test_model.dart';
import '../../models/question_model.dart';
import '../../app/theme/app_theme.dart';
import '../../app/responsive/responsive_utils.dart';

// ignore_for_file: avoid_print

class TestQuestionsScreen extends StatefulWidget {
  const TestQuestionsScreen({super.key});

  @override
  State<TestQuestionsScreen> createState() => _TestQuestionsScreenState();
}

class _TestQuestionsScreenState extends State<TestQuestionsScreen> {
  final QuestionController _questionController = Get.put(QuestionController());

  TestModel? _test;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _test = Get.arguments as TestModel?;
    if (_test != null) {
      await _questionController.fetchQuestionsByTest(testId: _test!.id!);
    }
  }

  Future<void> _showAddQuestionDialog() async {
    final formKey = GlobalKey<FormState>();
    final questionController = TextEditingController();
    final optionAController = TextEditingController();
    final optionBController = TextEditingController();
    final optionCController = TextEditingController();
    final optionDController = TextEditingController();
    final correctAnswerController = TextEditingController();
    final marksController = TextEditingController(text: '1');

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Add Question'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: questionController,
                  decoration: const InputDecoration(
                    labelText: 'Question',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: optionAController,
                  decoration: const InputDecoration(
                    labelText: 'Option A',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: optionBController,
                  decoration: const InputDecoration(
                    labelText: 'Option B',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: optionCController,
                  decoration: const InputDecoration(
                    labelText: 'Option C',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: optionDController,
                  decoration: const InputDecoration(
                    labelText: 'Option D',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: correctAnswerController,
                  decoration: const InputDecoration(
                    labelText: 'Correct Answer (A/B/C/D)',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 1,
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    if (![
                      'A',
                      'B',
                      'C',
                      'D',
                    ].contains(value.trim().toUpperCase())) {
                      return 'Must be A, B, C, or D';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: marksController,
                  decoration: const InputDecoration(
                    labelText: 'Marks',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    final marks = int.tryParse(value);
                    if (marks == null || marks <= 0) {
                      return 'Invalid marks';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Get.back(result: true);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true) {
      print('DEBUG: Dialog returned true, adding question');
      print('DEBUG: Test ID: ${_test!.id!}');
      print('DEBUG: Question: ${questionController.text.trim()}');
      print('DEBUG: Order: ${_questionController.questions.length + 1}');

      final success = await _questionController.addQuestion(
        testId: _test!.id!,
        question: questionController.text.trim(),
        optionA: optionAController.text.trim(),
        optionB: optionBController.text.trim(),
        optionC: optionCController.text.trim(),
        optionD: optionDController.text.trim(),
        correctAnswer: correctAnswerController.text.trim().toUpperCase(),
        marks: int.parse(marksController.text),
        order: _questionController.questions.length + 1,
      );

      print('DEBUG: addQuestion returned: $success');
      if (success) {
        print('DEBUG: Question added successfully, reloading data');
        await _loadData();
        Get.snackbar(
          'Success',
          'Question added',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.successColor,
          colorText: Colors.white,
        );
      } else {
        print(
          'DEBUG: Question addition failed: ${_questionController.errorMessage.value}',
        );
      }
    } else {
      print('DEBUG: Dialog returned false or was cancelled');
    }

    questionController.dispose();
    optionAController.dispose();
    optionBController.dispose();
    optionCController.dispose();
    optionDController.dispose();
    correctAnswerController.dispose();
    marksController.dispose();
  }

  Future<void> _showEditQuestionDialog(QuestionModel question) async {
    final formKey = GlobalKey<FormState>();
    final questionController = TextEditingController(text: question.question);
    final optionAController = TextEditingController(text: question.optionA);
    final optionBController = TextEditingController(text: question.optionB);
    final optionCController = TextEditingController(text: question.optionC);
    final optionDController = TextEditingController(text: question.optionD);
    final correctAnswerController = TextEditingController(
      text: question.correctAnswer,
    );
    final marksController = TextEditingController(
      text: question.marks.toString(),
    );

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Edit Question'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: questionController,
                  decoration: const InputDecoration(
                    labelText: 'Question',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: optionAController,
                  decoration: const InputDecoration(
                    labelText: 'Option A',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: optionBController,
                  decoration: const InputDecoration(
                    labelText: 'Option B',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: optionCController,
                  decoration: const InputDecoration(
                    labelText: 'Option C',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: optionDController,
                  decoration: const InputDecoration(
                    labelText: 'Option D',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: correctAnswerController,
                  decoration: const InputDecoration(
                    labelText: 'Correct Answer (A/B/C/D)',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 1,
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    if (![
                      'A',
                      'B',
                      'C',
                      'D',
                    ].contains(value.trim().toUpperCase())) {
                      return 'Must be A, B, C, or D';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: marksController,
                  decoration: const InputDecoration(
                    labelText: 'Marks',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    final marks = int.tryParse(value);
                    if (marks == null || marks <= 0) {
                      return 'Invalid marks';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Get.back(result: true);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (result == true) {
      final success = await _questionController.updateQuestion(
        questionId: question.id!,
        question: questionController.text.trim(),
        optionA: optionAController.text.trim(),
        optionB: optionBController.text.trim(),
        optionC: optionCController.text.trim(),
        optionD: optionDController.text.trim(),
        correctAnswer: correctAnswerController.text.trim().toUpperCase(),
        marks: int.parse(marksController.text),
      );

      if (success) {
        await _loadData();
        Get.snackbar(
          'Success',
          'Question updated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.successColor,
          colorText: Colors.white,
        );
      }
    }

    questionController.dispose();
    optionAController.dispose();
    optionBController.dispose();
    optionCController.dispose();
    optionDController.dispose();
    correctAnswerController.dispose();
    marksController.dispose();
  }

  Future<void> _deleteQuestion(QuestionModel question) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _questionController.deleteQuestion(
        questionId: question.id!,
      );
      if (success) {
        await _loadData();
        Get.snackbar(
          'Success',
          'Question deleted',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.successColor,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _importQuestionsFromCSV() async {
    print('DEBUG: _importQuestionsFromCSV called');
    try {
      print('DEBUG: Opening file picker');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        print('DEBUG: File selected: ${result.files.single.path}');
        final file = File(result.files.single.path!);
        final bytes = await file.readAsBytes();
        final csvData = String.fromCharCodes(bytes);
        print('DEBUG: CSV data read, length: ${csvData.length}');

        final rows = const CsvToListConverter().convert(csvData);
        print('DEBUG: CSV parsed, rows: ${rows.length}');

        // Skip header row if present
        final startIndex =
            rows[0][0].toString().toLowerCase().contains('question') ? 1 : 0;
        print('DEBUG: Start index (skipping header): $startIndex');

        int importedCount = 0;
        for (int i = startIndex; i < rows.length; i++) {
          final row = rows[i];
          print('DEBUG: Processing row $i, columns: ${row.length}');
          if (row.length >= 6) {
            print('DEBUG: Row has enough columns, adding question');
            final success = await _questionController.addQuestion(
              testId: _test!.id!,
              question: row[0].toString(),
              optionA: row[1].toString(),
              optionB: row[2].toString(),
              optionC: row[3].toString(),
              optionD: row[4].toString(),
              correctAnswer: row[5].toString().toUpperCase(),
              marks: row.length > 6 ? int.tryParse(row[6].toString()) ?? 1 : 1,
              order: _questionController.questions.length + 1,
            );
            if (success) {
              importedCount++;
              print('DEBUG: Question $i imported successfully');
            } else {
              print('DEBUG: Question $i import failed');
            }
          } else {
            print('DEBUG: Row $i skipped - not enough columns');
          }
        }

        print('DEBUG: Total imported: $importedCount');
        await _loadData();

        Get.snackbar(
          'Import Complete',
          'Successfully imported $importedCount questions',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.successColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Import Failed',
        'Error: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_test?.title ?? 'Test Questions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _importQuestionsFromCSV,
            tooltip: 'Import from CSV',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddQuestionDialog,
          ),
        ],
      ),
      body: Obx(
        () => _questionController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : _questionController.questions.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.quiz_outlined,
                      size: ResponsiveUtils.responsiveIconSize(context, 80),
                      color: AppTheme.textSecondary,
                    ),
                    SizedBox(
                      height: ResponsiveUtils.responsiveSpacing(context, 16),
                    ),
                    Text(
                      'No questions yet',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          18,
                        ),
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveUtils.responsiveSpacing(context, 16),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showAddQuestionDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Question'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: ResponsiveUtils.responsivePadding(context),
                itemCount: _questionController.questions.length,
                itemBuilder: (context, index) {
                  final question = _questionController.questions[index];
                  return Card(
                    margin: EdgeInsets.only(
                      bottom: ResponsiveUtils.responsiveSpacing(context, 12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(
                        question.question,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        'Marks: ${question.marks} • Correct: ${question.correctAnswer}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditQuestionDialog(question),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: AppTheme.errorColor,
                            onPressed: () => _deleteQuestion(question),
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
