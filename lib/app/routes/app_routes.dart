import 'package:get/get.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/signup_screen.dart';
import '../../views/auth/forgot_password_screen.dart';
import '../../views/auth/admin_login_screen.dart';
import '../../views/auth/admin_signup_screen.dart';
import '../../views/auth/teacher_login_screen.dart';
import '../../views/auth/teacher_signup_screen.dart';
import '../../views/auth/pending_approval_screen.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/onboarding/onboarding_screen.dart';
import '../../views/student/student_home_screen.dart';
import '../../views/student/student_tests_screen.dart';
import '../../views/student/student_results_screen.dart';
import '../../views/student/student_profile_screen.dart';
import '../../views/student/edit_profile_screen.dart';
import '../../views/student/student_courses_screen.dart';
import '../../views/student/test_screen.dart';
import '../../views/student/leaderboard_screen.dart';
import '../../views/student/overall_marksheet_screen.dart';
import '../../views/teacher/teacher_dashboard_screen.dart';
import '../../views/teacher/teacher_tests_screen.dart';
import '../../views/teacher/teacher_students_screen.dart';
import '../../views/teacher/teacher_results_screen.dart';
import '../../views/teacher/teacher_profile_screen.dart';
import '../../views/teacher/teacher_courses_screen.dart';
import '../../views/teacher/create_test_screen.dart';
import '../../views/teacher/test_questions_screen.dart';
import '../../views/teacher/test_monitoring_screen.dart';
import '../../views/teacher/all_students_results_screen.dart';
import '../../views/admin/admin_dashboard_screen.dart';
import '../../views/admin/courses_management_screen.dart';
import '../../views/admin/classes_management_screen.dart';
import '../../views/admin/shifts_management_screen.dart';
import '../../views/admin/enrollment_approval_screen.dart';
import '../../views/admin/admin_student_results_screen.dart';
import '../../views/settings/settings_screen.dart';
import '../../views/settings/change_password_screen.dart';
import '../../views/help/help_screen.dart';
import '../../views/about/about_screen.dart';

part 'app_routes.g.dart';

class AppPages {
  static const INITIAL = '/splash';

  static final routes = [
    GetPage(name: '/splash', page: () => const SplashScreen()),
    GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
    GetPage(name: Routes.LOGIN, page: () => const LoginScreen()),
    GetPage(name: Routes.SIGNUP, page: () => const SignupScreen()),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordScreen(),
    ),
    GetPage(name: '/admin-login', page: () => const AdminLoginScreen()),
    GetPage(name: '/admin-signup', page: () => const AdminSignupScreen()),
    GetPage(name: '/teacher-login', page: () => const TeacherLoginScreen()),
    GetPage(name: '/teacher-signup', page: () => const TeacherSignupScreen()),
    GetPage(name: Routes.PENDING_APPROVAL, page: () => const PendingApprovalScreen()),
    GetPage(name: Routes.STUDENT_HOME, page: () => const StudentHomeScreen()),
    GetPage(name: '/student-courses', page: () => const StudentCoursesScreen()),
    GetPage(name: Routes.STUDENT_TESTS, page: () => const StudentTestsScreen()),
    GetPage(
      name: Routes.STUDENT_RESULTS,
      page: () => const StudentResultsScreen(),
    ),
    GetPage(
      name: Routes.STUDENT_PROFILE,
      page: () => const StudentProfileScreen(),
    ),
    GetPage(
      name: Routes.EDIT_PROFILE,
      page: () => const EditProfileScreen(),
    ),
    GetPage(
      name: Routes.CHANGE_PASSWORD,
      page: () => const ChangePasswordScreen(),
    ),
    GetPage(name: Routes.TEST_SCREEN, page: () => const TestScreen()),
    GetPage(name: '/leaderboard', page: () => const LeaderboardScreen()),
    GetPage(
      name: '/overall-marksheet',
      page: () => const OverallMarksheetScreen(),
    ),
    GetPage(
      name: Routes.TEACHER_DASHBOARD,
      page: () => const TeacherDashboardScreen(),
    ),
    GetPage(name: Routes.TEACHER_COURSES, page: () => const TeacherCoursesScreen()),
    GetPage(name: Routes.TEACHER_TESTS, page: () => const TeacherTestsScreen()),
    GetPage(
      name: Routes.TEACHER_STUDENTS,
      page: () => const TeacherStudentsScreen(),
    ),
    GetPage(
      name: Routes.TEACHER_RESULTS,
      page: () => const TeacherResultsScreen(),
    ),
    GetPage(
      name: Routes.ALL_STUDENTS_RESULTS,
      page: () => const AllStudentsResultsScreen(),
    ),
    GetPage(
      name: Routes.TEACHER_PROFILE,
      page: () => const TeacherProfileScreen(),
    ),
    GetPage(name: Routes.CREATE_TEST, page: () => const CreateTestScreen()),
    GetPage(
      name: Routes.TEST_QUESTIONS,
      page: () => const TestQuestionsScreen(),
    ),
    GetPage(name: '/test-monitoring', page: () => const TestMonitoringScreen()),
    GetPage(
      name: Routes.ADMIN_DASHBOARD,
      page: () => const AdminDashboardScreen(),
    ),
    GetPage(
      name: '/courses-management',
      page: () => const CoursesManagementScreen(),
    ),
    GetPage(
      name: '/classes-management',
      page: () => const ClassesManagementScreen(),
    ),
    GetPage(
      name: '/shifts-management',
      page: () => const ShiftsManagementScreen(),
    ),
    GetPage(
      name: '/enrollment-approval',
      page: () => const EnrollmentApprovalScreen(),
    ),
    GetPage(
      name: '/admin-student-results',
      page: () => const AdminStudentResultsScreen(),
    ),
    GetPage(name: '/settings', page: () => const SettingsScreen()),
    GetPage(name: '/help', page: () => const HelpScreen()),
    GetPage(name: '/about', page: () => const AboutScreen()),
  ];
}
