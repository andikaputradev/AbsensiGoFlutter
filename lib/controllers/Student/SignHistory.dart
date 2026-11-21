import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/SignHistory.dart';
import 'package:intl/intl.dart';

class SignHistoryController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String studentId = FirebaseAuth.instance.currentUser?.uid ?? '';

  var signHistoryList = <SignHistoryModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSignHistory();
  }

  Future<void> fetchSignHistory() async {
    isLoading.value = true;
    signHistoryList.clear();

    try {
      List<SignHistoryModel> history = [];

      // Fetch from attendances collection in Firestore (Presensi Masuk & Pulang)
      try {
        final attendancesQuery = await firestore
            .collection('attendances')
            .where('userId', isEqualTo: studentId)
            .get();

        for (var doc in attendancesQuery.docs) {
          final d = doc.data();
          final type = d['type'] ?? d['status'] ?? 'PRESENSI';
          final date = d['date'] ?? '';
          final time = d['time'] ?? '';
          final lat = (d['latitude'] ?? d['lat'] ?? 0.0) as num;
          final lng = (d['longitude'] ?? d['lang'] ?? 0.0) as num;
          final coordStr =
              (lat != 0.0 || lng != 0.0)
                  ? " [Lat: ${lat.toStringAsFixed(4)}, Lang: ${lng.toStringAsFixed(4)}]"
                  : "";

          history.add(
            SignHistoryModel(
              moduleCode: "PRESENSI $type$coordStr",
              timeSigned: "$date $time WIB",
              status: type == 'MASUK' ? "Masuk" : "Pulang",
            ),
          );
        }
      } catch (e) {
        debugPrint("Error fetching attendances in history: $e");
      }

      // Get student document for QR module attendance
      final studentDoc =
          await firestore.collection('students').doc(studentId).get();
      if (studentDoc.exists) {
        final String courseName = studentDoc['course'] ?? '';
        final courseQuery =
            await firestore
                .collection('courses')
                .where('name', isEqualTo: courseName)
                .get();
        if (courseQuery.docs.isNotEmpty) {
          final courseDoc = courseQuery.docs.first;
          final courseId = courseDoc.id;

          final modulesQuery =
              await firestore
                  .collection('courses')
                  .doc(courseId)
                  .collection('modules')
                  .get();

          for (var moduleDoc in modulesQuery.docs) {
            final moduleId = moduleDoc.id;
            final moduleCode = moduleDoc['code'] ?? '';

            final attendanceDocs =
                await firestore
                    .collection('courses')
                    .doc(courseId)
                    .collection('modules')
                    .doc(moduleId)
                    .collection('attendance')
                    .get();

            for (var attDoc in attendanceDocs.docs) {
              final data = attDoc.data();
              final studentsMap = data['students'] ?? {};
              if (studentsMap.containsKey(studentId)) {
                final studentAttendance = studentsMap[studentId];
                Timestamp? lastUpdatedTimestamp =
                    studentAttendance['lastUpdated'];

                String timeSigned = "Unknown";
                String dateSigned = attDoc.id.replaceFirst('att_', '');
                try {
                  DateTime date = DateTime.parse(
                    '${dateSigned.substring(0, 4)}-${dateSigned.substring(4, 6)}-${dateSigned.substring(6, 8)}',
                  );
                  dateSigned = DateFormat('yyyy-MM-dd').format(date);
                } catch (_) {}

                if (lastUpdatedTimestamp != null) {
                  timeSigned = DateFormat(
                    'hh:mm a',
                  ).format(lastUpdatedTimestamp.toDate());
                }

                history.add(
                  SignHistoryModel(
                    moduleCode: moduleCode,
                    timeSigned: "$dateSigned at $timeSigned",
                    status: "Signed",
                  ),
                );
              }
            }
          }
        }
      }

      // Sort by date & time descending
      history.sort((a, b) => b.timeSigned.compareTo(a.timeSigned));

      signHistoryList.assignAll(history);
    } catch (e) {
      debugPrint('Error fetching history: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
