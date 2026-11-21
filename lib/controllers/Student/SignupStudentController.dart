import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:absensigo/services/NotificationServices.dart';
import '../../models/SignupStudentModel.dart';
import '../../utils/showAlert.dart';

class SignupStudentController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Identitas Kepegawaian & Akun
  final registrationNumber = TextEditingController(); // NIP
  final name = TextEditingController(); // Nama Lengkap Pegawai
  final email = TextEditingController(); // Email Pegawai
  final password = TextEditingController(); // Kata Sandi
  final confirmPassword = TextEditingController();

  var selectedCourse = ''.obs; // Divisi / Departemen
  var selectedYear = ''.obs; // Jabatan / Posisi

  // Unit Kerja & Peran Pegawai sesuai spesifikasi MagangHub FSP
  final List<String> defaultDivisions = const [
    'Mobile Engineering',
    'Full Stack Web',
    'Cyber Security',
    'UI/UX Design',
    'Operasional',
  ];

  final List<String> defaultPositions = const [
    'Mobile Programmer',
    'Backend Engineer',
    'System Analyst',
    'Staff',
  ];

  var courses = <String>[].obs; // Divisi / Departemen
  var years = <String>[].obs; // Jabatan / Posisi

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi daftar divisi dan jabatan default
    courses.assignAll(defaultDivisions);
    years.assignAll(defaultPositions);

    fetchCourses();
    ever(selectedCourse, (_) {
      fetchYearsForCourse();
    });
  }

  void fetchCourses() {
    _firestore.collection('courses').snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs.map((doc) => doc['name'] as String).toList();
        for (var item in list) {
          if (!courses.contains(item)) {
            courses.add(item);
          }
        }
      }
    }, onError: (_) {
      // Pertahankan list divisi default jika firestore offline/belum ada koleksi
      courses.assignAll(defaultDivisions);
    });
  }

  Future<void> fetchYearsForCourse() async {
    if (selectedCourse.value.isEmpty) return;

    try {
      final query = await _firestore
          .collection('courses')
          .where('name', isEqualTo: selectedCourse.value)
          .get();

      if (query.docs.isNotEmpty && query.docs.first.data().containsKey('year')) {
        final year = query.docs.first['year'];
        final parsed = _parseYearRange(year);
        if (parsed.isNotEmpty) {
          years.assignAll(parsed);
          return;
        }
      }
    } catch (_) {}

    // Tetap gunakan daftar jabatan pegawai
    years.assignAll(defaultPositions);
  }

  List<String> _parseYearRange(String yearString) {
    final match = RegExp(r'Year (\d+)').firstMatch(yearString);
    if (match != null) {
      final maxYear = int.parse(match.group(1)!);
      return List.generate(maxYear, (i) => 'Year ${i + 1}');
    }
    return [];
  }

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;
  void toggleConfirmPasswordVisibility() =>
      obscureConfirmPassword.value = !obscureConfirmPassword.value;

  void _showLoading() {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  void _hideLoading() {
    if (Get.isDialogOpen ?? false) Get.back();
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    final regNo = registrationNumber.text.trim();
    final emailText = email.text.trim();
    final passwordText = password.text.trim();

    if (passwordText.length < 6) {
      showAlert("Validasi Gagal", "Kata sandi minimal 6 karakter sesuai standar Firebase Auth", Colors.orange);
      return;
    }

    _showLoading();

    try {
      // Validasi keberadaan NIP atau Email di Firestore
      final existing = await _firestore
          .collection('students')
          .where('registrationNumber', isEqualTo: regNo)
          .get();

      final emailExists = await _firestore
          .collection('students')
          .where('email', isEqualTo: emailText)
          .get();

      if (existing.docs.isNotEmpty) {
        _hideLoading();
        showAlert("Error", "Nomor Induk Pegawai (NIP) sudah terdaftar", Colors.red);
        return;
      }

      if (emailExists.docs.isNotEmpty) {
        _hideLoading();
        showAlert("Error", "Email Pegawai sudah terdaftar", Colors.red);
        return;
      }

      // Registrasi akun ke Firebase Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailText,
        password: passwordText,
      );

      final student = StudentModel(
        registrationNumber: regNo,
        name: name.text.trim(),
        email: emailText,
        course: selectedCourse.value,
        year: selectedYear.value,
      );

      // Simpan data pegawai ke Firestore
      final Map<String, dynamic> employeeMap = student.toMap();
      employeeMap['nip'] = regNo;
      employeeMap['department'] = selectedCourse.value;
      employeeMap['position'] = selectedYear.value;
      employeeMap['role'] = 'pegawai';
      employeeMap['createdAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('students')
          .doc(userCredential.user!.uid)
          .set(employeeMap);

      // Simpan juga di koleksi employees untuk fleksibilitas query
      await _firestore
          .collection('employees')
          .doc(userCredential.user!.uid)
          .set(employeeMap);

      final box = GetStorage();
      box.write('role', 'student');
      box.write('nip', regNo);
      box.write('registrationNumber', regNo);
      box.write('name', name.text.trim());
      box.write('email', emailText);
      box.write('department', selectedCourse.value);
      box.write('position', selectedYear.value);

      try {
        await NotificationService.initialize();
      } catch (_) {}

      _hideLoading();
      showAlert("Berhasil", "Registrasi Pegawai atas nama ${student.name} berhasil disimpan!", Colors.green);

      Get.offAllNamed('/StudentNavigation');
    } on FirebaseAuthException catch (e) {
      _hideLoading();
      showAlert("Auth Error", e.message ?? "Terjadi kesalahan autentikasi", Colors.red);
    } catch (e) {
      _hideLoading();
      showAlert("Error", "Gagal menyimpan data pegawai: $e", Colors.red);
    }
  }

  @override
  void onClose() {
    registrationNumber.dispose();
    name.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.onClose();
  }
}
