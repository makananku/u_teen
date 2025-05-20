import 'package:flutter/material.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/models/order_model.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/providers/order_provider.dart';
import 'package:u_teen/widgets/order_card.dart';
import 'package:u_teen/providers/theme_notifier.dart';

class CancellationScreen extends StatelessWidget {
  const CancellationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          final isDarkMode = themeNotifier.isDarkMode;
          return Theme(
            data: themeNotifier.currentTheme,
            child: Scaffold(
              backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
              appBar: AppBar(
                backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                title: Text(
                  'Cancelled Orders',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
                elevation: isDarkMode ? 0 : 0.5,
              ),
              body: _buildOrderList(context),
            ),
          );
        },
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
            Icon(Icons.cancel, size: 50, color: isDarkMode ? Colors.grey[600] : Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No cancelled orders',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[400] : Colors.grey,
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
      color: isDarkMode ? Colors.white : Colors.blue,
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
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