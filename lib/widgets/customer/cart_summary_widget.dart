import 'package:flutter/material.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/theme_notifier.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/cart_item.dart';
import '../../models/order_model.dart';
import '../../auth/auth_provider.dart';

class CartSummaryWidget extends StatefulWidget {
  final DateTime? pickupTime;
  final String? paymentMethod;
  final String? notes;

  const CartSummaryWidget({
    Key? key,
    this.pickupTime,
    this.paymentMethod,
    this.notes,
  }) : super(key: key);

  @override
  _CartSummaryWidgetState createState() => _CartSummaryWidgetState();
}

class _CartSummaryWidgetState extends State<CartSummaryWidget> {
  bool _isPlacingOrder = false;

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
              onPressed: cartProvider.cartItems.isNotEmpty && !_isPlacingOrder
                  ? () async {
                      if (!authProvider.isLoggedIn || authProvider.user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please log in to place an order'),
                            backgroundColor:
                                AppTheme.getSnackBarError(isDarkMode),
                          ),
                        );
                        Navigator.pushNamed(context, '/login');
                        return;
                      }

                      // Validate single seller
                      final sellerEmails = cartProvider.cartItems
                          .map((item) => item.sellerEmail)
                          .toSet();
                      if (sellerEmails.length > 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'All items must be from the same seller'),
                            backgroundColor:
                                AppTheme.getSnackBarError(isDarkMode),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _isPlacingOrder = true;
                      });

                      try {
                        final orderItems =
                            _convertToOrderItems(cartProvider.cartItems);
                        final order = orderProvider.createOrderFromCart(
                          items: orderItems,
                          pickupTime: widget.pickupTime ??
                              DateTime.now().add(const Duration(hours: 1)),
                          paymentMethod: widget.paymentMethod ?? 'cash',
                          merchantName: cartProvider.cartItems.first.subtitle,
                          merchantEmail: cartProvider.cartItems.first.sellerEmail,
                          customerName: authProvider.user!.email,
                          notes: widget.notes,
                        );
                        await orderProvider.addOrder(order);
                        await cartProvider.clearCart();
                        if (context.mounted) {
                          Navigator.pushNamed(context, '/order-confirmation');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Order placed successfully!'),
                              backgroundColor:
                                  AppTheme.getSnackBarInfo(isDarkMode),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to place order: $e'),
                              backgroundColor:
                                  AppTheme.getSnackBarError(isDarkMode),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isPlacingOrder = false;
                          });
                        }
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.getAccentPrimaryBlue(isDarkMode),
                foregroundColor: AppTheme.getPrimaryText(!isDarkMode),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isPlacingOrder
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.getPrimaryText(!isDarkMode),
                      ),
                    )
                  : Text(
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