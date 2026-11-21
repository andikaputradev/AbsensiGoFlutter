import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:absensigo/services/NotificationServices.dart';
import '../../utils/showAlert.dart';

class SigninStudentController extends GetxController {
  final TextEditingController regNoController = TextEditingController(); // NIP atau Email
  final TextEditingController passwordController = TextEditingController();
  final RxBool obscureText = true.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _box = GetStorage();

  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  void _showLoading() {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  void _hideLoading() {
    if (Get.isDialogOpen ?? false) Get.back();
  }

  Future<void> login() async {
    final inputId = regNoController.text.trim();
    final password = passwordController.text.trim();

    if (inputId.isEmpty || password.isEmpty) {
      showAlert("Validasi", "Silakan masukkan NIP/Email dan Kata Sandi", Colors.orange);
      return;
    }

    _showLoading();

    try {
      String emailToAuth = inputId;

      // Jika user memasukkan NIP (bukan email), cari email-nya di Firestore
      if (!inputId.contains('@')) {
        final query = await _firestore
            .collection('students')
            .where('registrationNumber', isEqualTo: inputId)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          // Cek juga field nip
          final queryNip = await _firestore
              .collection('students')
              .where('nip', isEqualTo: inputId)
              .limit(1)
              .get();

          if (queryNip.docs.isEmpty) {
            _hideLoading();
            showAlert(
              "Akun Tidak Ditemukan",
              "Tidak ditemukan pegawai dengan NIP: $inputId",
              Colors.red,
            );
            return;
          }
          final data = queryNip.docs.first.data();
          emailToAuth = data['email'] ?? '';
          _savePegawaiSession(data);
        } else {
          final data = query.docs.first.data();
          emailToAuth = data['email'] ?? '';
          _savePegawaiSession(data);
        }
      }

      final cred = await _auth.signInWithEmailAndPassword(
        email: emailToAuth,
        password: password,
      );

      _box.write('role', 'student');
      _box.write('userId', cred.user?.uid ?? '');
      _box.write('email', emailToAuth);

      try {
        await NotificationService.initialize();
      } catch (_) {}

      _hideLoading();
      showAlert("Berhasil", "Selamat datang di AbsensiGo!", Colors.green);

      Future.delayed(const Duration(milliseconds: 500), () {
        Get.offAllNamed('/StudentNavigation');
      });
    } on FirebaseAuthException catch (e) {
      _hideLoading();
      String message = "Autentikasi gagal";
      if (e.code == 'user-not-found') {
        message = "Akun tidak terdaftar";
      } else if (e.code == 'wrong-password') {
        message = "Kata sandi yang dimasukkan salah";
      } else if (e.code == 'invalid-credential') {
        message = "NIP/Email atau kata sandi tidak valid";
      } else {
        message = e.message ?? message;
      }
      showAlert("Login Gagal", message, Colors.red);
    } catch (e) {
      _hideLoading();
      showAlert("Error", "Terjadi kesalahan: $e", Colors.red);
    }
  }

  void _savePegawaiSession(Map<String, dynamic> data) {
    if (data.containsKey('name')) _box.write('name', data['name']);
    if (data.containsKey('nip')) _box.write('nip', data['nip']);
    if (data.containsKey('registrationNumber')) _box.write('registrationNumber', data['registrationNumber']);
    if (data.containsKey('department')) _box.write('department', data['department']);
    if (data.containsKey('position')) _box.write('position', data['position']);
  }

  Future<void> forgotPassword() async {
    final inputId = regNoController.text.trim();

    if (inputId.isEmpty) {
      showAlert(
        "Lupa Kata Sandi",
        "Masukkan NIP atau Email Anda terlebih dahulu",
        Colors.orange,
      );
      return;
    }

    _showLoading();
    try {
      String emailToSend = inputId;
      if (!inputId.contains('@')) {
        final query = await _firestore
            .collection('students')
            .where('registrationNumber', isEqualTo: inputId)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          _hideLoading();
          showAlert("Error", "Pegawai dengan NIP $inputId tidak ditemukan", Colors.red);
          return;
        }
        emailToSend = query.docs.first['email'];
      }

      await _auth.sendPasswordResetEmail(email: emailToSend);
      _hideLoading();
      showAlert("Email Terkirim", "Tautan reset kata sandi telah dikirim ke $emailToSend", Colors.green);
    } catch (e) {
      _hideLoading();
      showAlert("Gagal", "Gagal mengirim email reset: $e", Colors.red);
    }
  }

  @override
  void onClose() {
    regNoController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
