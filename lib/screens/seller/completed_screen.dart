import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/providers/order_provider.dart';
import 'package:u_teen/widgets/order_card.dart';
import 'package:u_teen/models/order_model.dart';
import 'package:u_teen/providers/theme_notifier.dart';
import 'package:u_teen/utils/app_theme.dart';

class CompletedScreen extends StatelessWidget {
  const CompletedScreen({super.key});

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
            'Completed Orders',
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
    final orderProvider = Provider.of<OrderProvider>(context, listen: true);
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    final sellerEmail = authProvider.user?.email ?? '';
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

    debugPrint('Seller Email: $sellerEmail');
    debugPrint('All Completed Orders: ${orderProvider.completedOrders.length}');

    final completedOrders =
        orderProvider.completedOrders
            .where((order) => order.merchantEmail == sellerEmail)
            .toList();

    debugPrint('Filtered Completed Orders: ${completedOrders.length}');

    if (completedOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 50, color: AppTheme.getSecondaryText(isDarkMode)),
            const SizedBox(height: 16),
            Text(
              'No completed orders yet',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.getSecondaryText(isDarkMode),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedOrders.length,
      itemBuilder: (context, index) {
        debugPrint('Showing order: ${completedOrders[index].id}');
        return OrderCard(
          order: completedOrders[index],
          isSellerView: true,
          onTap: () {},
        );
      },
    );
  }
}