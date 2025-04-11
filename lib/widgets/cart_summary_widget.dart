import 'package:flutter/material.dart';
import '../providers/cart_provider.dart';
import 'package:provider/provider.dart';

class CartSummaryWidget extends StatelessWidget {
  const CartSummaryWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${cartProvider.totalItems} Items Selected",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                "Rp ${cartProvider.totalPrice}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Buy Now",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}