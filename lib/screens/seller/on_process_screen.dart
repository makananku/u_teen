import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/providers/order_provider.dart';
import 'package:u_teen/widgets/order_card.dart';
import 'package:u_teen/widgets/seller/empty_state_widget.dart';
import 'package:u_teen/providers/theme_notifier.dart';
import 'package:u_teen/utils/app_theme.dart';

class OnProcessScreen extends StatelessWidget {
  const OnProcessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDarkMode;
    return Theme(
      data: themeNotifier.currentTheme,
      child: Scaffold(
        backgroundColor: AppTheme.getBackground(isDarkMode),
        appBar: AppBar(
          backgroundColor: AppTheme.getCard(isDarkMode),
          title: Text(
            'Processing Orders',
            style: TextStyle(
              color: AppTheme.getPrimaryText(isDarkMode),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppTheme.getPrimaryText(isDarkMode)),
            onPressed: () => Navigator.pop(context),
          ),
          elevation: isDarkMode ? 0 : 0.5,
        ),
        body: _buildOrderList(context),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final sellerEmail = authProvider.user?.email ?? '';
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

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

    if (processingOrders.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.hourglass_empty,
        message: 'No orders currently processing',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: processingOrders.length,
      itemBuilder: (context, index) {
        return OrderCard(
          order: processingOrders[index],
          isSellerView: true,
          onTap: () {
            // TODO: Navigate to order details screen if needed
          },
        );
      },
    );
  }
}