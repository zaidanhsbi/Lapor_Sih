import 'package:flutter/material.dart';

class Register extends StatelessWidget {
  const Register({super.key});
  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Register UI',
      home: const register(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class register extends StatelessWidget {
  const register ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        // Perbaiki padding atas dan bawah juga agar layout lebih proporsional
        padding: const EdgeInsets.symmetric(horizontal: 40.0).copyWith(top: 80, bottom: 40),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Supaya tombol full-width sesuai container
              children: [
                const Text(
                  "Daftar Akun",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[300],
                    hintText: "Masukan Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
                 const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[300],
                    hintText: "Masukan username",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[300],
                    hintText: "Masukan password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: implement login logic
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      backgroundColor: Colors.black,
                      elevation: 0, // karena shadow sudah pakai boxShadow di container
                    ),
                    child: const Text("Daftar", style: TextStyle(color: Colors.white),),
              
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
