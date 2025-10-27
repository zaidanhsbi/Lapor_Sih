import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions(BuildContext context) async {

  var cameraStatus = await Permission.camera.status;
  var locationStatus = await Permission.location.status;

  print("Status awal:");
  print("Camera: $cameraStatus");
  print("Location: $locationStatus");

  if (cameraStatus.isDenied || cameraStatus.isRestricted) {
    bool? retryCamera = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Izin Kamera Diperlukan"),
        content: const Text(
          "Aplikasi membutuhkan akses kamera untuk mengambil foto laporan.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Izinkan"),
          ),
        ],
      ),
    );

    if (retryCamera == true) {
      var result = await Permission.camera.request();
      if (result.isGranted) {
        print("Izin kamera diberikan");
      } else {
        print("Izin kamera ditolak");
      }
    }
  }

  if (cameraStatus.isPermanentlyDenied) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Aktifkan izin kamera di pengaturan."),
      ),
    );
    openAppSettings();
  }

  if (locationStatus.isDenied || locationStatus.isRestricted) {
    bool? retryLocation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Izin Lokasi Diperlukan"),
        content: const Text(
          "Aplikasi memerlukan akses lokasi untuk mengirimkan laporan dengan koordinat yang akurat.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Izinkan"),
          ),
        ],
      ),
    );

    if (retryLocation == true) {
      var result = await Permission.location.request();
      if (result.isGranted) {
        print("Izin lokasi diberikan ");
      } else {
        print("Izin lokasi ditolak");
      }
    }
  }

  if (locationStatus.isPermanentlyDenied) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Aktifkan izin lokasi di pengaturan."),
      ),
    );
    openAppSettings();
  }
  print("Status akhir:");
  print("Camera: ${await Permission.camera.status}");
  print("Location: ${await Permission.location.status}");
}
