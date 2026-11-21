import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:absensigo/controllers/Shared/PresensiController.dart';
import 'package:absensigo/views/shared/PresensiCard.dart';

class PresensiPage extends StatelessWidget {
  const PresensiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PresensiController controller = Get.put(PresensiController());
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Presensi Online",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.onSecondaryFixed,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu Presensi Utama (MASUK / PULANG + GPS Coordinates)
            const PresensiCard(),
            const SizedBox(height: 24),

            // Riwayat Presensi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Riwayat Presensi Terakhir",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => controller.fetchAttendanceHistory(),
                  tooltip: "Muat Ulang Riwayat",
                ),
              ],
            ),
            const SizedBox(height: 8),

            Obx(() {
              if (controller.attendanceHistory.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        "Belum ada data presensi",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.attendanceHistory.length,
                itemBuilder: (context, index) {
                  final item = controller.attendanceHistory[index];
                  final type = item['type'] ?? item['status'] ?? 'PRESENSI';
                  final date = item['date'] ?? '';
                  final time = item['time'] ?? '';
                  final lat = (item['latitude'] ?? item['lat'] ?? 0.0) as num;
                  final lng = (item['longitude'] ?? item['lang'] ?? 0.0) as num;
                  final isMasuk = type == 'MASUK';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            isMasuk
                                ? Colors.green.shade50
                                : Colors.blue.shade50,
                        child: Icon(
                          isMasuk ? Icons.login_rounded : Icons.logout_rounded,
                          color: isMasuk ? Colors.green : Colors.blue,
                        ),
                      ),
                      title: Text(
                        "Presensi $type",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text("Waktu: $date $time WIB"),
                          if (lat != 0.0 || lng != 0.0) ...[
                            const SizedBox(height: 2),
                            Text(
                              "📍 Lat: ${lat.toStringAsFixed(6)}, Lang: ${lng.toStringAsFixed(6)}",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "Firebase",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
