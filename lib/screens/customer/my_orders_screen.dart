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
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  Future<void> _initializeProviders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) {
      debugPrint('MyOrdersScreen: No user logged in, redirecting to login');
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    try {
      await orderProvider.initialize(authProvider.user!.email);
      if (orderProvider.lastError != null) {
        throw Exception(orderProvider.lastError);
      }
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('MyOrdersScreen: Error initializing OrderProvider: $e');
      // if (context.mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('Failed to load orders: $e'),
      //       backgroundColor: AppTheme.getSnackBarError(false),
      //     ),
      //   );
      // }
      setState(() {
        _isInitialized = true; // Allow UI to render error state
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    try {
      final orderProvider = Provider.of<OrderProvider>(context);
      final authProvider = Provider.of<AuthProvider>(context);

      if (!_isInitialized || authProvider.user == null) {
        return Scaffold(
          backgroundColor: AppTheme.getCard(isDarkMode),
          body: Center(
            child: CircularProgressIndicator(
              color: AppTheme.getButton(isDarkMode),
            ),
          ),
        );
      }

      debugPrint('MyOrdersScreen: User email: ${authProvider.user!.email}, name: ${authProvider.user!.name}');
      final customerName = authProvider.user!.name;
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
              tabs: const [Tab(text: 'Ongoing'), Tab(text: 'History')],
            ),
          ),
          body: orderProvider.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.getButton(isDarkMode),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrderList(ongoingOrders, "Ongoing", isDarkMode, orderProvider),
                    _buildOrderList(historyOrders, "History", isDarkMode, orderProvider),
                  ],
                ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: CustomBottomNavigation(
            selectedIndex: 1,
            context: context,
          ),
        ),
      );
    } catch (e) {
      debugPrint('MyOrdersScreen: Build error: $e');
      return Scaffold(
        backgroundColor: AppTheme.getCard(isDarkMode),
        body: Center(
          child: Text(
            'An error occurred: $e',
            style: TextStyle(color: AppTheme.getPrimaryText(isDarkMode)),
          ),
        ),
      );
    }
  }

  Widget _buildOrderList(List<Order> orders, String type, bool isDarkMode, OrderProvider orderProvider) {
    if (orders.isEmpty) {
      return _buildEmptyOrderView(type, isDarkMode);
    }

    return RefreshIndicator(
      onRefresh: () async {
        try {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          await orderProvider.initialize(authProvider.user!.email);
          if (orderProvider.lastError != null) {
            throw Exception(orderProvider.lastError);
          }
        } catch (e) {
          debugPrint('MyOrdersScreen: Refresh error: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to refresh orders: $e'),
              backgroundColor: AppTheme.getSnackBarError(isDarkMode),
            ),
          );
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) => OrderCard(
          order: orders[index],
          onTap: () {
            // TODO: Navigate to order details
          },
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