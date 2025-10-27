import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lapor_sih/utils/convert.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/colors.dart';
import 'userMainPage.dart';

class LaporanForm extends StatefulWidget {
  const LaporanForm({super.key});

  @override
  State<LaporanForm> createState() => _LaporanFormState();
}

class _LaporanFormState extends State<LaporanForm> {
  final supabase = Supabase.instance.client;
  final _descController = TextEditingController();
  File? _image;
  double? latitude;
  double? longitude;
  bool isLoading = false;

  // Ambil foto dari kamera
  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  // Dapatkan lokasi pengguna
  Future<void> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location service tidak aktif')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak')));
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });
  }

  // Upload laporan ke Supabase
  Future<void> submitLaporan() async {
    if (_image == null || latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data terlebih dahulu')),
      );
      return;
    }

    try {
      setState(() => isLoading = true);
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User belum login');

      // Upload foto ke Supabase Storage
      final fileName = 'laporan_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$userId/$fileName';
      await supabase.storage.from('lapor_sih_pics').upload(filePath, _image!);

      // Ambil URL publik
      final fotoUrl = supabase.storage
          .from('lapor_sih_pics')
          .getPublicUrl(filePath);

      // Simpan ke tabel laporan
      await supabase.from('laporan').insert({
        'user_id': userId,
        'latitude': latitude,
        'longitude': longitude,
        'deskripsi': _descController.text,
        'foto_url': fotoUrl,
        'status': false,
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserMainPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengirim laporan: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UserMainPage()),
            );
          },
        ),
        title: Text("Upload Laporan",
                              style: TextStyle(
                        fontFamily: "Helvetica",
                        fontSize: 24,
                        letterSpacing: figmaSpacing(-5, 24),
                        fontWeight: FontWeight.w400,
                      ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 21,
          ), // golden spacing
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 📸 Box Foto
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    height: 233, // 144 * 1.618 ≈ proporsi golden
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(21),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      image: _image != null
                          ? DecorationImage(
                              image: FileImage(_image!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _image == null
                        ? const Icon(Icons.camera_alt, size: 40)
                        : null,
                  ),
                ),

                const SizedBox(height: 34), // golden ratio step
                // Tombol Lokasi
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: getLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(48),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.secondary.withOpacity(0.5),
                    ),
                    child: const Text(
                      "Dapatkan Lokasi!",
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 16,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                if (latitude != null && longitude != null) ...[
                  const SizedBox(height: 13),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Lat: ${latitude!.toStringAsFixed(6)}, Lon: ${longitude!.toStringAsFixed(6)}",
                            style: const TextStyle(
                              fontFamily: "OpenSans",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 34),

                // Deskripsi
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Deskripsi...",
                      hintStyle: TextStyle(
                      fontFamily: "OpenSans"
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 55),

                // Tombol Lapor
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(48),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(1, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : submitLaporan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(48),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Lapor!",
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 16,
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
