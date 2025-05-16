import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/auth/logout_service.dart';
import 'package:u_teen/providers/order_provider.dart';
import 'package:u_teen/screens/seller/cancellation_screen.dart' as cancellation;
import 'package:u_teen/screens/seller/completed_screen.dart' as completed;
import 'package:u_teen/screens/seller/on_process_screen.dart' as onprocess;
import 'package:u_teen/screens/seller/rating_screen.dart';
import 'package:u_teen/widgets/seller/status_button.dart';
import 'package:u_teen/widgets/seller/event_card.dart';
import 'package:u_teen/widgets/seller/seller_custom_bottom_navigation.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/services/calendar_service.dart' as calendar_service;
import '../../utils/calendar_utils.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  _SellerHomeScreenState createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  int _selectedFilterIndex = 2; // Default to 6 months
  final List<int> _filterMonths = [1, 3, 6];

  void _confirmLogout(BuildContext context) {
    LogoutService.showLogoutConfirmation(context);
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Time Range',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._filterMonths.asMap().entries.map((entry) {
                int index = entry.key;
                int months = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedFilterIndex = index;
                      });
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 120,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: _selectedFilterIndex == index ? Colors.blue[50] : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$months Month${months > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: _selectedFilterIndex == index ? Colors.blue[700] : Colors.black87,
                          fontWeight: _selectedFilterIndex == index ? FontWeight.w600 : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.blue[700], fontSize: 14),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final user = authProvider.user;
    final tenantName = user?.name ?? 'Tenant';
    final sellerEmail = user?.email ?? '';

    // Get order counts
    final onProcessCount = orderProvider.getProcessingOrdersForMerchant(sellerEmail).length;
    final cancelledCount = orderProvider.getCancelledOrdersForMerchant(sellerEmail).length;
    final completedCount = orderProvider.getCompletedOrdersForMerchant(sellerEmail).length;

    // Calculate sales metrics
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfWeek = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    final todayCount = orderProvider.getCompletedOrdersForMerchant(sellerEmail)
        .where((order) => order.completedTime != null && order.completedTime!.isAfter(startOfToday))
        .length;
    final weekCount = orderProvider.getCompletedOrdersForMerchant(sellerEmail)
        .where((order) => order.completedTime != null && order.completedTime!.isAfter(startOfWeek))
        .length;
    final monthCount = orderProvider.getCompletedOrdersForMerchant(sellerEmail)
        .where((order) => order.completedTime != null && order.completedTime!.isAfter(startOfMonth))
        .length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          tenantName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[800]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with greeting
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $tenantName 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Here\'s your business overview',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.storefront,
                      color: Colors.blue,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            // Sales Metrics Cards - Horizontal Scroll
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sales Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildMetricCard(
                          context,
                          value: todayCount.toString(),
                          label: 'Today',
                          icon: Icons.today,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        _buildMetricCard(
                          context,
                          value: weekCount.toString(),
                          label: 'This Week',
                          icon: Icons.calendar_view_week,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 12),
                        _buildMetricCard(
                          context,
                          value: monthCount.toString(),
                          label: 'This Month',
                          icon: Icons.calendar_month,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Order Status Buttons - Grid Layout
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.5,
                    children: [
                      _buildStatusButton(
                        context,
                        text: 'On Process',
                        count: onProcessCount,
                        icon: Icons.hourglass_top,
                        color: Colors.blue,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const onprocess.OnProcessScreen()),
                        ),
                      ),
                      _buildStatusButton(
                        context,
                        text: 'Cancelled',
                        count: cancelledCount,
                        icon: Icons.cancel,
                        color: Colors.red,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const cancellation.CancellationScreen()),
                        ),
                      ),
                      _buildStatusButton(
                        context,
                        text: 'Completed',
                        count: completedCount,
                        icon: Icons.check_circle,
                        color: Colors.green,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const completed.CompletedScreen()),
                        ),
                      ),
                      _buildStatusButton(
                        context,
                        text: 'My Ratings',
                        count: 0,
                        icon: Icons.star_rate,
                        color: Colors.amber,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RatingScreen()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Calendar Events Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Expanded(child: Divider(thickness: 1, endIndent: 10)),
                  Text(
                    'ACADEMIC CALENDAR (${_filterMonths[_selectedFilterIndex]} MONTHS)',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showFilterDialog(context),
                    child: Icon(
                      Icons.filter_list,
                      size: 20,
                      color: Colors.blue[700],
                    ),
                  ),
                  const Expanded(child: Divider(thickness: 1, indent: 10)),
                ],
              ),
            ),

            // Events List
            FutureBuilder<List<calendar_service.CalendarEvent>>(
              future: calendar_service.CalendarService().getPublicEvents(_filterMonths[_selectedFilterIndex]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  );
                }

                final events = snapshot.data ?? [];

                if (events.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Text(
                      'No events found for the selected period',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: events.map((event) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: EventCard(
                        summary: event.summary,
                        description: event.description,
                        start: event.start,
                        end: event.end,
                      ),
                    )).toList(),
                  ),
                );
              },
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

  Widget _buildMetricCard(
    BuildContext context, {
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(
    BuildContext context, {
    required String text,
    required int count,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$count orders',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}