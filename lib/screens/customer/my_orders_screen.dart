import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../auth/auth_provider.dart';
import '../../widgets/customer/custom_bottom_navigation.dart';
import '../../providers/order_provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/theme_notifier.dart';
import '../../models/order_model.dart';
import '../../widgets/order_card.dart';
import 'home_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final customerName = authProvider.user?.name ?? '';
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

    // Get orders for this customer
    final ongoingOrders = orderProvider.orders
        .where((order) =>
            (order.status == 'pending' ||
                order.status == 'processing' ||
                order.status == 'ready') &&
            order.customerName == customerName)
        .toList()
      ..sort((a, b) {
        const statusPriority = {
          'ready': 1,
          'pending': 2,
          'processing': 3,
        };
        return statusPriority[a.status]!.compareTo(statusPriority[b.status]!);
      });

    final historyOrders = orderProvider.orders
        .where((order) =>
            (order.status == 'completed' || order.status == 'cancelled') &&
            order.customerName == customerName)
        .toList();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.getCard(isDarkMode),
        appBar: AppBar(
          title: Text(
            'My Orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.getPrimaryText(isDarkMode),
            ),
          ),
          centerTitle: true,
          backgroundColor: AppTheme.getCard(isDarkMode),
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppTheme.getButton(isDarkMode),
            unselectedLabelColor: AppTheme.getPrimaryText(isDarkMode),
            indicatorColor: AppTheme.getButton(isDarkMode),
            tabs: const [Tab(text: "Ongoing"), Tab(text: "History")],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOrderList(ongoingOrders, "Ongoing", isDarkMode),
            _buildOrderList(historyOrders, "History", isDarkMode),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: CustomBottomNavigation(
          selectedIndex: 1,
          context: context,
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders, String type, bool isDarkMode) {
    if (orders.isEmpty) {
      return _buildEmptyOrderView(type, isDarkMode);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) => OrderCard(
          order: orders[index],
          onTap: () {},
        ),
      ),
    );
  }

  Widget _buildEmptyOrderView(String type, bool isDarkMode) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animation/empty_order.json',
                width: 280,
                height: 280,
                fit: BoxFit.contain,
                animate: true,
              ),
              const SizedBox(height: 16),
              Text(
                type == "Ongoing" ? "No Active Orders Yet" : "No Order History",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextDark(isDarkMode),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  type == "Ongoing"
                      ? "Your upcoming orders will appear here once you place an order"
                      : "Your completed orders will show up here for reference",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.getSecondaryText(isDarkMode),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.getAccentBlue(isDarkMode),
                  foregroundColor: AppTheme.getPrimaryText(!isDarkMode),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  elevation: 3,
                  shadowColor: AppTheme.getButton(isDarkMode).withOpacity(0.3),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      type == "Ongoing" ? Icons.restaurant : Icons.history,
                      size: 20,
                      color: AppTheme.getPrimaryText(!isDarkMode),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type == "Ongoing" ? "Order Now" : "View Menu",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getPrimaryText(!isDarkMode),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}