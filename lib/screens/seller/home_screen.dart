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
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class SellerHomeScreen extends StatelessWidget {
  const SellerHomeScreen({super.key});

  void _confirmLogout(BuildContext context) {
    LogoutService.showLogoutConfirmation(context);
  }

  IconData _getEventIcon(String summary) {
    final lowerSummary = summary.toLowerCase();
    if (lowerSummary.contains('exam')) return Icons.school;
    if (lowerSummary.contains('holiday')) return Icons.celebration;
    if (lowerSummary.contains('meeting')) return Icons.people;
    if (lowerSummary.contains('natal')) return Icons.celebration;
    if (lowerSummary.contains('idul') || lowerSummary.contains('fitri')) 
      return Icons.mosque;
    if (lowerSummary.contains('tahun baru')) return Icons.confirmation_number;
    if (lowerSummary.contains('kemerdekaan')) return Icons.flag;
    return Icons.event;
  }

  Color _getEventColor(String summary) {
    final lowerSummary = summary.toLowerCase();
    if (lowerSummary.contains('natal')) return Colors.green[600]!;
    if (lowerSummary.contains('idul') || lowerSummary.contains('fitri')) 
      return Colors.blue[600]!;
    if (lowerSummary.contains('kemerdekaan')) return Colors.red[600]!;
    if (lowerSummary.contains('exam')) return Colors.orange[600]!;
    return Colors.blue[400]!;
  }

  String _formatEventDate(DateTime start, DateTime end) {
    final dateFormat = DateFormat('d MMM', 'id_ID');
    final dayName = DateFormat('EEEE', 'id_ID').format(start);
    
    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      return '${dateFormat.format(start)} ($dayName)';
    }
    return '${dateFormat.format(start)} - ${dateFormat.format(end)} ($dayName)';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final user = authProvider.user;
    final tenantName = user?.name ?? 'Tenant';
    final sellerEmail = user?.email ?? '';

    // Get order counts
    final onProcessCount = orderProvider.processingOrders
        .where((order) => order.merchantName == sellerEmail).length;
    final cancelledCount = orderProvider.cancelledOrders
        .where((order) => order.merchantName == sellerEmail).length;
    final completedCount = orderProvider.completedOrders
        .where((order) => order.merchantName == sellerEmail).length;

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
                            child: const Row(
                              children: [
                                SalesMetricCard(value: '24', label: 'Today', icon: Icons.today),
                                SalesMetricCard(value: '156', label: 'This Week', icon: Icons.calendar_view_week),
                                SalesMetricCard(value: '624', label: 'This Month', icon: Icons.calendar_today),
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

            // Events Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Expanded(child: Divider(thickness: 1, endIndent: 10)),
                  Text('PUBLIC EVENTS (6 MONTHS)', 
                      style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold)),
                  const Expanded(child: Divider(thickness: 1, indent: 10)),
                ],
              ),
            ),

            // Events List with 3D Shadow Effect
            FutureBuilder<List<CalendarEvent>>(
              future: CalendarService().getPublicEvents(),
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
                                    color: _getEventColor(event.summary).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getEventColor(event.summary).withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(1, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _getEventIcon(event.summary),
                                    color: _getEventColor(event.summary),
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
                                            _formatEventDate(event.start, event.end),
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
                                              color: Colors.grey[700],
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