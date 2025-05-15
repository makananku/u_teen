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
import 'package:u_teen/widgets/seller/seller_custom_bottom_navigation.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/services/calendar_service.dart';
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

    // Get order counts using OrderProvider methods
    final onProcessCount = orderProvider.getProcessingOrdersForMerchant(sellerEmail).length;
    final cancelledCount = orderProvider.getCancelledOrdersForMerchant(sellerEmail).length;
    final completedCount = orderProvider.getCompletedOrdersForMerchant(sellerEmail).length;

    // Calculate sales metrics for completed orders
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfWeek = DateTime(now.year, now.month, now.day - (now.weekday - 1)).copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
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
        title: Text(tenantName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[700]!, Colors.blue[400]!],
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
            // Sales Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('My Sales', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[50]!, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                SalesMetricCard(
                                  value: todayCount.toString(),
                                  label: 'Today',
                                  icon: Icons.today,
                                ),
                                SalesMetricCard(
                                  value: weekCount.toString(),
                                  label: 'This Week',
                                  icon: Icons.calendar_view_week,
                                ),
                                SalesMetricCard(
                                  value: monthCount.toString(),
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
                                    MaterialPageRoute(builder: (context) => const onprocess.OnProcessScreen()),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusButton(
                                  text: 'Cancellation',
                                  count: cancelledCount,
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const cancellation.CancellationScreen()),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusButton(
                                  text: 'Completed',
                                  count: completedCount,
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const completed.CompletedScreen()),
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

            // Events Divider with Filter Icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Expanded(child: Divider(thickness: 1, endIndent: 10)),
                  Text(
                    'ACADEMIC CALENDER (${_filterMonths[_selectedFilterIndex]} MONTHS)',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold),
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

            // Events List with 3D Shadow Effect
            FutureBuilder<List<CalendarEvent>>(
              future: CalendarService().getPublicEvents(_filterMonths[_selectedFilterIndex]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  ));
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red[700])),
                  );
                }

                final events = snapshot.data ?? [];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: events.map((event) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(2, 4), // Shadow position
                            ),
                          ],
                        ),
                        child: Card(
                          elevation: 0, // Important: Set to 0 to use our custom shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Icon with colored background
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: CalendarUtils.getEventColor(event.summary).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: CalendarUtils.getEventColor(event.summary).withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(1, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    CalendarUtils.getEventIcon(event.summary),
                                    color: CalendarUtils.getEventColor(event.summary),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Event details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.summary,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            CalendarUtils.formatEventDate(event.start, event.end),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (event.description.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            event.description,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
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
}