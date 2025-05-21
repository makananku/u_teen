import 'package:flutter/material.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/theme_notifier.dart';
import 'package:provider/provider.dart';

class CartSummaryWidget extends StatelessWidget {
  const CartSummaryWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCard(isDarkMode),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${cartProvider.totalItems} Items Selected",
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.getTextGrey(isDarkMode),
                ),
              ),
              Text(
                "Rp ${cartProvider.totalPrice}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getPrimaryText(isDarkMode),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: cartProvider.cartItems.isNotEmpty ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.getAccentPrimaryBlue(isDarkMode),
                foregroundColor: AppTheme.getPrimaryText(!isDarkMode),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                "Buy Now",
                style: TextStyle(
                  color: AppTheme.getPrimaryText(!isDarkMode),
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}