import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:absensigo/controllers/Shared/PresensiController.dart';

class PresensiCard extends StatelessWidget {
  const PresensiCard({super.key});

  @override
  Widget build(BuildContext context) {
    final PresensiController controller = Get.put(PresensiController());
    final theme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      color: theme.onSecondary,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: PRESENSI & Live Clock
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.how_to_reg_rounded,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "PRESENSI",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time_filled,
                          size: 14,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${controller.currentTime.value} WIB",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Date Subtitle
            Obx(
              () => Text(
                controller.currentDate.value,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Buttons: [ MASUK ]  [ PULANG ] (seperti soal magang nomor 1)
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text(
                          "Mengambil koordinat GPS & menyimpan ke Firebase...",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Row(
                children: [
                  // Tombol MASUK
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              controller.isClockedIn.value
                                  ? Colors.grey.shade400
                                  : const Color(0xFF1E88E5), // Blue matching PDF
                          foregroundColor: Colors.white,
                          elevation: controller.isClockedIn.value ? 0 : 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.login_rounded, size: 20),
                        label: Text(
                          controller.isClockedIn.value
                              ? "MASUK (${controller.clockInTime.value})"
                              : "MASUK",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        onPressed:
                            controller.isClockedIn.value
                                ? null
                                : () => controller.presensiMasuk(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Tombol PULANG
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              (!controller.isClockedIn.value ||
                                      controller.isClockedOut.value)
                                  ? Colors.grey.shade400
                                  : const Color(0xFF42A5F5), // Light blue matching PDF
                          foregroundColor: Colors.white,
                          elevation:
                              (!controller.isClockedIn.value ||
                                      controller.isClockedOut.value)
                                  ? 0
                                  : 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.logout_rounded, size: 20),
                        label: Text(
                          controller.isClockedOut.value
                              ? "PULANG (${controller.clockOutTime.value})"
                              : "PULANG",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        onPressed:
                            (!controller.isClockedIn.value ||
                                    controller.isClockedOut.value)
                                ? null
                                : () => controller.presensiPulang(),
                      ),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 16),

            // Location Coordinate Display (Get Lokasi Koordinat Absen)
            Obx(() {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.my_location_rounded,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Get Lokasi Koordinat Absen:",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            controller.hasLocation.value
                                ? "Lat: ${controller.lastLatitude.value.toStringAsFixed(6)} | Lang: ${controller.lastLongitude.value.toStringAsFixed(6)}"
                                : "Belum ada data (akan diambil saat tombol ditekan)",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color:
                                  controller.hasLocation.value
                                      ? Colors.black87
                                      : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_done,
                            size: 13,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            "Firebase",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
