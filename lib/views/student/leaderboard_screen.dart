import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/result_controller.dart';
import '../../controllers/test_controller.dart';
import '../../controllers/student_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../app/theme/app_theme.dart' as theme;
import '../../app/responsive/responsive_utils.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final ResultController _resultController = Get.put(ResultController());
  final TestController _testController = Get.put(TestController());
  final StudentController _studentController = Get.put(StudentController());
  final AuthController _authController = Get.find<AuthController>();

  bool _showOverallLeaderboard = false;
  final RxList<Map<String, dynamic>> _overallLeaderboard = <Map<String, dynamic>>[].obs;
  final RxBool _isLoadingOverall = false.obs;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _testController.fetchAllTests(),
      _studentController.fetchAllStudents(),
    ]);
  }

  Future<void> _loadOverallLeaderboard() async {
    _isLoadingOverall.value = true;
    final data = await _resultController.calculateOverallLeaderboard();
    _overallLeaderboard.value = (data['leaderboard'] as List<Map<String, dynamic>>);
    _isLoadingOverall.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Leaderboard'),
        actions: [
          IconButton(
            icon: Icon(_showOverallLeaderboard ? Icons.quiz : Icons.emoji_events),
            onPressed: () {
              setState(() {
                _showOverallLeaderboard = !_showOverallLeaderboard;
                if (_showOverallLeaderboard) {
                  _loadOverallLeaderboard();
                }
              });
            },
            tooltip: _showOverallLeaderboard ? 'View by Test' : 'View Overall',
          ),
        ],
      ),
      body: _showOverallLeaderboard
          ? _buildOverallLeaderboard()
          : _buildTestList(),
    );
  }

  Widget _buildOverallLeaderboard() {
    return Obx(
      () => _isLoadingOverall.value
          ? const Center(child: CircularProgressIndicator())
          : _overallLeaderboard.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 80,
                        color: theme.AppTheme.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No results yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: theme.AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _overallLeaderboard.length,
                  itemBuilder: (context, index) {
                    final entry = _overallLeaderboard[index];
                    final student = _studentController.students
                        .where((s) => s.id == entry['studentId'])
                        .firstOrNull;
                    final isCurrentUser = student?.id == _authController.currentUser?.id;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: isCurrentUser
                          ? theme.AppTheme.primaryColor.withValues(alpha: 0.1)
                          : null,
                      child: ListTile(
                        leading: _buildPositionBadge(entry['position']),
                        title: Text(student?.name ?? 'Unknown Student'),
                        subtitle: Text(
                          'Tests: ${entry['totalTests']} • Passed: ${entry['passedTests']}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${entry['averagePercentage'].toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: theme.AppTheme.primaryColor,
                              ),
                            ),
                            Text(
                              '${entry['obtainedMarks']}/${entry['totalMarks']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildTestList() {
    return Obx(
      () => _testController.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : _testController.tests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
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
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _testController.tests.length,
                  itemBuilder: (context, index) {
                    final test = _testController.tests[index];
                    if (!test.resultsReleased) {
                      return const SizedBox.shrink();
                    }
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text(test.title),
                        subtitle: Text(
                          '${test.questionCount} Questions • ${test.totalMarks} Marks',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _showTestLeaderboard(test),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _showTestLeaderboard(dynamic test) async {
    await _resultController.fetchTestResults(testId: test.id!);

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${test.title} - Leaderboard',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: Obx(
            () => _resultController.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : _resultController.results.isEmpty
                    ? const Center(child: Text('No results yet'))
                    : ListView.builder(
                        itemCount: _resultController.results.length,
                        itemBuilder: (context, index) {
                          final result = _resultController.results[index];
                          final student = _studentController.students
                              .where((s) => s.id == result.studentId)
                              .firstOrNull;
                          final isCurrentUser = student?.id == _authController.currentUser?.id;
                          final position = result.position ?? (index + 1);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: isCurrentUser
                                ? theme.AppTheme.primaryColor.withValues(alpha: 0.1)
                                : null,
                            elevation: isCurrentUser ? 4 : 1,
                            child: ListTile(
                              leading: _buildPositionBadge(position),
                              title: Text(
                                student?.name ?? 'Unknown Student',
                                style: TextStyle(
                                  fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${result.obtainedMarks}/${result.totalMarks} (${result.percentage.toStringAsFixed(1)}%)',
                                  ),
                                  Text(
                                    'Correct: ${result.correctAnswers} • Wrong: ${result.wrongAnswers}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$position${_getOrdinalSuffix(position)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.AppTheme.primaryColor,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Chip(
                                    label: Text(result.status),
                                    backgroundColor: result.status == 'PASS'
                                        ? theme.AppTheme.successColor
                                        : theme.AppTheme.errorColor,
                                    labelStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionBadge(int position) {
    Color color;
    IconData icon;

    switch (position) {
      case 1:
        color = Colors.amber;
        icon = Icons.emoji_events;
        break;
      case 2:
        color = Colors.grey;
        icon = Icons.military_tech;
        break;
      case 3:
        color = Colors.brown;
        icon = Icons.military_tech;
        break;
      default:
        color = theme.AppTheme.primaryColor;
        icon = Icons.person;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
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
}