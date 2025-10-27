import 'package:flutter/material.dart';
import 'package:lapor_sih/adminMainPage.dart';
import 'package:lapor_sih/userMainPage.dart';
import 'package:lapor_sih/utils/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AuthService {
  final supabase = Supabase.instance.client;

  void _showSnackbar(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppColors.danger : AppColors.success,
      duration: Duration(seconds: 1),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // SIGN UP
  Future<bool> signUpNewUser(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      if (email.isEmpty || password.isEmpty || password.length < 6) {
        _showSnackbar(context, "Email/password minimal 6 karakter");
        return false;
      }

      final response = await supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );

      // Cek apakah signup berhasil
      if (response.user == null) {
        _showSnackbar(context, "Gagal daftar. Coba lagi!");
        return false;
      }

      // Ambil user yang baru dibuat
      final user = response.user!;
      final userEmail = user.email ?? "";
      String username = "";
      for (int i = 0; i < userEmail.length; i++) {
        if (userEmail[i] == "@") {
          break;
        }
        username += userEmail[i];
      }

      await supabase.from('pengguna').insert({
        'id': user.id,
        'username': username,
      });

      _showSnackbar(context, 'Akun berhasil dibuat!', isError: false);
      return true;
    } on AuthException catch (e) {
      String message;
      switch (e.message) {
        case 'User already registered':
        case 'Email already registered':
          message = 'Email sudah dipakai!';
          break;
        case 'Invalid email':
          message = 'Format email salah!';
          break;
        case 'Password should be at least 6 characters':
          message = 'Password minimal 6 karakter!';
          break;
        default:
          message = e.message;
      }
      _showSnackbar(context, message);
      return false;
    } catch (e) {
      _showSnackbar(context, "Error: ${e.toString()}");
      return false;
    }
  }

  Future<bool> signIn(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        _showSnackbar(context, "Email/password kosong");
        return false;
      }

      final response = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      // Ambil user yang baru dibuat
      final user = response.user!;
      final userEmail = user.email ?? "";
     final userId = user.id;
      String username = "";
      for (int i = 0; i < userEmail.length; i++) {
        if (userEmail[i] == "@") {
          break;
        }
        username += userEmail[i];
      }
      //Login logic berdasarkan roles
      if (username.contains('admin') || username.contains('Admin')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminMainPage()),
        );
      } else {
        print("Berhasil Login dengan username :" + '$username');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserMainPage()),
        );
      }

      if (response.user != null) {
        _showSnackbar(
          context,
          'Login berhasil! Selamat datang!',
          isError: false,
        );
        return true;
      }

      _showSnackbar(context, "Login gagal");
      return false;
    } on AuthException catch (e) {
      String message;
      switch (e.message) {
        case 'Invalid login credentials':
          message = 'Email/password salah!';
          break;
        case 'Email not confirmed':
          message = 'Cek email konfirmasi dulu!';
          break;
        default:
          message = e.message;
      }
      _showSnackbar(context, message);
      return false;
    } catch (e) {
      _showSnackbar(context, "Koneksi error. Cek internet kamu!");
      return false;
    }
  }

  // SIGN OUT (bonus)
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}

