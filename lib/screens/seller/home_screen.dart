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
import 'package:u_teen/utils/app_theme.dart';
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
          backgroundColor: AppTheme.getAccentPrimaryBlue(false),
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
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDarkMode;
    final Color appBarColor = isDarkMode ? const Color(0xFF1E3A8A) : Colors.blue[800]!;

    return Theme(
      data: themeNotifier.currentTheme,
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppTheme.getBackground(isDarkMode),
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 180,
                    floating: false,
                    pinned: true,
                    stretch: true,
                    backgroundColor: appBarColor,
                    flexibleSpace: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        final double shrinkOffset = constraints.biggest.height;
                        final double opacity = (shrinkOffset / 180).clamp(0.0, 1.0);

                        return FlexibleSpaceBar(
                          title: DefaultTextStyle(
                            style: TextStyle(
                              color: AppTheme.getAppBarText(isDarkMode),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            child: Opacity(
                              opacity: 1 - opacity,
                              child: const Text('Home'),
                            ),
                          ),
                          centerTitle: true,
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
                                          child: Icon(
                                            Icons.storefront,
                                            color: AppTheme.getAppBarText(isDarkMode),
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
                                                style: TextStyle(
                                                  color: AppTheme.getAppBarText(isDarkMode),
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'By Libro',
                                                style: TextStyle(
                                                  color: AppTheme.getAppBarText(isDarkMode).withOpacity(0.9),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.logout,
                                            color: AppTheme.getAppBarText(isDarkMode),
                                          ),
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
                                          Icon(
                                            Icons.calendar_today,
                                            size: 16,
                                            color: AppTheme.getAppBarText(isDarkMode),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
                                            style: TextStyle(
                                              color: AppTheme.getAppBarText(isDarkMode),
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
                        );
                      },
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
                                  color: AppTheme.getPrimaryText(isDarkMode),
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
                                      color: AppTheme.getAccentPrimaryBlue(isDarkMode),
                                    ),
                                    const SizedBox(width: 12),
                                    _buildMetricCard(
                                      context,
                                      value: _getSalesCount(context, 'week').toString(),
                                      label: 'This Week',
                                      icon: Icons.calendar_view_week,
                                      color: AppTheme.getSnackBarSuccess(isDarkMode),
                                    ),
                                    const SizedBox(width: 12),
                                    _buildMetricCard(
                                      context,
                                      value: _getSalesCount(context, 'month').toString(),
                                      label: 'This Month',
                                      icon: Icons.calendar_month,
                                      color: AppTheme.getRating(isDarkMode),
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
                                  color: AppTheme.getPrimaryText(isDarkMode),
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
                                    color: AppTheme.getAccentPrimaryBlue(isDarkMode),
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
                                    color: AppTheme.getSnackBarError(isDarkMode),
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
                                    color: AppTheme.getSnackBarSuccess(isDarkMode),
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
                                    color: AppTheme.getRating(isDarkMode),
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
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: SellerCustomBottomNavigation(
                  selectedIndex: 0,
                  context: context,
                ),
              ),
            ],
          ),
        ),
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
        color: AppTheme.getCard(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: AppTheme.getSecondaryText(isDarkMode).withOpacity(0.1),
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
                color: AppTheme.getPrimaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.getSecondaryText(isDarkMode),
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
          color: AppTheme.getCard(isDarkMode),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDarkMode
              ? []
              : [
                  BoxShadow(
                    color: AppTheme.getSecondaryText(isDarkMode).withOpacity(0.1),
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
                      color: AppTheme.getPrimaryText(isDarkMode),
                    ),
                  ),
                  if (text != 'My Ratings')
                    Text(
                      '$count orders',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.getSecondaryText(isDarkMode),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.getSecondaryText(isDarkMode),
            ),
          ],
        ),
      ),
    );
  }
}