import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/colors.dart';
import 'utils/config.dart';
import 'utils/convert.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  final supabase = Supabase.instance.client;
  mapbox.MapboxMap? mapboxMap;
  geo.Position? currentLocation;
  List<Map<String, dynamic>> laporanList = [];
  bool isLoading = true;
  Map<String, dynamic>? selectedLaporan;
  mapbox.PointAnnotationManager? pointAnnotationManager; 

  @override
  void initState() {
    super.initState();
    mapbox.MapboxOptions.setAccessToken(mapBoxToken);
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    await _fetchLaporan();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location service tidak aktif');
      }

      geo.LocationPermission permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak');
        }
      }

      currentLocation = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );
      setState(() {});
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _fetchLaporan() async {
    try {
      final response = await supabase
          .from('laporan')
          .select(
              'id, user_id, latitude, longitude, deskripsi, foto_url, status, pengguna!inner(username)')
          .eq('status', false);
      setState(() {
        laporanList = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });

      if (mapboxMap != null) {
        await _addMarkers();
      }
    } catch (e) {
      print('Error fetching laporan: $e');
      setState(() => isLoading = false);
    }
  }

  void _onMapCreated(mapbox.MapboxMap map) {
    mapboxMap = map;
    if (!isLoading) {
      _addMarkers();
    }
  }

  Future<void> _addMarkers() async {
    if (mapboxMap == null) return;

    // Buat atau gunakan PointAnnotationManager
    if (pointAnnotationManager == null) {
      pointAnnotationManager = await mapboxMap!.annotations.createPointAnnotationManager();
    }

    // Hapus semua marker yang ada
    await pointAnnotationManager!.deleteAll();

    try {
      // Memuat gambar dari assets
      final ByteData bytes = await rootBundle.load('assets/icon-marker.png');
      final Uint8List imageData = bytes.buffer.asUint8List();

      // Tambahkan marker baru
      for (var laporan in laporanList) {
        final latitude = laporan['latitude'] as num;
        final longitude = laporan['longitude'] as num;

        final pointAnnotationOptions = mapbox.PointAnnotationOptions(
          image: imageData,
          geometry: mapbox.Point(
            coordinates: mapbox.Position(
              longitude.toDouble(),
              latitude.toDouble(),
            ),
          ),

          iconSize: 1.5,
        );

        await pointAnnotationManager!.create(pointAnnotationOptions);
      }

      // Tambahkan listener untuk klik marker
      pointAnnotationManager!.addOnPointAnnotationClickListener(
        MyPointAnnotationClickListener(_onMarkerTap),
      );
    } catch (e) {
      print('Error adding markers: $e');
    }
  }

  void _onMarkerTap(mapbox.PointAnnotation annotation) {
    final geometry = annotation.geometry;
    if (geometry is mapbox.Point) {
      final coords = geometry.coordinates;
      final laporan = laporanList.firstWhere(
        (l) =>
            (l['longitude'] as num).toDouble() == coords.lng &&
            (l['latitude'] as num).toDouble() == coords.lat,
        orElse: () => {},
      );

      if (laporan.isNotEmpty) {
        setState(() {
          selectedLaporan = laporan;
        });
      }
    }
  }

  Future<void> _updateStatus(String laporanId) async {
    try {
      await supabase.from('laporan').update({'status': true}).eq('id', laporanId);

      setState(() {
        selectedLaporan = null;
      });

      // Refresh data laporan dan marker
      await _fetchLaporan();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status laporan berhasil diubah')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (currentLocation != null)
            mapbox.MapWidget(
              key: const ValueKey("mapWidget"),
              onMapCreated: _onMapCreated,
              cameraOptions: mapbox.CameraOptions(
                center: mapbox.Point(
                  coordinates: mapbox.Position(
                    currentLocation!.longitude,
                    currentLocation!.latitude,
                  ),
                ),
                zoom: 14.0,
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),

          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: Text(
                  "Temukan Lokasi\nJalan Rusak",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Helvetica",
                    fontSize: 32,
                    letterSpacing: figmaSpacing(-5, 32),
                    fontWeight: FontWeight.w400,
                    color: AppColors.textBlack,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),

          if (selectedLaporan != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedLaporan = null;
                  });
                },
                child: Container(
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        margin: const EdgeInsets.all(24),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 160,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(16),
                                image: selectedLaporan!['foto_url'] != null
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          selectedLaporan!['foto_url'],
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: selectedLaporan!['foto_url'] == null
                                  ? const Center(
                                      child: Text(
                                        "FOTO",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Dear \"${selectedLaporan!['pengguna']['username']}\",",
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Latitude: ${selectedLaporan!['latitude']}",
                              style: const TextStyle(
                                fontFamily: "OpenSans",
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "Longitude: ${selectedLaporan!['longitude']}",
                              style: const TextStyle(
                                fontFamily: "OpenSans",
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              selectedLaporan!['deskripsi'] ??
                                  "(Deskripsi kosong)",
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: "OpenSans",
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  _updateStatus(selectedLaporan!['id']);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(48),
                                  ),
                                  elevation: 4,
                                ),
                                child: const Text(
                                  "Ubah Status",
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
                ),
              ),
            ),

          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.secondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Listener harus di luar class utama!
class MyPointAnnotationClickListener
    extends mapbox.OnPointAnnotationClickListener {
  final void Function(mapbox.PointAnnotation) onClick;

  MyPointAnnotationClickListener(this.onClick);

  @override
  void onPointAnnotationClick(mapbox.PointAnnotation annotation) {
    onClick(annotation);
  }
}