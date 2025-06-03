import 'package:flutter/material.dart';
import 'package:u_teen/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'package:u_teen/providers/food_provider.dart';

class LogoutService extends StatelessWidget {
  static Future<bool> logout(BuildContext context) async {
    try {
      // Close all dialogs
      Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);

      // Clear auth state
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final logoutSuccess = await authProvider.logout();
      if (!logoutSuccess) {
        debugPrint('LogoutService: AuthProvider.logout returned false');
        throw Exception('Failed to logout from authentication service');
      }

      // Clear food products
      final foodProvider = Provider.of<FoodProvider>(context, listen: false);
      foodProvider.clearProducts();

      // Navigate to login screen
      if (!context.mounted) {
        debugPrint('LogoutService: Context is not mounted, skipping navigation');
        return false;
      }

      await Navigator.pushAndRemoveUntil(context, 
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );

      return true;
    } catch (error) {
      debugPrint('LogoutService error: $error');
      if (context.mounted) {
        // Fallback navigation
        await Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
        return true; // Consider navigation as success to avoid UI error
      }
      return false;
    }
  }

  static Future<bool> showLogoutConfirmation(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
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
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop(true); // Close dialog
                await logout(context); // Process logout
              },
            ),
          ],
        );
      },
    ) ?? false;
  }

  const LogoutService({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(); // Placeholder if used as widget
  }
}