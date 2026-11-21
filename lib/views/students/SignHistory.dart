import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:absensigo/controllers/Student/SignHistory.dart';
import 'package:absensigo/models/SignHistory.dart';

class SignHistory extends StatelessWidget {
  final SignHistoryController controller = Get.find();

  SignHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sign History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.onSecondaryFixed,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator(color: Colors.blue));
          }
          if (controller.signHistoryList.isEmpty) {
            return const Center(
              child: Text(
                "No sign-in history available",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Displaying sign-in history as simple ListTiles
          return ListView.builder(
            itemCount: controller.signHistoryList.length,
            itemBuilder: (context, index) {
              SignHistoryModel sign = controller.signHistoryList[index];
              final isPulang = sign.status == "Pulang";
              return Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: Icon(
                    isPulang ? Icons.logout_rounded : Icons.check_circle,
                    color: isPulang ? Colors.orange : Colors.green,
                  ),
                  title: Text(
                    sign.moduleCode,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Waktu: ${sign.timeSigned}"),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isPulang ? Colors.orange : Colors.green).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      sign.status,
                      style: TextStyle(
                        color: isPulang ? Colors.orange.shade800 : Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 12,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
