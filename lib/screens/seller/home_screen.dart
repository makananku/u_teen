import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/auth/logout_service.dart';
import 'package:u_teen/providers/order_provider.dart';
import 'package:u_teen/screens/seller/cancellation_screen.dart' as cancellation;
import 'package:u_teen/screens/seller/completed_screen.dart' as completed;
import 'package:u_teen/screens/seller/on_process_screen.dart' as onprocess;
import 'package:u_teen/widgets/seller/sales_metric_card.dart';
import 'package:u_teen/widgets/seller/status_button.dart';
import 'package:u_teen/widgets/seller/event_card.dart';
import 'package:u_teen/widgets/seller_custom_bottom_navigation.dart';
import 'package:provider/provider.dart';

class SellerHomeScreen extends StatelessWidget {
  const SellerHomeScreen({super.key});

  void _confirmLogout(BuildContext context) {
    LogoutService.showLogoutConfirmation(context);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final user = authProvider.user;
    final tenantName = user?.name ?? 'Tenant';
    final sellerEmail = user?.email ?? '';

    // Get order counts for the current seller
    final onProcessCount = orderProvider.processingOrders
      .where((order) => order.merchantName == sellerEmail)
      .length;
    final cancelledCount = orderProvider.cancelledOrders
        .where((order) => order.merchantName == sellerEmail)
        .length;
    final completedCount = orderProvider.completedOrders
        .where((order) => order.merchantName == sellerEmail)
        .length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          tenantName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue[700]!, Colors.blue[400]!],
            ),
          ),
        ),
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _confirmLogout(context),
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // My Sales Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Sales',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.blue[50]!, Colors.white],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: const [
                                SalesMetricCard(
                                  value: '24',
                                  label: 'Today',
                                  icon: Icons.today,
                                ),
                                SalesMetricCard(
                                  value: '156',
                                  label: 'This Week',
                                  icon: Icons.calendar_view_week,
                                ),
                                SalesMetricCard(
                                  value: '624',
                                  label: 'This Month',
                                  icon: Icons.calendar_today,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                StatusButton(
                                  text: 'On Process',
                                  count: onProcessCount,
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const onprocess.OnProcessScreen(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusButton(
                                  text: 'Cancellation',
                                  count: cancelledCount,
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const cancellation.CancellationScreen(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusButton(
                                  text: 'Completed',
                                  count: completedCount,
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const completed.CompletedScreen(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider with more style
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey[300],
                      endIndent: 10,
                    ),
                  ),
                  Text(
                    'UPCOMING EVENTS',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey[300],
                      indent: 10,
                    ),
                  ),
                ],
              ),
            ),

            // Calendar Events
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: const [
                  EventCard(
                    date: '13 - 23 Dec',
                    event: 'Final Exam',
                    description: 'Campus will be crowded',
                    icon: Icons.school,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 12),
                  EventCard(
                    date: '24 - 31 Dec',
                    event: 'Christmas Holiday',
                    description: 'Reduced campus activity',
                    icon: Icons.celebration,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: SellerCustomBottomNavigation(
        selectedIndex: 0,
        context: context,
      ),
    );
  }
}