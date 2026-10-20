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
  final List<Map<String, TextEditingController>> _questionControllers = [];
  final List<GlobalKey<FormState>> _formKeys = [];
  bool _isUploadingCSV = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _isUploadingCSV = false;
    for (final controllers in _questionControllers) {
      for (final controller in controllers.values) {
        controller.dispose();
      }
    }
    _questionControllers.clear();
    _formKeys.clear();
    super.dispose();
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

  Future<void> _showBulkAddQuestionsDialog() async {
    _questionControllers.clear();
    _formKeys.clear();

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Add Multiple Questions'),
        content: SizedBox(
          width: ResponsiveUtils.responsiveSpacing(context, 600),
          height: ResponsiveUtils.responsiveSpacing(context, 500),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _questionControllers.length,
                      itemBuilder: (context, index) {
                        final controllers = _questionControllers[index];
                        final formKey = _formKeys[index];

                        return Card(
                          margin: EdgeInsets.only(
                            bottom: ResponsiveUtils.responsiveSpacing(context, 12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(
                              ResponsiveUtils.responsiveSpacing(context, 12),
                            ),
                            child: Form(
                              key: formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Question ${index + 1}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            _questionControllers.removeAt(index);
                                            _formKeys.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: ResponsiveUtils.responsiveSpacing(context, 8),
                                  ),
                                  TextFormField(
                                    controller: controllers['question']!,
                                    decoration: const InputDecoration(
                                      labelText: 'Question',
                                      border: OutlineInputBorder(),
                                    ),
                                    maxLines: 2,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: ResponsiveUtils.responsiveSpacing(context, 8),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: controllers['optionA']!,
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
                                      ),
                                      SizedBox(
                                        width: ResponsiveUtils.responsiveSpacing(context, 8),
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          controller: controllers['optionB']!,
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
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: ResponsiveUtils.responsiveSpacing(context, 8),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: controllers['optionC']!,
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
                                      ),
                                      SizedBox(
                                        width: ResponsiveUtils.responsiveSpacing(context, 8),
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          controller: controllers['optionD']!,
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
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: ResponsiveUtils.responsiveSpacing(context, 8),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: controllers['correctAnswer']!,
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
                                            if (!['A', 'B', 'C', 'D'].contains(value.trim().toUpperCase())) {
                                              return 'Must be A, B, C, or D';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: ResponsiveUtils.responsiveSpacing(context, 8),
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          controller: controllers['marks']!,
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
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _questionControllers.add({
                          'question': TextEditingController(),
                          'optionA': TextEditingController(),
                          'optionB': TextEditingController(),
                          'optionC': TextEditingController(),
                          'optionD': TextEditingController(),
                          'correctAnswer': TextEditingController(),
                          'marks': TextEditingController(text: '1'),
                        });
                        _formKeys.add(GlobalKey<FormState>());
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Question'),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_questionControllers.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please add at least one question',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.errorColor,
                  colorText: Colors.white,
                );
                return;
              }

              bool allValid = true;
              for (final formKey in _formKeys) {
                if (!formKey.currentState!.validate()) {
                  allValid = false;
                }
              }

              if (allValid) {
                Get.back(result: true);
              }
            },
            child: const Text('Add All Questions'),
          ),
        ],
      ),
    );

    if (result == true) {
      final questionsData = _questionControllers.map((controllers) {
        return {
          'question': controllers['question']!.text.trim(),
          'optionA': controllers['optionA']!.text.trim(),
          'optionB': controllers['optionB']!.text.trim(),
          'optionC': controllers['optionC']!.text.trim(),
          'optionD': controllers['optionD']!.text.trim(),
          'correctAnswer': controllers['correctAnswer']!.text.trim().toUpperCase(),
          'marks': int.parse(controllers['marks']!.text),
        };
      }).toList();

      final success = await _questionController.addMultipleQuestions(
        testId: _test!.id!,
        questionsData: questionsData,
      );

      if (success) {
        await _loadData();
        Get.snackbar(
          'Success',
          'Questions Added',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.successColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to add questions. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.errorColor,
          colorText: Colors.white,
        );
      }
    }

    for (final controllers in _questionControllers) {
      for (final controller in controllers.values) {
        controller.dispose();
      }
    }
    _questionControllers.clear();
    _formKeys.clear();
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
    // Prevent multiple simultaneous uploads
    if (_isUploadingCSV) {
      Get.snackbar(
        'Upload in Progress',
        'Please wait for the current upload to complete.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
      return;
    }

    print('DEBUG: _importQuestionsFromCSV called');
    try {
      print('DEBUG: Opening file picker');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        String csvData;

        // Handle web (bytes) vs desktop/mobile (path)
        if (file.bytes != null) {
          // Web platform - use bytes directly
          print('DEBUG: Using bytes (web platform)');
          csvData = String.fromCharCodes(file.bytes!);
        } else if (file.path != null) {
          // Desktop/mobile platform - read from file path
          print('DEBUG: Using path (desktop/mobile): ${file.path}');
          final fileObj = File(file.path!);
          final bytes = await fileObj.readAsBytes();
          csvData = String.fromCharCodes(bytes);
        } else {
          throw Exception('Unable to read file - no path or bytes available');
        }

        print('DEBUG: CSV data read, length: ${csvData.length}');

        final rows = const CsvToListConverter().convert(csvData);
        print('DEBUG: CSV parsed, rows: ${rows.length}');

        if (rows.isEmpty) {
          throw Exception('CSV file is empty or could not be parsed');
        }

        // Skip header row if present
        final startIndex =
            rows[0][0].toString().toLowerCase().contains('question') ? 1 : 0;
        print('DEBUG: Start index (skipping header): $startIndex');

        if (startIndex >= rows.length) {
          throw Exception('CSV file has no data rows (only header)');
        }

        // VALIDATE ALL QUESTIONS FIRST (no loading during validation)
        print('DEBUG: Validating all questions...');
        final List<Map<String, dynamic>> validQuestions = [];
        final List<String> errors = [];

        for (int i = startIndex; i < rows.length; i++) {
          final row = rows[i];

          if (row.length >= 6) {
            // Validate row data
            final question = row[0]?.toString().trim() ?? '';
            final optionA = row[1]?.toString().trim() ?? '';
            final optionB = row[2]?.toString().trim() ?? '';
            final optionC = row[3]?.toString().trim() ?? '';
            final optionD = row[4]?.toString().trim() ?? '';
            final correctAnswer = row[5]?.toString().trim().toUpperCase() ?? '';
            final marks = row.length > 6 ? int.tryParse(row[6].toString()) ?? 1 : 1;

            if (question.isEmpty) {
              errors.add('Row ${i + 1}: Question is empty');
              continue;
            }

            if (optionA.isEmpty || optionB.isEmpty || optionC.isEmpty || optionD.isEmpty) {
              errors.add('Row ${i + 1}: All options are required');
              continue;
            }

            if (!['A', 'B', 'C', 'D'].contains(correctAnswer)) {
              errors.add('Row ${i + 1}: Invalid correct answer "$correctAnswer" (must be A, B, C, or D)');
              continue;
            }

            // Add to valid questions list
            validQuestions.add({
              'question': question,
              'optionA': optionA,
              'optionB': optionB,
              'optionC': optionC,
              'optionD': optionD,
              'correctAnswer': correctAnswer,
              'marks': marks,
            });
          } else {
            errors.add('Row ${i + 1}: Not enough columns (got ${row.length}, need 6)');
          }
        }

        print('DEBUG: Validation complete. Valid questions: ${validQuestions.length}, Errors: ${errors.length}');

        if (validQuestions.isEmpty) {
          throw Exception('No valid questions found in CSV. Errors: ${errors.take(3).join("; ")}${errors.length > 3 ? "..." : ""}');
        }

        // NOW SHOW LOADING AND UPLOAD IN BATCH
        setState(() {
          _isUploadingCSV = true;
        });

        print('DEBUG: Starting batch upload of ${validQuestions.length} questions');
        final success = await _questionController.addMultipleQuestions(
          testId: _test!.id!,
          questionsData: validQuestions,
        );

        print('DEBUG: Batch upload completed. Success: $success');

        setState(() {
          _isUploadingCSV = false;
        });

        // Refresh question list only once after batch upload
        await _loadData();

        if (success) {
          Get.snackbar(
            'Import Complete',
            '${validQuestions.length} questions uploaded successfully.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.successColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );

          if (errors.isNotEmpty) {
            // Show skipped questions warning
            Future.delayed(const Duration(seconds: 1), () {
              Get.snackbar(
                'Some Rows Skipped',
                '${errors.length} row(s) were skipped. ${errors.take(2).join("; ")}${errors.length > 2 ? "..." : ""}',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
                duration: const Duration(seconds: 4),
              );
            });
          }
        } else {
          Get.snackbar(
            'Import Failed',
            'Failed to upload questions. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.errorColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
        }
      }
    } catch (e) {
      print('DEBUG: Exception: $e');
      setState(() {
        _isUploadingCSV = false;
      });
      Get.snackbar(
        'Import Failed',
        'Error: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(_test?.title ?? 'Test Questions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _isUploadingCSV ? null : _importQuestionsFromCSV,
            tooltip: 'Import from CSV',
          ),
          IconButton(
            icon: const Icon(Icons.playlist_add),
            onPressed: _isUploadingCSV ? null : _showBulkAddQuestionsDialog,
            tooltip: 'Add Multiple Questions',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _isUploadingCSV ? null : _showAddQuestionDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          Obx(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isUploadingCSV ? null : _showAddQuestionDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Question'),
                            ),
                            SizedBox(
                              width: ResponsiveUtils.responsiveSpacing(context, 16),
                            ),
                            ElevatedButton.icon(
                              onPressed: _isUploadingCSV ? null : _showBulkAddQuestionsDialog,
                              icon: const Icon(Icons.playlist_add),
                              label: const Text('Add Multiple'),
                            ),
                          ],
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
                                onPressed: _isUploadingCSV ? null : () => _showEditQuestionDialog(question),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: AppTheme.errorColor,
                                onPressed: _isUploadingCSV ? null : () => _deleteQuestion(question),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // CSV upload loading overlay
          if (_isUploadingCSV)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Uploading questions...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
