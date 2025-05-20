import 'package:flutter/material.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/providers/order_provider.dart';
import 'package:u_teen/widgets/order_card.dart';
import '../../models/order_model.dart';
import 'package:u_teen/providers/theme_notifier.dart';

class CompletedScreen extends StatelessWidget {
  const CompletedScreen({super.key});

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
                  'Completed Orders',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
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
            Icon(Icons.check_circle, size: 50, color: isDarkMode ? Colors.grey[600] : Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No completed orders yet',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[400] : Colors.grey,
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