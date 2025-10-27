import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/colors.dart';
import 'utils/convert.dart';
import 'laporanForm.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({super.key});

  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  final supabase = Supabase.instance.client;
  String? username;
  List<Map<String, dynamic>> laporanList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Ambil username
      final userResponse = await supabase
          .from('pengguna')
          .select('username')
          .eq('id', userId)
          .single();

      // Ambil laporan berdasarkan user_id
      final laporanResponse = await supabase
          .from('laporan')
          .select('id, latitude, longitude, status, deskripsi, foto_url')
          .eq('user_id', userId);

      setState(() {
        username = userResponse['username'];
        laporanList = List<Map<String, dynamic>>.from(laporanResponse);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username == null ? 'Halo, ...' : 'Halo, $username',
                      style: TextStyle(
                        fontFamily: "Helvetica",
                        fontSize: 32,
                        letterSpacing: figmaSpacing(-5, 32),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Laporanku',
                      style: TextStyle(
                        fontFamily: "Helvetica",
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: laporanList.isEmpty
                          ? const Center(
                              child: Text(
                                "Laporan Kosong!",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textBlack,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: laporanList.length,
                              itemBuilder: (context, index) {
                                final laporan = laporanList[index];
                                final processed = laporan['status'] == true;

                                return GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: double.infinity,
                                                  height: 160,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    image:
                                                        laporan['foto_url'] !=
                                                            null
                                                        ? DecorationImage(
                                                            image: NetworkImage(
                                                              laporan['foto_url'],
                                                            ),
                                                            fit: BoxFit.cover,
                                                          )
                                                        : null,
                                                  ),
                                                  child:
                                                      laporan['foto_url'] ==
                                                          null
                                                      ? const Center(
                                                          child: Text("FOTO"),
                                                        )
                                                      : null,
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  "Dear \"$username\",",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: "Monserrat",
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  "Latitude: ${laporan['latitude']}",
                                                  style: TextStyle(
                                                    fontFamily: "OpenSans"
                                                  ),
                                                ),
                                                Text(
                                                  "Longitude: ${laporan['longitude']}",
                                                  style: TextStyle(
                                                    fontFamily: "OpenSans"
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  laporan['deskripsi'] ??
                                                      "(Deskripsi kosong)",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: "OpenSans"
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            image: laporan['foto_url'] != null
                                                ? DecorationImage(
                                                    image: NetworkImage(
                                                      laporan['foto_url'],
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Status :",
                                                style: TextStyle(fontSize: 16
                                                ,fontFamily: "Monserrat",
                                                fontWeight: FontWeight.w500),
                                                
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.secondary,
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      processed
                                                          ? "Telah diproses"
                                                          : "Belum diproses",
                                                      style: const TextStyle(
                                                        color:
                                                            AppColors.textWhite,
                                                        fontSize: 16,
                                                        fontFamily: "Monserrat",
                                                        fontWeight: FontWeight.w600
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: BoxDecoration(
                                                        color: processed
                                                            ? AppColors.success
                                                            : AppColors.danger,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: 12),
                    Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(48),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary,
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LaporanForm(),
                            ),
                          );
                        },

                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(48),
                          ),
                          backgroundColor: AppColors.secondary,
                          elevation: 0,
                        ),
                        child: const Text(
                          "Lapor!",
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 24,
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
    );
  }
}
