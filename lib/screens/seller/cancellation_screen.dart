import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/models/order_model.dart';
import 'package:u_teen/providers/order_provider.dart';
import 'package:u_teen/widgets/order_card.dart';
import 'package:u_teen/providers/theme_notifier.dart';
import 'package:u_teen/utils/app_theme.dart';

class CancellationScreen extends StatelessWidget {
  const CancellationScreen({super.key});

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
            'Cancelled Orders',
            style: TextStyle(
              color: AppTheme.getPrimaryText(isDarkMode),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: AppTheme.getPrimaryText(isDarkMode)),
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

    final cancelledOrders = orderProvider.getCancelledOrdersForMerchant(sellerEmail);

    if (cancelledOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel, size: 50, color: AppTheme.getSecondaryText(isDarkMode)),
            const SizedBox(height: 16),
            Text(
              'No cancelled orders',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.getSecondaryText(isDarkMode),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      color: AppTheme.getButton(isDarkMode),
      backgroundColor: AppTheme.getCard(isDarkMode),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cancelledOrders.length,
        itemBuilder: (context, index) => OrderCard(
          order: cancelledOrders[index],
          isSellerView: true,
          onTap: () {},
        ),
      ),
    );
  }
}