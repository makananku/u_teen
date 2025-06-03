import 'package:flutter/material.dart';
import 'package:u_teen/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'package:u_teen/providers/food_provider.dart';

class LogoutService {
  static Future<void> logout(BuildContext context) async {
    try {
      // Tutup semua dialog yang mungkin terbuka
      Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
      
      // Clear auth state
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      
      // Clear food products jika diperlukan
      final foodProvider = Provider.of<FoodProvider>(context, listen: false);
      foodProvider.clearProducts();
      
      // Navigasi ke login screen dengan menghapus semua route sebelumnya
      await Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      debugPrint('Logout error: $e');
      // Fallback navigasi jika terjadi error
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  static Future<void> showLogoutConfirmation(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            "Logout",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: const Text(
            "Are you sure you want to logout?",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog
                await logout(context); // Proses logout
              },
            ),
          ],
        );
      },
    );
  }
}