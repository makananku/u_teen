import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/auth/logout_service.dart';
import 'package:u_teen/providers/order_provider.dart';
import 'package:u_teen/screens/seller/cancellation_screen.dart' as cancellation;
import 'package:u_teen/screens/seller/completed_screen.dart' as completed;
import 'package:u_teen/screens/seller/on_process_screen.dart' as onprocess;
import 'package:u_teen/screens/seller/rating_screen.dart';
import 'package:u_teen/widgets/seller/calendar_widget.dart';
import 'package:u_teen/widgets/seller/custom_bottom_navigation.dart';
import 'package:u_teen/providers/theme_notifier.dart';
import 'package:intl/intl.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  _SellerHomeScreenState createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  int _selectedFilterIndex = 2; // Default to 6 months
  final List<int> _filterMonths = [1, 3, 6];
  String _selectedEventType = 'All'; // Default event type filter
  DateTimeRange? _customDateRange;
  DateTime? _lastBackPressTime;

  void _confirmLogout(BuildContext context) {
    LogoutService.showLogoutConfirmation(context);
  }

  Future<bool> _onWillPop() async {
    final currentTime = DateTime.now();
    final backPressDuration = _lastBackPressTime == null
        ? Duration.zero
        : currentTime.difference(_lastBackPressTime!);

    if (backPressDuration >= const Duration(seconds: 2)) {
      _lastBackPressTime = currentTime;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tekan kembali untuk keluar'),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.blueGrey[800]!
              : Colors.blue,
        ),
      );
      return false;
    } else {
      _lastBackPressTime = null;
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          final isDarkMode = themeNotifier.isDarkMode;
          return Theme(
            data: themeNotifier.currentTheme,
            child: WillPopScope(
              onWillPop: _onWillPop,
              child: Scaffold(
                backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.grey[50],
                body: CustomScrollView(
                  slivers: [
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
                              colors: isDarkMode
                                  ? [
                                      const Color(0xFF1E3A8A),
                                      const Color(0xFF1E40AF),
                                    ]
                                  : [
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
                                              Provider.of<AuthProvider>(context).user?.name ?? 'Tenant',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'By Libro',
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
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sales Overview',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : Colors.black,
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
                                        value: _getSalesCount(context, 'today').toString(),
                                        label: 'Today',
                                        icon: Icons.today,
                                        color: isDarkMode ? const Color(0xFF60A5FA) : Colors.blue,
                                      ),
                                      const SizedBox(width: 12),
                                      _buildMetricCard(
                                        context,
                                        value: _getSalesCount(context, 'week').toString(),
                                        label: 'This Week',
                                        icon: Icons.calendar_view_week,
                                        color: isDarkMode ? const Color(0xFF34D399) : Colors.green,
                                      ),
                                      const SizedBox(width: 12),
                                      _buildMetricCard(
                                        context,
                                        value: _getSalesCount(context, 'month').toString(),
                                        label: 'This Month',
                                        icon: Icons.calendar_month,
                                        color: isDarkMode ? const Color(0xFFFBBF24) : Colors.orange,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order Status',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : Colors.black,
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
                                      count: Provider.of<OrderProvider>(context)
                                          .getProcessingOrdersForMerchant(
                                              Provider.of<AuthProvider>(context).user?.email ?? '')
                                          .length,
                                      icon: Icons.hourglass_top,
                                      color: isDarkMode ? const Color(0xFF60A5FA) : Colors.blue,
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const onprocess.OnProcessScreen()),
                                      ),
                                    ),
                                    _buildStatusButton(
                                      context,
                                      text: 'Cancelled',
                                      count: Provider.of<OrderProvider>(context)
                                          .getCancelledOrdersForMerchant(
                                              Provider.of<AuthProvider>(context).user?.email ?? '')
                                          .length,
                                      icon: Icons.cancel,
                                      color: isDarkMode ? const Color(0xFFF87171) : Colors.red,
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const cancellation.CancellationScreen()),
                                      ),
                                    ),
                                    _buildStatusButton(
                                      context,
                                      text: 'Completed',
                                      count: Provider.of<OrderProvider>(context)
                                          .getCompletedOrdersForMerchant(
                                              Provider.of<AuthProvider>(context).user?.email ?? '')
                                          .length,
                                      icon: Icons.check_circle,
                                      color: isDarkMode ? const Color(0xFF34D399) : Colors.green,
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
                                      color: isDarkMode ? const Color(0xFFFBBF24) : Colors.amber,
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
                          CalendarSection(
                            selectedFilterIndex: _selectedFilterIndex,
                            filterMonths: _filterMonths,
                            selectedEventType: _selectedEventType,
                            customDateRange: _customDateRange,
                            onFilterChanged: (index) {
                              setState(() {
                                _selectedFilterIndex = index;
                                _customDateRange = null;
                              });
                            },
                            onEventTypeChanged: (type) {
                              setState(() {
                                _selectedEventType = type;
                              });
                            },
                            onCustomDateRangeSelected: (range) {
                              setState(() {
                                _customDateRange = range;
                                _selectedFilterIndex = -1;
                              });
                            },
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
              ),
            ),
          );
        },
      ),
    );
  }

  int _getSalesCount(BuildContext context, String period) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final sellerEmail = Provider.of<AuthProvider>(context).user?.email ?? '';
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfWeek = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    switch (period) {
      case 'today':
        return orderProvider.getCompletedOrdersForMerchant(sellerEmail)
            .where((order) => order.completedTime != null && order.completedTime!.isAfter(startOfToday))
            .length;
      case 'week':
        return orderProvider.getCompletedOrdersForMerchant(sellerEmail)
            .where((order) => order.completedTime != null && order.completedTime!.isAfter(startOfWeek))
            .length;
      case 'month':
        return orderProvider.getCompletedOrdersForMerchant(sellerEmail)
            .where((order) => order.completedTime != null && order.completedTime!.isAfter(startOfMonth))
            .length;
      default:
        return 0;
    }
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDarkMode
            ? []
            : [
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
                color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDarkMode
              ? []
              : [
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
                color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  if (text != 'My Ratings')
                    Text(
                      '$count orders',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}