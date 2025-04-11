import 'package:flutter/material.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/models/order_model.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/providers/order_provider.dart';
import 'package:u_teen/widgets/order_card.dart';
import 'package:u_teen/screens/seller/home_screen.dart';

class CancellationScreen extends StatelessWidget {
  const CancellationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final sellerEmail = authProvider.user?.email ?? '';
    
    final cancelledOrders = orderProvider.getCancelledOrdersForMerchant(sellerEmail);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cancelled Orders'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SellerHomeScreen()),
          ),
        ),
      ),
      body: _buildOrderList(cancelledOrders),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel, size: 50, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No cancelled orders',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) => OrderCard(order: orders[index]),
      ),
    );
  }
}