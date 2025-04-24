import 'package:flutter/material.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/providers/order_provider.dart';
import 'package:u_teen/widgets/order_card.dart';
import 'package:u_teen/screens/seller/home_screen.dart';
import '../../models/order_model.dart';

class CompletedScreen extends StatelessWidget {
  const CompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: true);
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    final sellerEmail = authProvider.user?.email ?? '';
    
    // Debugging: Print untuk memverifikasi data
    debugPrint('Seller Email: $sellerEmail');
    debugPrint('All Completed Orders: ${orderProvider.completedOrders.length}');
    
    final completedOrders = orderProvider.completedOrders
        .where((order) => order.merchantEmail == sellerEmail)
        .toList();

    debugPrint('Filtered Completed Orders: ${completedOrders.length}');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Completed Orders'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SellerHomeScreen()),
          ),
        ),
      ),
      body: _buildOrderList(completedOrders),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 50, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No completed orders yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

      return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        debugPrint('Showing order: ${orders[index].id}');
        return OrderCard(
          order: orders[index],
          isSellerView: true, onTap: () {  },
        );
      },
    );
  }
}