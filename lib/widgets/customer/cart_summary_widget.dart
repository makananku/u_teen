import 'package:flutter/material.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/theme_notifier.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/cart_item.dart';
import '../../models/order_model.dart';

class CartSummaryWidget extends StatelessWidget {
  const CartSummaryWidget({Key? key}) : super(key: key);

  // Convert CartItem to OrderItem
  List<OrderItem> _convertToOrderItems(List<CartItem> cartItems) {
    return cartItems.map((cartItem) => OrderItem(
      name: cartItem.name,
      price: cartItem.price,
      imgBase64: cartItem.image,
      subtitle: cartItem.subtitle,
      sellerEmail: cartItem.sellerEmail,
      quantity: cartItem.quantity,
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
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
              onPressed: cartProvider.cartItems.isNotEmpty
                  ? () async {
                      final orderItems = _convertToOrderItems(cartProvider.cartItems);
                      await orderProvider.createOrderFromCart(
                        items: orderItems, // Now passing List<OrderItem>
                        pickupTime: DateTime.now().add(const Duration(hours: 1)),
                        paymentMethod: 'cash',
                        merchantName: 'Masakan Minang',
                        merchantEmail: cartProvider.cartItems.first.sellerEmail,
                        customerName: 'currentUser',
                        notes: null,
                      );
                      await cartProvider.clearCart();
                      Navigator.pushNamed(context, '/order-confirmation');
                    }
                  : null,
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