import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../models/order_model.dart';
import '../../utils/app_theme.dart';
import '../../providers/theme_notifier.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final Order order;

  const PaymentSuccessScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

    return Scaffold(
      backgroundColor: AppTheme.getCard(isDarkMode),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animation/success_checkmark.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              repeat: true,
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.getSnackBarSuccess(isDarkMode),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Order #${order.id}',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.getPrimaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ${currencyFormat.format(order.totalPrice)}',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.getPrimaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pickup at ${DateFormat('HH:mm').format(order.pickupTime)}',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.getPrimaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 32),
            _buildAnimatedButton(context, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedButton(BuildContext context, bool isDarkMode) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getButton(isDarkMode),
              foregroundColor: AppTheme.getPrimaryText(!isDarkMode),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
              shadowColor: AppTheme.getSnackBarSuccess(isDarkMode).withOpacity(0.3),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home, size: 20),
                SizedBox(width: 8),
                Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}