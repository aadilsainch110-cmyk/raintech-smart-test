import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'controllers/course_controller.dart';
import 'controllers/test_controller.dart';
import 'controllers/question_controller.dart';
import 'controllers/student_controller.dart';
import 'controllers/teacher_controller.dart';
import 'controllers/admin_controller.dart';
import 'controllers/result_controller.dart';
import 'controllers/enrollment_controller.dart';
import 'controllers/exam_controller.dart';
import 'controllers/attempt_controller.dart';
import 'services/data_init_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize default data
  final dataInitService = DataInitService();
  await dataInitService.initializeDefaultData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    Get.put(AuthController());
    Get.put(CourseController());
    Get.put(TestController());
    Get.put(QuestionController());
    Get.put(StudentController());
    Get.put(TeacherController());
    Get.put(AdminController());
    Get.put(ResultController());
    Get.put(EnrollmentController());
    Get.put(ExamController());
    Get.put(AttemptController());

    return GetMaterialApp(
      title: 'RainTech Smart Test',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
