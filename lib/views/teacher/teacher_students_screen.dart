import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/student_controller.dart';
import '../../app/theme/app_theme.dart';
import '../../app/responsive/responsive_utils.dart';

class TeacherStudentsScreen extends StatefulWidget {
  const TeacherStudentsScreen({super.key});

  @override
  State<TeacherStudentsScreen> createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends State<TeacherStudentsScreen> {
  final StudentController _studentController = Get.put(StudentController());
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _studentController.fetchActiveStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUtils.responsiveSpacing(context, 16)),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.responsiveBorderRadius(context, 8),
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ),
      ),
      body: Obx(
        () => _studentController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : _studentController.students.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: ResponsiveUtils.responsiveIconSize(context, 80),
                          color: AppTheme.textSecondary,
                        ),
                        SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
                        Text(
                          'No students found',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: ResponsiveUtils.responsivePadding(context),
                    itemCount: _studentController.students.length,
                    itemBuilder: (context, index) {
                      final student = _studentController.students[index];
                      final searchQuery = _searchController.text.toLowerCase();
                      
                      if (searchQuery.isNotEmpty &&
                          !student.name.toLowerCase().contains(searchQuery) &&
                          !student.email.toLowerCase().contains(searchQuery) &&
                          !(student.studentId?.toLowerCase().contains(searchQuery) ?? false)) {
                        return const SizedBox.shrink();
                      }

                      return Card(
                        margin: EdgeInsets.only(
                          bottom: ResponsiveUtils.responsiveSpacing(context, 12),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.responsiveBorderRadius(context, 12),
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor,
                            radius: ResponsiveUtils.responsiveSpacing(context, 24),
                            child: Text(
                              student.name[0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
                              ),
                            ),
                          ),
                          title: Text(
                            student.name,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.email,
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                                ),
                              ),
                              if (student.studentId != null)
                                Text(
                                  'ID: ${student.studentId}',
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                                  ),
                                ),
                            ],
                          ),
                          trailing: Chip(
                            label: Text(
                              student.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.responsiveFontSize(context, 12),
                              ),
                            ),
                            backgroundColor: student.isActive
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                            labelStyle: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
