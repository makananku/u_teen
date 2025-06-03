import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/providers/food_provider.dart';
import 'package:u_teen/screens/login_screen.dart';
import 'package:u_teen/utils/app_theme.dart';
import 'package:u_teen/providers/theme_notifier.dart';

class LogoutService {
  static Future<bool> showLogoutDialog(BuildContext context) async {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final isDarkMode = themeNotifier.isDarkMode;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.getCard(isDarkMode),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.getAccentRedLight(isDarkMode),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout,
                  size: 40,
                  color: AppTheme.getSnackBarError(isDarkMode),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Ready to Leave?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getPrimaryText(isDarkMode),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "You'll be signed out of your account",
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.getSecondaryText(isDarkMode),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: AppTheme.getSwitchInactive(isDarkMode),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: AppTheme.getDetailBackground(isDarkMode),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: AppTheme.getTextMedium(isDarkMode),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.getSnackBarError(isDarkMode),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Logout",
                        style: TextStyle(
                          color: AppTheme.getPrimaryText(!isDarkMode),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      return await logout(context);
    }
    return false;
  }

  static Future<bool> logout(BuildContext context) async {
    try {
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
      if (context.mounted) {
        // Close all dialogs and routes
        Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
        // Perform navigation to LoginScreen
        await Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        debugPrint('LogoutService: Context is not mounted, attempting navigation with new context');
        // Fallback: Use a new context from the navigator key if available
        final navigator = Navigator.of(context, rootNavigator: true);
        navigator.popUntil((route) => route.isFirst);
        await navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }

      return true;
    } catch (error) {
      debugPrint('LogoutService error: $error');
      // Attempt navigation even on error to ensure user is redirected
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
        await Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
      return false; // Return false to trigger error message
    }
  }
}