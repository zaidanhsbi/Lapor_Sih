import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client.auth;

  void _showSnackbar(BuildContext context, String message, {bool isError = true}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
      duration: Duration(seconds: 2),
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

      final response = await supabase.signUp(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        _showSnackbar(
          context,
          'Akun berhasil dibuat!',
          isError: false,
        );
        return true;
      }
      
      _showSnackbar(context, "Gagal daftar. Coba lagi!");
      return false;
    } on AuthException catch (e) {
      String message;
      switch (e.message) {
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
      _showSnackbar(context, "Koneksi error. Cek internet kamu!");
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

      final response = await supabase.signInWithPassword(
        email: email.trim(),
        password: password,
      );

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
}

// Cara pakai di widget:
// 
// ElevatedButton(
//   onPressed: () async {
//     final authService = AuthService();
//     final success = await authService.signIn(
//       context,
//       emailController.text,
//       passwordController.text,
//     );
//     
//     if (success) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => UserMain()),
//       );
//     }
//   },
//   child: Text('Login'),
// )