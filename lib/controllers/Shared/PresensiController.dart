import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class PresensiController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GetStorage storage = GetStorage();

  var currentTime = ''.obs;
  var currentDate = ''.obs;
  var isClockedIn = false.obs;
  var isClockedOut = false.obs;
  var clockInTime = '-'.obs;
  var clockOutTime = '-'.obs;
  var lastLatitude = 0.0.obs;
  var lastLongitude = 0.0.obs;
  var hasLocation = false.obs;
  var isLoading = false.obs;
  var attendanceHistory = <Map<String, dynamic>>[].obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startClock();
    _loadLocalState();
    loadTodayAttendance();
    fetchAttendanceHistory();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _startClock() {
    _updateDateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateDateTime());
  }

  void _updateDateTime() {
    final now = DateTime.now();
    currentTime.value = DateFormat('HH:mm:ss').format(now);
    currentDate.value = DateFormat('EEEE, d MMMM yyyy').format(now);
  }

  String _todayDateStr() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  void _loadLocalState() {
    final today = _todayDateStr();
    final savedDate = storage.read('presensi_date');
    if (savedDate == today) {
      isClockedIn.value = storage.read('presensi_isClockedIn') ?? false;
      isClockedOut.value = storage.read('presensi_isClockedOut') ?? false;
      clockInTime.value = storage.read('presensi_clockInTime') ?? '-';
      clockOutTime.value = storage.read('presensi_clockOutTime') ?? '-';
      lastLatitude.value = storage.read('presensi_lastLat') ?? 0.0;
      lastLongitude.value = storage.read('presensi_lastLng') ?? 0.0;
      if (lastLatitude.value != 0.0 || lastLongitude.value != 0.0) {
        hasLocation.value = true;
      }
    }
  }

  void _saveLocalState() {
    final today = _todayDateStr();
    storage.write('presensi_date', today);
    storage.write('presensi_isClockedIn', isClockedIn.value);
    storage.write('presensi_isClockedOut', isClockedOut.value);
    storage.write('presensi_clockInTime', clockInTime.value);
    storage.write('presensi_clockOutTime', clockOutTime.value);
    storage.write('presensi_lastLat', lastLatitude.value);
    storage.write('presensi_lastLng', lastLongitude.value);
  }

  String _getCurrentUserId() {
    return auth.currentUser?.uid ??
        storage.read('userId') ??
        'pegawai_default';
  }

  String _getCurrentUserName() {
    return auth.currentUser?.displayName ??
        storage.read('studentName') ??
        storage.read('userName') ??
        'Pegawai';
  }

  Future<void> loadTodayAttendance() async {
    try {
      final userId = _getCurrentUserId();
      final today = _todayDateStr();

      final snapshot = await firestore
          .collection('attendances')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: today)
          .get();

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final type = data['type'] ?? data['status'];
          final time = data['time'] ?? '';
          final lat = (data['latitude'] ?? data['lat'] ?? 0.0) as num;
          final lng = (data['longitude'] ?? data['lang'] ?? 0.0) as num;

          if (type == 'MASUK') {
            isClockedIn.value = true;
            clockInTime.value = time.toString();
            lastLatitude.value = lat.toDouble();
            lastLongitude.value = lng.toDouble();
            hasLocation.value = true;
          } else if (type == 'PULANG') {
            isClockedOut.value = true;
            clockOutTime.value = time.toString();
            lastLatitude.value = lat.toDouble();
            lastLongitude.value = lng.toDouble();
            hasLocation.value = true;
          }
        }
        _saveLocalState();
      }
    } catch (e) {
      debugPrint('Error loading today attendance: $e');
    }
  }

  Future<void> fetchAttendanceHistory() async {
    try {
      final userId = _getCurrentUserId();
      final snapshot = await firestore
          .collection('attendances')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      final list = snapshot.docs.map((d) => d.data()).toList();
      attendanceHistory.assignAll(list);
    } catch (e) {
      debugPrint('Error fetching attendance history: $e');
    }
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar(
        'GPS Nonaktif',
        'Mohon aktifkan GPS/Layanan Lokasi perangkat Anda',
        backgroundColor: Colors.amber.shade700,
        colorText: Colors.white,
      );
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'Izin Ditolak',
          'Izin akses lokasi diperlukan untuk melakukan presensi',
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Izin Ditolak Permanen',
        'Buka pengaturan perangkat untuk mengizinkan akses lokasi',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      await Geolocator.openAppSettings();
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      debugPrint('Primary GPS error: $e. Trying last known position...');
      return await Geolocator.getLastKnownPosition();
    }
  }

  Future<void> presensiMasuk() async {
    if (isClockedIn.value) {
      Get.snackbar(
        'Info Presensi',
        'Anda sudah melakukan presensi MASUK hari ini pada jam ${clockInTime.value}',
        backgroundColor: Colors.blue.shade700,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final position = await _determinePosition();
      if (position == null) {
        isLoading.value = false;
        return;
      }

      final now = DateTime.now();
      final dateStr = _todayDateStr();
      final timeStr = DateFormat('HH:mm:ss').format(now);
      final userId = _getCurrentUserId();
      final userName = _getCurrentUserName();

      final record = {
        'userId': userId,
        'userName': userName,
        'type': 'MASUK',
        'status': 'MASUK',
        'date': dateStr,
        'time': timeStr,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'lat': position.latitude,
        'lang': position.longitude,
        'clockInDateTime': now.millisecondsSinceEpoch,
        'clockInLatitude': position.latitude,
        'clockInLongitude': position.longitude,
        'createdAt': now.millisecondsSinceEpoch,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await firestore.collection('attendances').add(record);

      // Update users collection if logged in
      if (auth.currentUser != null) {
        await firestore.collection('users').doc(userId).set({
          'status': true,
          'lastClockIn': now.millisecondsSinceEpoch,
          'lastLatitude': position.latitude,
          'lastLongitude': position.longitude,
        }, SetOptions(merge: true));
      }

      isClockedIn.value = true;
      clockInTime.value = timeStr;
      lastLatitude.value = position.latitude;
      lastLongitude.value = position.longitude;
      hasLocation.value = true;
      _saveLocalState();

      _showSuccessDialog(
        title: 'Presensi Masuk Berhasil',
        type: 'MASUK',
        time: timeStr,
        lat: position.latitude,
        lng: position.longitude,
      );

      fetchAttendanceHistory();
    } catch (e) {
      Get.snackbar(
        'Gagal Presensi',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> presensiPulang() async {
    if (!isClockedIn.value) {
      Get.snackbar(
        'Peringatan',
        'Anda harus melakukan presensi MASUK terlebih dahulu!',
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
      return;
    }

    if (isClockedOut.value) {
      Get.snackbar(
        'Info Presensi',
        'Anda sudah melakukan presensi PULANG hari ini pada jam ${clockOutTime.value}',
        backgroundColor: Colors.blue.shade700,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final position = await _determinePosition();
      if (position == null) {
        isLoading.value = false;
        return;
      }

      final now = DateTime.now();
      final dateStr = _todayDateStr();
      final timeStr = DateFormat('HH:mm:ss').format(now);
      final userId = _getCurrentUserId();
      final userName = _getCurrentUserName();

      final record = {
        'userId': userId,
        'userName': userName,
        'type': 'PULANG',
        'status': 'PULANG',
        'date': dateStr,
        'time': timeStr,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'lat': position.latitude,
        'lang': position.longitude,
        'clockOutDateTime': now.millisecondsSinceEpoch,
        'clockOutLatitude': position.latitude,
        'clockOutLongitude': position.longitude,
        'createdAt': now.millisecondsSinceEpoch,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await firestore.collection('attendances').add(record);

      if (auth.currentUser != null) {
        await firestore.collection('users').doc(userId).set({
          'status': false,
          'lastClockOut': now.millisecondsSinceEpoch,
          'lastLatitude': position.latitude,
          'lastLongitude': position.longitude,
        }, SetOptions(merge: true));
      }

      isClockedOut.value = true;
      clockOutTime.value = timeStr;
      lastLatitude.value = position.latitude;
      lastLongitude.value = position.longitude;
      hasLocation.value = true;
      _saveLocalState();

      _showSuccessDialog(
        title: 'Presensi Pulang Berhasil',
        type: 'PULANG',
        time: timeStr,
        lat: position.latitude,
        lng: position.longitude,
      );

      fetchAttendanceHistory();
    } catch (e) {
      Get.snackbar(
        'Gagal Presensi',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showSuccessDialog({
    required String title,
    required String type,
    required String time,
    required double lat,
    required double lng,
  }) {
    Get.defaultDialog(
      title: title,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      content: Column(
        children: [
          Icon(
            type == 'MASUK' ? Icons.login_rounded : Icons.logout_rounded,
            color: type == 'MASUK' ? Colors.green : Colors.red,
            size: 54,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 18, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Waktu: $time WIB',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, size: 18, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Koordinat:\nLat: ${lat.toStringAsFixed(6)}\nLang: ${lng.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.cloud_done, size: 18, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Tersimpan di Firebase',
                      style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => Get.back(),
        child: const Text('OK'),
      ),
    );
  }
}
