import 'package:get/get.dart';
import 'package:absensigo/controllers/Lecture/GenerateQrControler.dart';
import 'package:absensigo/controllers/Lecture/LectureAttendanceControler.dart';
import 'package:absensigo/controllers/Lecture/NavigationControler.dart';
import 'package:absensigo/controllers/Lecture/SaveShareController.dart';
import 'package:absensigo/controllers/Lecture/ScheduleController.dart';
import 'package:absensigo/controllers/Lecture/StudentListControllers.dart';

class LectureNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LecturenavController>(() => LecturenavController());
  }
}

class LectureAttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LectureAttendanceController>(
      () => LectureAttendanceController(),
    );
  }
}

class LectureGenerateQrBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GenerateQrController>(() => GenerateQrController());
  }
}

class LectureSaveShareBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SaveShareController>(() => SaveShareController());
  }
}

class LectureSheduleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LectureScheduleController>(() => LectureScheduleController());
  }
}

class LectureStudentListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentListController>(() => StudentListController());
  }
}
