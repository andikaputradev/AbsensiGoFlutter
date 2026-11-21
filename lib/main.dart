import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:absensigo/bindings/LectureBindings.dart';
import 'package:absensigo/bindings/SharedBindings.dart';
import 'package:absensigo/bindings/StudentBindings.dart';
import 'package:absensigo/config/theme.dart';

import 'package:absensigo/controllers/Shared/UserSessionController.dart';
import 'package:absensigo/controllers/Shared/ThemeController.dart'; //
import 'package:absensigo/firebase_options.dart';
import 'package:absensigo/views/lecturers/announcementHistory.dart';
import 'package:absensigo/views/shared/PrivacyPolicy.dart';
import 'package:absensigo/views/shared/TermsConidtion.dart';

// Shared Views
import 'package:absensigo/views/shared/Welcome.dart';
import 'package:absensigo/views/shared/Role.dart';
import 'package:absensigo/views/shared/Settings.dart';
import 'package:absensigo/views/shared/attendance.dart';
import 'package:absensigo/views/shared/Notifications.dart';
import 'package:absensigo/views/shared/About.dart';
import 'package:absensigo/views/shared/PresensiPage.dart';

// Student Views
import 'package:absensigo/views/students/Dashboard.dart';
import 'package:absensigo/views/students/Module.dart';
import 'package:absensigo/views/students/Navigation.dart';
import 'package:absensigo/views/students/Profile.dart';
import 'package:absensigo/views/students/Scanqr.dart';
import 'package:absensigo/views/students/Schedule.dart';
import 'package:absensigo/views/students/SignHistory.dart';
import 'package:absensigo/views/students/SigninStudent.dart';
import 'package:absensigo/views/students/SignupStudent.dart';

// Lecture Views
import 'package:absensigo/views/lecturers/Dashboard.dart';
import 'package:absensigo/views/lecturers/Announcement.dart';
import 'package:absensigo/views/lecturers/GenerateQr.dart';
import 'package:absensigo/views/lecturers/Profile.dart';
import 'package:absensigo/views/lecturers/SigninLecture.dart';
import 'package:absensigo/views/lecturers/SignupLecture.dart';
import 'package:absensigo/views/lecturers/StudentList.dart';
import 'package:absensigo/views/lecturers/attendance.dart';
import 'package:absensigo/views/lecturers/navigation.dart';
import 'package:absensigo/views/lecturers/schedule.dart';

//Background initialization in push notification
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('📥 Background message received: ${message.messageId}');
}

//implement global navigation for ontap pushNotification behaviour

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //init firebaseService
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();
  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  Get.put(UserSessionController());
  Get.put(ThemeController()); // ✅ Inject ThemeController
  // Auth and role check
  final box = GetStorage();
  final user = FirebaseAuth.instance.currentUser;
  final role = box.read('role');
  String initialRoute = '/';
  if (user != null && role != null) {
    if (role == 'student') {
      initialRoute = '/StudentNavigation';
    } else if (role == 'lecture') {
      initialRoute = '/LectureNavigation';
    }
  }

  runApp(MyApp(initialRoute: initialRoute)); //
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>(); // Get theme controller

    return Obx(
      () => GetMaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        initialRoute: initialRoute, // ← Dynamic
        theme: lightmode,
        darkTheme: darkmode, // Optional: customize your dark theme here
        themeMode:
            themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        getPages: [
          // Shared
          GetPage(name: '/', page: () => WelcomePage()),
          GetPage(name: '/Presensi', page: () => const PresensiPage()),
          GetPage(name: '/Settings', page: () => Settings()),
          GetPage(name: '/Notification', page: () => Notifications()),
          GetPage(name: '/About', page: () => AboutAppPage()),
          GetPage(name: '/PrivacyPolicy', page: () => PrivacyPolicy()),
          GetPage(name: '/TermsConditions', page: () => TermsCondition()),
          GetPage(
            name: '/Role',
            page: () => Role(),
            binding: RoleBinding(),
            transition: Transition.cupertino,
          ),

          // Students
          GetPage(name: '/StudentDashboard', page: () => StudentDashboard()),
          GetPage(name: '/StudentNavigation', page: () => StudentNavigation()),
          GetPage(name: '/Signin_student', page: () => SigninStudent()),
          GetPage(name: '/Signup_student', page: () => SignupStudent()),
          GetPage(name: '/Student_Profile', page: () => ProfileStudent()),
          GetPage(
            name: '/Modules',
            page: () => Modules(),
            binding: ModuleBinding(),
          ),
          GetPage(
            name: '/StudentSchedule',
            page: () => StudentSchedule(),
            binding: StudentScheduleBinding(),
          ),
          GetPage(
            name: '/SignHistory',
            page: () => SignHistory(),
            transition: Transition.cupertino,
            binding: SignHistoryBinding(),
          ),
          GetPage(
            name: '/StudentAttendance',
            page: () => StudentAttendance(),
            binding: StudentAttendanceBinding(),
          ),
          GetPage(
            name: '/Scanqr',
            page: () => Scanqr(),
            binding: ScanqrBinding(),
          ),

          // Lectures
          GetPage(name: '/LectureDashboard', page: () => LectureDashboard()),
          GetPage(name: '/LectureNavigation', page: () => LectureNavigation()),
          GetPage(name: '/Signin_lecture', page: () => SigninLecture()),
          GetPage(name: '/Signup_lecture', page: () => SignupLecture()),
          GetPage(name: '/Lecture_Profile', page: () => ProfileLecture()),
          GetPage(name: '/GenerateQr', page: () => GenerateQr()),
          GetPage(name: '/Announcement', page: () => Announcement()),
          GetPage(
            name: '/AnnouncementHistory',
            page: () => Announcementhistory(),
          ),
          GetPage(
            name: '/StudentList',
            page: () => StudentList(),
            binding: LectureStudentListBinding(),
          ),
          GetPage(
            name: '/LectureAttendance',
            page: () => LectureAttendance(),
            binding: LectureAttendanceBinding(),
          ),
          GetPage(
            name: '/LectureSchedule',
            page: () => LectureSchedule(),
            binding: LectureSheduleBinding(),
          ),
        ],
      ),
    );
  }
}
