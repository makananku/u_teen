import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/screens/login_screen.dart';
import 'auth_provider.dart';
import 'package:u_teen/providers/food_provider.dart';
import 'package:u_teen/providers/cart_provider.dart';
import 'package:u_teen/providers/favorite_provider.dart';
import 'package:u_teen/providers/order_provider.dart';
import 'package:u_teen/providers/notification_provider.dart';
import 'package:u_teen/providers/rating_provider.dart';
import 'package:u_teen/providers/theme_notifier.dart';
import 'package:u_teen/utils/app_theme.dart';

class LogoutService {
  static Future<void> logout(BuildContext context) async {
    try {
      // Tutup semua dialog yang mungkin terbuka
      Navigator.of(context, rootNavigator: true)
          .popUntil((route) => route.isFirst);

      // Ambil semua provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final foodProvider = Provider.of<FoodProvider>(context, listen: false);
      final favoriteProvider =
          Provider.of<FavoriteProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);

      // Logout dari AuthProvider
      debugPrint('LogoutService: Logging out user');
      await authProvider.logout();

      // Bersihkan state provider lain
      debugPrint('LogoutService: Clearing cart');
      await cartProvider.clearCart();

      debugPrint('LogoutService: Clearing food products');
      foodProvider.clearProducts();

      debugPrint('LogoutService: Clearing favorites');
      await favoriteProvider.clearFavorites();

      debugPrint('LogoutService: Clearing orders');
      orderProvider.clearOrders();

      debugPrint('LogoutService: Clearing notifications');
      await notificationProvider.clearAll();

      // Navigasi ke login screen dengan menghapus semua route sebelumnya
      debugPrint('LogoutService: Navigating to LoginScreen');
      await Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      debugPrint('LogoutService: Error during logout: $e');
      // Fallback navigasi jika terjadi error
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  static Future<void> showLogoutConfirmation(BuildContext context) async {
    final isDarkMode = Provider.of<ThemeNotifier>(context, listen: false).isDarkMode;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.getCard(isDarkMode),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            "Logout",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.getPrimaryText(isDarkMode),
            ),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: TextStyle(color: AppTheme.getPrimaryText(isDarkMode)),
          ),
          actions: [
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: AppTheme.getButton(isDarkMode)),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                "Logout",
                style: TextStyle(color: AppTheme.getError(isDarkMode)),
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