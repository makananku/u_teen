import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../auth/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/theme_notifier.dart';
import '../../models/cart_item.dart';
import '../../models/order_model.dart';

class CartSummaryWidget extends StatelessWidget {
  const CartSummaryWidget({Key? key}) : super(key: key);

  // Convert CartItem to OrderItem
  List<OrderItem> _convertToOrderItems(List<CartItem> cartItems) {
    return cartItems.map((cartItem) => OrderItem(
      name: cartItem.name,
      price: cartItem.price,
      imgBase64: cartItem.imgBase64,
      subtitle: cartItem.subtitle,
      sellerEmail: cartItem.sellerEmail,
      quantity: cartItem.quantity,
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
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
                      try {
                        final authUser = firebase_auth.FirebaseAuth.instance.currentUser;
                        if (authUser == null || authProvider.user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Please log in to place an order'),
                              backgroundColor: AppTheme.getSnackBarError(isDarkMode),
                            ),
                          );
                          return;
                        }

                        final customerUid = authUser.uid;
                        final orderItems = _convertToOrderItems(cartProvider.cartItems);

                        // Assume all cart items are from the same merchant
                        final merchantEmail = cartProvider.cartItems.first.sellerEmail;

                        // Fetch merchant name from users collection
                        final merchantDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .where('email', isEqualTo: merchantEmail)
                            .limit(1)
                            .get();
                        if (merchantDoc.docs.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Merchant not found'),
                              backgroundColor: AppTheme.getSnackBarError(isDarkMode),
                            ),
                          );
                          return;
                        }
                        final merchantName = merchantDoc.docs.first.data()['name'] as String;

                        debugPrint('CartSummaryWidget: Creating order for UID: $customerUid, merchant: $merchantEmail');

                        final order = await orderProvider.createOrderFromCart(
                          customerUid: customerUid,
                          items: orderItems,
                          pickupTime: DateTime.now().add(const Duration(hours: 1)),
                          paymentMethod: 'cash', // Adjust based on user input
                          merchantName: merchantName,
                          merchantEmail: merchantEmail,
                          notes: null, // Optional, add UI for notes if needed
                        );

                        await orderProvider.addOrder(order);
                        await cartProvider.clearCart();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Order placed successfully!'),
                              backgroundColor: AppTheme.getSnackBarSuccess(isDarkMode),
                            ),
                          );
                          Navigator.pushNamed(context, '/order-confirmation');
                        }
                      } catch (e) {
                        debugPrint('CartSummaryWidget: Error placing order: $e');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to place order: $e'),
                              backgroundColor: AppTheme.getSnackBarError(isDarkMode),
                            ),
                          );
                        }
                      }
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