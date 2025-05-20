import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/models/order_model.dart';
import 'package:u_teen/providers/order_provider.dart';
import 'package:u_teen/widgets/order_card.dart';
import 'package:u_teen/widgets/seller/empty_state_widget.dart';

class OnProcessScreen extends StatelessWidget {
  const OnProcessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final sellerEmail = authProvider.user?.email ?? '';

    // Filter orders by seller email and processing status
    final processingOrders = orderProvider.orders
        .where(
          (order) =>
              order.merchantEmail == sellerEmail &&
              (order.status == 'pending' ||
                  order.status == 'processing' ||
                  order.status == 'ready'),
        )
        .toList();

    // Sort orders: pending > processing > ready
    processingOrders.sort((a, b) {
      const statusPriority = {
        'pending': 1,
        'processing': 2,
        'ready': 3,
      };
      return statusPriority[a.status]!.compareTo(statusPriority[b.status]!);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Processing Orders',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: _buildOrderList(context, processingOrders),
    );
  }

  Widget _buildOrderList(BuildContext context, List<Order> orders) {
    if (orders.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.hourglass_empty,
        message: 'No orders currently processing',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return OrderCard(
          order: orders[index],
          isSellerView: true,
          onTap: () {
            // TODO: Navigate to order details screen if needed
          },
        );
      },
    );
  }
}