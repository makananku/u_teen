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
import 'package:intl/intl.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  _SellerHomeScreenState createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  int _selectedFilterIndex = 2; // Default to 6 months
  final List<int> _filterMonths = [1, 3, 6];
  final Map<String, Color> _filterColors = {
    'All': Colors.blueAccent,
    'Holidays': Colors.redAccent,
    'Exams': Colors.orangeAccent,
    'Events': Colors.purpleAccent,
  };

  void _confirmLogout(BuildContext context) {
    LogoutService.showLogoutConfirmation(context);
  }

  Widget _buildCalendarFilterButton(BuildContext context) {
    return PopupMenuButton<String>(
      color: Colors.white,
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter',
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.filter_list,
              size: 16,
              color: Colors.blue[700],
            ),
          ],
        ),
      ),
      onSelected: (value) {
        setState(() {
          if (value == 'custom') {
            _showCustomDateRangePicker(context);
          } else {
            _selectedFilterIndex = int.parse(value);
          }
        });
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: '0',
          child: Row(
            children: [
              Icon(Icons.calendar_view_month, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text('1 Month'),
            ],
          ),
        ),
        PopupMenuItem(
          value: '1',
          child: Row(
            children: [
              Icon(Icons.calendar_view_week, color: Colors.green[700]),
              const SizedBox(width: 8),
              const Text('3 Months'),
            ],
          ),
        ),
        PopupMenuItem(
          value: '2',
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.orange[700]),
              const SizedBox(width: 8),
              const Text('6 Months'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'custom',
          child: Row(
            children: [
              Icon(Icons.date_range, color: Colors.purple[700]),
              const SizedBox(width: 8),
              const Text('Custom Range...'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeDisplay(BuildContext context) {
    final now = DateTime.now();
    final endDate = DateTime(
      now.year,
      now.month + _filterMonths[_selectedFilterIndex],
      now.day,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month, size: 16, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Text(
            '${DateFormat('MMM yyyy').format(now)} - ${DateFormat('MMM yyyy').format(endDate)}',
            style: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTypeChip(String label, IconData icon) {
    final color = _filterColors[label] ?? Colors.blueAccent;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
        selected: false,
        onSelected: (bool selected) {
          // Add your filter logic here
        },
        selectedColor: color.withOpacity(0.2),
        backgroundColor: color.withOpacity(0.1),
        labelStyle: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
    );
  }

  Widget _buildEventItem(calendar_service.CalendarEvent event) {
    final icon = CalendarUtils.getEventIcon(event.summary);
    final color = CalendarUtils.getEventColor(event.summary);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          event.summary,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              event.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_month, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  event.formattedDateRange,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            event.dayName,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showCustomDateRangePicker(BuildContext context) {
    DateTimeRange? selectedDateRange;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // optional: biar lebih modern
        ),
          title: const Text('Select Date Range'),
          content: SizedBox(
            width: double.maxFinite,
            child: CalendarDatePicker(
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              initialDate: DateTime.now(),
              onDateChanged: (DateTime date) {
                // Simplified range selection
                selectedDateRange = DateTimeRange(
                  start: date,
                  end: date.add(const Duration(days: 30)),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (selectedDateRange != null) {
                  // Implement custom date range filtering
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Apply'),
            ),
          ],
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
      body: CustomScrollView(
        slivers: [
          // Sliver App Bar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue[800]!,
                      Colors.blue[600]!,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.storefront,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tenantName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Kantin Kampus',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.logout, color: Colors.white),
                              onPressed: () => _confirmLogout(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
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
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
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

                // Calendar Events Section - Enhanced
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Calendar Header with Enhanced Controls
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'ACADEMIC CALENDAR',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                _buildCalendarFilterButton(context),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildDateRangeDisplay(context),
                          ],
                        ),
                      ),

                      // Events List
                      FutureBuilder<List<calendar_service.CalendarEvent>>(
                        future: calendar_service.CalendarService().getPublicEvents(_filterMonths[_selectedFilterIndex]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                              child: Text(
                                'Error loading calendar events',
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            );
                          }

                          final events = snapshot.data ?? [];

                          if (events.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                              child: Text(
                                'No events in the selected period',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              children: [
                                // Event Type Filter Chips
                                SizedBox(
                                  height: 40,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      _buildEventTypeChip('All', Icons.calendar_today),
                                      _buildEventTypeChip('Holidays', Icons.beach_access),
                                      _buildEventTypeChip('Exams', Icons.school),
                                      _buildEventTypeChip('Events', Icons.event),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...events.map((event) => _buildEventItem(event)).toList(),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
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